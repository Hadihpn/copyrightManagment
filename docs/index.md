# Solidity API

## BAFC_NFT

### marketplacePercentage

```solidity
uint256 marketplacePercentage
```

### userCounter

```solidity
uint128 userCounter
```

### totalContribution

```solidity
uint256 totalContribution
```

### usersContributions

```solidity
mapping(address => uint256) usersContributions
```

### constructor

```solidity
constructor(uint256 ownerContribution, address marketPlace, address creator) public
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| ownerContribution | uint256 | ownerContribution |
| marketPlace | address | address of marketPlace |
| creator | address | address of creator |

### addUsersContributions

```solidity
function addUsersContributions(address userAddress, uint256 contribution) public
```

this function used because only marketPlace as owner of contract can use this function

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| userAddress | address | the id of nft you want to buy |
| contribution | uint256 | the amount of nft you want to buy |

### getUsersContributions

```solidity
function getUsersContributions(address userAddress) public view returns (uint256)
```

get address of nftContract per id

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| userAddress | address | address that you want its contribution |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | the amount of user contribution |

### withdraw

```solidity
function withdraw() public
```

this function used because only marketPlace as owner of contract can use this function

### receive

```solidity
receive() external payable
```

## NFTMarketplace

### NFTs

```solidity
mapping(address => struct NFTMarketplace.Listing1155) NFTs
```

its list of NFT's information

_the address of BAFC_NFT contract => instance of Listing1155_

### listingNFT

```solidity
mapping(uint256 => address) listingNFT
```

its list of NFT's address

_the id of token => address of nft_

### _listingIds1155

```solidity
struct Counters.Counter _listingIds1155
```

### constructor

```solidity
constructor() public
```

_Initializes the contract setting the deployer as the initial owner._

### Listing1155

```solidity
struct Listing1155 {
  address nftAddress;
  address seller;
  uint256 tokenId;
  uint256 price;
  uint256 amount;
}
```

### TokenListed1155

```solidity
event TokenListed1155(address seller, uint256 tokenId, uint256 amount, uint256 pricePerToken, uint256 listingId)
```

### newContributionAdded

```solidity
event newContributionAdded(address nftAddress, address contributerAddress, uint256 contributionAmount)
```

### TokenSold1155

```solidity
event TokenSold1155(address buyer, uint256 tokenId, uint256 amount, uint256 pricePerToken)
```

### mintNFT

```solidity
function mintNFT(address creator, string uri, uint256 ownerContribution, uint256 tokenId, uint256 price, uint256 amount) public
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| creator | address | address of deployer |
| uri | string | ipfs address of files |
| ownerContribution | uint256 | contribution of depoyer address |
| tokenId | uint256 | the id that you set for your nft |
| price | uint256 | the price that you set for nft |
| amount | uint256 | the amount that you mint  nft |

### addNFT

```solidity
function addNFT(address nftAddress, uint128 tokenId, uint128 price, uint128 amount) public
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nftAddress | address | address of nft that had been deployed before |
| tokenId | uint128 | the id that you set for your nft |
| price | uint128 | the price that you set for nft |
| amount | uint128 | the amount that you mint  nft |

### purchaseNFT

```solidity
function purchaseNFT(address nftAddress, uint256 tokenId, uint256 amount) public payable
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nftAddress | address | address of nft you want to buy |
| tokenId | uint256 | the id of nft you want to buy |
| amount | uint256 | the amount of nft you want to buy |

### addUsersContributions

```solidity
function addUsersContributions(address nftAddress, address userAddress, uint256 contribution) public
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nftAddress | address | address of nft you want to buy |
| userAddress | address | the id of nft you want to buy |
| contribution | uint256 | the amount of nft you want to buy |

### getNFTAddress

```solidity
function getNFTAddress(uint256 id) public view returns (address)
```

get address of nftContract per id

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | uint256 | id of mapping |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address | the address of nft Contracts |

### receive

```solidity
receive() external payable
```

## MyToken

### constructor

```solidity
constructor(address defaultAdmin, address marketPlace) public
```

### setURI

```solidity
function setURI(string newuri) public
```

set uri for nftContract

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| newuri | string | the uri of folder of your files |

### mint

```solidity
function mint(address account, uint256 id, uint256 amount, bytes data) public
```

### _update

```solidity
function _update(address from, address to, uint256[] ids, uint256[] values) internal
```

