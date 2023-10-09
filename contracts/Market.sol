// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BAFC_NFT.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract NFTMarketplace is Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    //mapping(nft address,NFT)
    mapping(address => Listing1155) public NFTs;
    mapping(uint256 => address) public listingNFT;
    Counters.Counter public _listingIds1155;

    constructor() Ownable(msg.sender) {}

    struct Listing1155 {
        address nftAddress;
        address seller;
        uint256 tokenId;
        uint256 amount;
        uint256 price;
    }
    event TokenListed1155(
        address indexed seller,
        uint256 indexed tokenId,
        uint256 amount,
        uint256 pricePerToken,
        uint indexed listingId
    );

    event TokenSold1155(
        address seller,
        address buyer,
        uint256 tokenId,
        uint256 amount,
        uint256 pricePerToken
    );

    function mintNFT(
        address creator,
        string memory uri,
        uint256 ownerContribution,
        uint256 tokenId,
        uint256 price,
        uint256 amount
    ) public  {
        BAFC_NFT nft = new BAFC_NFT(ownerContribution,address(this),creator );
        nft.setURI(uri);
        nft.mint(msg.sender, tokenId, amount, "");
        NFTs[address(nft)] = Listing1155(
            address(nft),
            msg.sender,
            tokenId,
            price,
            amount
        );
        emit TokenListed1155(
            msg.sender,
            tokenId,
            price,
            amount,
            uint128(_listingIds1155.current())
        );
        listingNFT[_listingIds1155.current()] = address(nft);
        _listingIds1155.increment();
    }
function addNFT(
        address nftAddress,
        uint128 tokenId,
        uint128 price,
        uint128 amount
    ) public  {
        require(NFTs[nftAddress].seller == msg.sender,"only owner can mint new nft");
        BAFC_NFT nft = BAFC_NFT(payable(nftAddress));
        nft.mint(msg.sender, tokenId, amount, "");
        NFTs[address(nft)] = Listing1155(
            address(nft),
            msg.sender,
            tokenId,
            price,
            amount
        );
        emit TokenListed1155(
            msg.sender,
            tokenId,
            price,
            amount,
            uint128(_listingIds1155.current())
        );
        listingNFT[_listingIds1155.current()] = address(nft);
        _listingIds1155.increment();
    }
    function purchaseNFT(
        address nftAdd,
        uint256 tokenId,
        uint256 amount
    ) public payable nonReentrant {
        Listing1155 memory nft = NFTs[nftAdd];
        require(msg.sender != nft.seller, "Can't buy your own tokens!");
          require(msg.value >= nft.price * amount, "Insufficient funds!");
        console.log(msg.value);
        console.log(nft.price);
        console.log(amount);
        console.log(nft.price * amount);
        require(
            IERC1155(nft.nftAddress).balanceOf(nft.seller, tokenId) >= amount,
            "Seller doesn't have enough tokens!"
        );
        (bool success, ) = payable(nft.nftAddress).call{value: ((nft.price) * amount)}(
            ""
        );
         require(success, "Unable to transfer funds to seller");
        
        emit TokenSold1155(nft.seller, msg.sender, tokenId, amount, nft.price);
    }

    function withDraw(address nftAdd) public {
        BAFC_NFT(payable(NFTs[nftAdd].nftAddress)).withdraw();
    }

    function getNFTAddress(uint256 id) public view returns (address) {
        return listingNFT[id];
    }

    function balanceOf(
        address userAddr,
        address nftAddr,
        uint256 tokenId
    ) public view returns (uint256) {
        return
            BAFC_NFT(payable(NFTs[nftAddr].nftAddress)).balanceOf(userAddr, tokenId);
    }

    receive() external payable {}
}
