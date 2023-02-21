// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {IVulnerableContract} from "./IVulnerableContract.sol";
import {ERC1363} from "erc-payable-token/contracts/token/ERC1363/ERC1363.sol";
import {IERC1363Receiver} from "erc-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol";
import {ERC20Capped, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title RareSkills Week1 ERC-1363 Bonding Curve Mint Contract
 * @author Ben Yu
 * @notice An ERC-1363 contract that implements sanctioning addresses, admin transfers, and linear bonding curve minting
 */
contract VulnerableContract is
    ERC1363,
    IERC1363Receiver,
    ERC20Capped,
    Ownable,
    IVulnerableContract
{
    uint256 public constant MAX_SUPPLY = 100_000_000 ether; // 100 million tokens; ether is shorthand for 18 decimal places

    mapping(address => uint256) public depositedTokens;
    mapping(address => bool) public freeClaimMinted;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) ERC20Capped(MAX_SUPPLY) {
        _mint(address(this), 100000);
    }

    function _mint(
        address account,
        uint256 amount
    ) internal override(ERC20, ERC20Capped) {
        ERC20Capped._mint(account, amount);
    }

    function freeInitialMint() external {
        require(
            !freeClaimMinted[msg.sender],
            "Cannot claim free initial token twice"
        );
        freeClaimMinted[msg.sender] = true;
        _mint(msg.sender, 1);
    }

    function safeWithdrawTokens() external {
        _approve(address(this), msg.sender, MAX_SUPPLY);
        uint256 oldBalance = depositedTokens[msg.sender];
        depositedTokens[msg.sender] = 0;
        transferFromAndCall(address(this), msg.sender, oldBalance);
    }

    function reentrancyAttackWithdrawTokens() external {
        _approve(address(this), msg.sender, MAX_SUPPLY);
        transferFromAndCall(
            address(this),
            msg.sender,
            depositedTokens[msg.sender]
        );
        depositedTokens[msg.sender] = 0;
    }

    /**
     * @notice Allows for tokens to be sent to this contract and then refunded at a 10% loss at current market rate
     * @dev Any ERC1363 smart contract calls this function on the recipient
     * after a `transfer` or a `transferFrom`. This function MAY throw to revert and reject the
     * transfer. Return of other than the magic value MUST result in the
     * transaction being reverted.
     * Note: the token contract address is always the message sender.
     * @param spender address The address which called `transferAndCall` or `transferFromAndCall` function
     * @param sender address The address which are token transferred from
     * @param amount uint256 The amount of tokens transferred
     * @param data bytes Additional data with no specified format
     * @return `bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"))` unless throwing
     */
    function onTransferReceived(
        address spender,
        address sender,
        uint256 amount,
        bytes calldata data
    ) external override returns (bytes4) {
        depositedTokens[sender] += amount;
        return
            bytes4(
                keccak256("onTransferReceived(address,address,uint256,bytes)")
            );
    }
}
