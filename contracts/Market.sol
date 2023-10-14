// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BAFC_NFT.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

///@title basis of simple copyright management marketPlace
///@author hadihpn
/**
 * ///@notice this contract can be used as simple copyright manamgent system marketPlace
 * you can create contribution for any user after minting nft and everyone can withdraw their contribution
 */
///@custom:experimental this is an experimental contracts
contract NFTMarketplace is Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    ///@notice its list of NFT's information
    ///@dev the address of BAFC_NFT contract =>(tokenId => instance of Listing1155)
    mapping(address => mapping(uint256 =>Listing1155)) public NFTs;
    ///@notice its list of NFT's address
    ///@dev the id of token => address of nft
    mapping(address => uint256) public listingNFT;
    ///@notice its list of NFT's address
    ///@dev the id of token => address of nft
    mapping(uint256 => address) public listingNFTAddress;
    Counters.Counter public _listingIds1155;

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() Ownable(msg.sender) {}

    struct Listing1155 {

        address nftAddress;
        address seller;
        uint256 tokenId;
        uint256 price;
        uint256 amount;
    }
    event TokenListed1155(
        address indexed nftAddress,
        address indexed seller,
        uint256 indexed tokenId,
        uint256 amount,
        uint256 pricePerToken
    );
    event newContributionAdded(
        address indexed nftAddress,
        address indexed contributerAddress,
        uint256 contributionAmount
    );
    event TokenSold1155(
        address buyer,
        uint256 tokenId,
        uint256 amount,
        uint256 pricePerToken
    );

    /** 
    /// @notice create an instance of BAFC_NFT contract 
    /// set uri 
    /// mint an nft 
    /// emit TokenListed1155 event
    /// set address of new BAFC_NFT contract in mapping 
    /// increase _listingIds1155 
*/
    /// @param uri ipfs address of files
    /// @param ownerContribution contribution of depoyer address
    /// @param price the price that you set for nft
    /// @param amount the amount that you mint  nft
    function mintNFT(
        string memory uri,
        uint256 ownerContribution,
        uint256 price,
        uint256 amount
    ) public{
        BAFC_NFT nft = new BAFC_NFT(ownerContribution, address(this), msg.sender);
        nft.setURI(uri);
        nft.mint(msg.sender, 0, amount, "");
        NFTs[address(nft)][0] = Listing1155(
            address(nft),
            msg.sender,
            0,
            price,
            amount
        );
        emit TokenListed1155(
            address(nft),
            msg.sender,
            0,
            price,
            amount
        );
       listingNFT[address(nft)]=0;
       listingNFTAddress[_listingIds1155.current()]=address(nft);
       _listingIds1155.increment();
    }

    /// @notice add new nft To deployed BAFC_NFT

    /// @param nftAddress  address of nft that had been deployed before
    /// @param price the price that you set for nft
    /// @param amount the amount that you mint  nft
    function addNFT(
        address nftAddress,
        uint128 price,
        uint128 amount
    ) public {
        require(
            NFTs[nftAddress][0].seller == msg.sender,
            "only owner can mint new nft"
        );
        BAFC_NFT nft = BAFC_NFT(payable(nftAddress));
        uint256 newTokenId= listingNFT[nftAddress]+1;
        nft.mint(msg.sender, newTokenId, amount, "");
        
        NFTs[address(nft)][newTokenId] = Listing1155(
            address(nft),
            msg.sender,
            newTokenId,
            price,
            amount
        );
        emit TokenListed1155(
            address(nft),
            msg.sender,
            newTokenId,
            price,
            amount
        );
        // listingNFT[_listingIds1155.current()] = address(nft);
        _listingIds1155.increment();
    }

    /** 
    /// @notice purchase nft  & send fee to market and contract
    /// @notice 2 percent of value that has been send for purchasing will transfer to market as purchaseFee
     Requirements:
     *
     * cannot buy your nft
     * enough token must be available
     * the value should be enough for buying per amount and price
     * /// emit TokenSold1155 event after solding nft
*/
    /// @param nftAddress  address of nft you want to buy
    /// @param tokenId the id of nft you want to buy
    /// @param amount the amount of nft you want to buy
    function purchaseNFT(
        address nftAddress,
        uint256 tokenId,
        uint256 amount
    ) public payable nonReentrant {
        require(nftAddress != address(0), "please enter correct address");
        Listing1155 memory nft = NFTs[nftAddress][tokenId];
        require(msg.sender != nft.seller, "Can't buy your own tokens!");
        require(
            msg.value >= nft.price * (10 ** 18) * amount,
            "Insufficient funds!"
        );
        require(
            IERC1155(nft.nftAddress).balanceOf(nft.seller, tokenId) >= amount,
            "Seller doesn't have enough tokens!"
        );
        (bool success, ) = payable(nft.nftAddress).call{
            value: (98 * (msg.value / 100))
        }("");
        require(success, "Unable to transfer funds to reciever");
        transfer(nftAddress, nft.seller, msg.sender, tokenId, amount);
        // BAFC_NFT nftContract = BAFC_NFT(payable(nftAddress));
        // nftContract.safeTransferFrom(nft.seller, msg.sender, tokenId, amount, "");
        emit TokenSold1155(msg.sender, tokenId, amount, nft.price);
    }

    function transfer(
        address nftAddress,
        address seller,
        address to,
        uint256 tokenId,
        uint256 amount
    ) internal {
        require(nftAddress != address(0), "please enter correct address");
        BAFC_NFT nftContract = BAFC_NFT(payable(nftAddress));
        nftContract.safeTransferFrom(seller, to, tokenId, amount, "");
    }

    /** 
    /// @notice add newUserContribution to BAFC_NFT contract
     * /// emit newContributionAdded event
*/
    /// @param nftAddress  address of nft you want to buy
    /// @param userAddress the id of nft you want to buy
    /// @param contribution the amount of nft you want to buy
    function addUsersContributions(
        address nftAddress,
        address userAddress,
        uint256 contribution
    ) public {
        BAFC_NFT(payable(nftAddress)).addUsersContributions(
            userAddress,
            contribution
        );
        emit newContributionAdded(nftAddress, userAddress, contribution);
    }

    // /// @notice get address of nftContract per id
    // /// @param id  id of mapping
    // /// @return the address of nft Contracts
    // function getNFTAddress(uint256 id) public view returns (address) {
    //     return listingNFT[id];
    // }

    /** 
    /// @notice by this function owner of token can send their tokens to anotherone
    ///@dev this function had been written because transfering tokens must be done by marketplace
     
*/
    function transferNFT(
        address nftAddress,
        address to,
        uint256 tokenId,
        uint256 amount
    ) public {
        require(
            IERC1155(nftAddress).balanceOf(msg.sender, tokenId) >= amount,
            "you dont't have enough tokens!"
        );
        // require(to != "0x0","you cannot send to zero address");
        BAFC_NFT(payable(nftAddress)).safeTransferFrom(
            msg.sender,
            to,
            tokenId,
            amount,
            ""
        );
    }
 /** 
    /// @notice by this function owner of market withdraw all balance
     
*/
    function withdraw() public onlyOwner nonReentrant {
        require(address(this).balance > 0, "you haven't any balance");
        (bool success, ) = payable(msg.sender).call{value: (address(this).balance) }("");
        require(success);
    }

    receive() external payable {}
}