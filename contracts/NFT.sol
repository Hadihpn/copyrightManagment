// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "hardhat/console.sol";

contract NFT is ERC1155, ERC1155Supply, Ownable {
    constructor(
        address defaultAdmin,
        address marketPlace
    ) ERC1155("") Ownable(marketPlace) {}

    /// @notice set uri for nftContract
    /// @param newuri  the uri of folder of your files
    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyOwner {
        _mint(account, id, amount, data);
    }

    // function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
    //     public
    //     onlyOwner
    // {
    //     _mintBatch(to, ids, amounts, data);
    // }

    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Supply) {
        super._update(from, to, ids, values);
    }

    // function supportsInterface(bytes4 interfaceId)
    //     public
    //     view
    //     override(ERC1155)
    //     returns (bool)
    // {
    //     return super.supportsInterface(interfaceId);
    // }
}
