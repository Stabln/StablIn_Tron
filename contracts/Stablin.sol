// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "./TRC721.sol";
import "./interface/IUSDT.sol";
import "./interface/IUSDC.sol";

/*
//                           ***DEMO***
//  This contract has only two functions, mintWithTenUSD() and redeem().
//  mintWithTenUSD(): User can mint by paying 10 USD
//  redeem(): redeem USD they paid, and return NFT to this contract
//  * In Demo,
//  * 1. Only USDC is used
//  * 2. After redeem, NFT is lock into contract.
*/ 
contract Stablin is TRC721{

// using SafeERC20 for IERC20

    struct NFTInfo{
        uint256 tokenId;
        address paymentToken;
        uint256 tokenAmount;
        address owner;
    }

    uint256 public totalSupply;
    uint256 public totalSupplyTenUSD;
    uint256 public totalSupplyFiftyUSD;
    uint256 public totalFeeClaimed;
    mapping (uint256 => NFTInfo) public NFTInfos; // token Id => NFTInfo

    // munbai USDC: 0xFEca406dA9727A25E71e732F9961F680059eF1F9
    address public immutable USDC;
    address public immutable USDT;
    
    event totalSupplyAdded(uint256);
    event mintNFT_FiftyUSD(address owner, uint256 tokenId);
    event mintNFT_TenUSD(address owner, uint256 tokenId);

    constructor(uint256 _totalSupply, address _USDC, address _USDT) TRC721("Stablen",  "STB") {
        require(_USDC != address(0), "USDC is ZERO ADDRESS");
        require(_USDT != address(0), "USDT is ZERO ADDRESS");

        USDT = _USDT;
        USDC = _USDC;
        totalSupply = _totalSupply;
    }

    // function setBaseURI(string memory baseURI) public onlyOwner {
    //     _setBaseURI(baseURI);
    // }
    function _baseURI() internal pure returns (string memory) {
        return "needBaseURI";
    }

    /// @notice Newly mint NFT worth 10 USD
    /// @dev Transfers the `paymentToken` from `msg.sender` to the contract
    /// @dev must approved before use `transferFrom`, `paymentToken.approve(...)`
    /// @param paymentToken USDC or USDT, only USDC for DEMO
    function mintWithTenUSD(address paymentToken) public {
        require(totalSupplyTenUSD < 50, "exceed total supply");
        uint256 tokenId = totalSupplyTenUSD;
        
        // 10USD for NFT and 1% fee
        uint256 amount = getBuyAmount(10*10**6);
        // must approve the contract for payment
        if(paymentToken == USDT){
            // USDT payment
            IUSDT(USDT).transferFrom(msg.sender, address(this), amount);
        } else if(paymentToken == USDC){
            // USDC payment
            IUSDC(USDC).transferFrom(msg.sender, address(this), amount);
        } else{
            revert("Wrong Payment Token");
        }
 
        NFTInfos[tokenId] = NFTInfo(
            tokenId,
            paymentToken,
            10*10**6,
            msg.sender
        );

        // mint token
        totalSupplyTenUSD++;
        _safeMint(msg.sender, tokenId);
    }

    /// @notice Users can redeem USDT or USDC, and return NFT to contract
    /// @dev Transfers the `paymentToken` to `msg.sender` and `safeTransferFrom` NFT to address(this)
    /// @param tokenId USDC or USDT, only USDC for DEMO
    function redeem(uint256 tokenId) public {
        address tokenOwner = ownerOf(tokenId);
        require(tokenOwner == msg.sender,"Not Owner");

        // later used for payment
        NFTInfo memory tokenInfo = NFTInfos[tokenId];
        
        // update Info of NFT
        NFTInfos[tokenId] = NFTInfo(
            tokenId,
            address(0),
            10*10**6,
            address(this)
        );

        // NFT 회수
        safeTransferFrom(msg.sender, address(this), tokenId);
        
        // token 돈 다시 보내주기
        // amount = 99%
        uint256 amount = tokenInfo.tokenAmount - (tokenInfo.tokenAmount * 1 / 100);

        // maybe just use safeTransfer
        if(tokenInfo.paymentToken == USDT){
            IUSDT(USDT).transfer(tokenOwner, amount);
        } else {
            IUSDC(USDC).transfer(tokenOwner, amount);
        }

    }
    
    // only for the DEMO!!!
    function feeRedeem() public {
        // require(msg.sender == ownerOf(0), "Wrong Fee Collector");
        IUSDT(USDT).transfer(msg.sender, totalFeeClaimed);
        totalFeeClaimed = 0;
    }
    
    function getBuyAmount(uint256 price) public pure returns(uint256 amount){
        amount = price + (price * 1 / 100);
    }

    function onTRC721Received(address, address, uint256, bytes calldata) external returns (bytes4){
        return ITRC721Receiver.onTRC721Received.selector;
    }


}
