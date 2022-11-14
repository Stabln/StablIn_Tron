// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

interface IUSDT {
    function transferFrom(address, address, uint256) external;
    function transfer(address, uint256) external;
}
