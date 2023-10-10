// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./NFT.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

///@title basis of simple copyright management
///@author hadihpn
/**
 * ///@notice this contract can be used as simple copyright manamgent system
 */
///@custom:experimental this is an experimental contracts
contract BAFC_NFT is MyToken {
    uint256 marketplacePercentage = 125;
    uint128 internal userCounter;
    mapping(address => uint256) private _salesOrderNounces;
    mapping(bytes32 => bool) private _invalidatedSalesOrders;
    address private _owner;
    uint256 public totalContribution;
    mapping(address => uint256) public usersContributions;

    /**
     * @dev Initializes the contract and set deployer contribution and set owner
     */
    /// @param ownerContribution  ownerContribution
    /// @param marketPlace  address of marketPlace
    /// @param creator  address of creator
    constructor(
        uint256 ownerContribution,
        address marketPlace,
        address creator
    ) MyToken(marketPlace, marketPlace) {
        _owner = marketPlace;
        usersContributions[creator] = ownerContribution;
        totalContribution += ownerContribution;
    }

    /** 
    /// @notice add newUserContribution to BAFC_NFT contract
     * /// emit newContributionAdded event
     * requirement just marketplca as owner can call this function
     * requirement contribution must be greater than zero
     
*/
    /// this function used because only marketPlace as owner of contract can use this function
    /// @param userAddress the id of nft you want to buy
    /// @param contribution the amount of nft you want to buy
    function addUsersContributions(
        address userAddress,
        uint256 contribution
    ) public {
        require(msg.sender == _owner, "you have not enough permisson");
        require(contribution > 0, "please enter right share");
        usersContributions[userAddress] = contribution;
        totalContribution += contribution;
    }

    /// @notice get address of nftContract per id
    /// @param userAddress  address that you want its contribution
    /// @return the amount of user contribution
    function getUsersContributions(
        address userAddress
    ) public view returns (uint256) {
        return usersContributions[userAddress];
    }

    /** 
    /// @notice you can withdraw balance of contract per your contribution
     * requirement balance of contract must be greater than zero
     * requirement your contribution must be added before
     
*/

    /// this function used because only marketPlace as owner of contract can use this function
    function withdraw() public {
        require(address(this).balance > 0);
        require(
            usersContributions[msg.sender] > 0,
            "you can just withdraw zero "
        );

        (bool success, ) = payable(msg.sender).call{
            value: (address(this).balance * usersContributions[msg.sender]) /
                (totalContribution * 100)
        }("");
        require(success);
    }

    receive() external payable {}
}
