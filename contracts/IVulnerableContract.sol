// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC1363} from "erc-payable-token/contracts/token/ERC1363/IERC1363.sol";

interface IVulnerableContract is IERC1363 {
    function freeInitialMint() external;

    function safeWithdrawTokens() external;

    function reentrancyAttackWithdrawTokens() external;
}
