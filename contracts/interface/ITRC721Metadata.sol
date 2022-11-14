// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "./ITRC721.sol";

/**
 * @title TRC-721 Non-Fungible Token Standard, optional metadata extension
 */
interface ITRC721Metadata is ITRC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
