// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./NFT.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BAFC_NFT is MyToken {
    uint256 marketplacePercentage = 125;

    // using Counters for Counters.Counter;
    uint128 internal userCounter;
    mapping(address => uint256) private _salesOrderNounces;
    mapping(bytes32 => bool) private _invalidatedSalesOrders;
    address private _owner;
    uint256 public totalContribution;
    mapping(address => uint256) public usersContributions;

    constructor(
        uint256 ownerContribution,
        address marketPlace,
        address creator
    ) MyToken(marketPlace, marketPlace) {
        _owner = marketPlace;
        usersContributions[creator] = ownerContribution;
        totalContribution +=ownerContribution;
    }

    function addUsersContributions(
        address userAddress,
        uint256 contribution
    ) public {
        require(msg.sender == _owner, "you have not enough permisson");
        require(contribution > 0, "please enter right share");
        usersContributions[userAddress] = contribution;
        totalContribution += contribution;
    }

    function getUsersContributions(
        address userAddress
    ) public view returns (uint256) {
        return usersContributions[userAddress];
    }

    function withdraw() public {
        require(address(this).balance > 0);
        require(
            usersContributions[msg.sender] > 0,
            "you can just withdraw zero "
        );
          
          (bool success, ) = payable(msg.sender).call{value: (address(this).balance*usersContributions[msg.sender])/(totalContribution*100)}("");
          require(success);
    }

    receive() external payable {}
}
