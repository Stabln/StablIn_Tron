// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

interface IUSDC {
    function transferFrom(address, address, uint) external returns (bool);
    function transfer(address, uint256) external;
}
