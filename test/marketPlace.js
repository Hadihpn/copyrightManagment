const { expect } = require("chai");
const { network, deployments, ethers } = require("hardhat");
const { abi } = require("../artifacts/contracts/BAFC_NFT.sol/BAFC_NFT.json")
describe("NFTMarketplace", async function () {
    let deployer, acc01, acc02;
    const sendValue = ethers.utils.parseEther("15");
    let market, accounts;
    beforeEach(async () => {
        // deployer = (await getNamedAccounts()).deployer       
        [deployer, acc01, acc02] = await ethers.getSigners()
        const Market = await ethers.getContractFactory("NFTMarketplace");
        market = await Market.deploy();
    })
    describe("MarkerPlace", async function () {
        describe("constructor", function () {
            it("owner address must bee equal to deployer", async function () {
                expect(deployer.address).to.be.equal(await market.owner());
            });
        });
        describe(" NFT", function () {
            let contract, NFTAddress;
            let uri = "my";
            beforeEach(async () => {


                await market.mintNFT(deployer.address, uri, 10, 0, 100, 1000);
                NFTAddress = await market.listingNFT(0);
                contract = new ethers.Contract(NFTAddress, abi, deployer);
            });
            describe("mint NFT", function () {
                it("next _listingIds1155 increament", async function () {
                    expect(await market._listingIds1155()).to.be.equal(1);
                });
                it("checking uri", async function () {
                    expect(await contract.uri(0)).to.be.equal(uri);
                });
                it("getNFTAddress", async function () {
                    expect(await market.getNFTAddress(0)).to.be.equal(contract.address);
                });

                it("checking balanceOf owner", async function () {
                    expect(await contract.balanceOf(deployer.address, 0)).to.be.equal(1000);
                });
                it("checking minting event emmited", async function () {
                    expect(await market.mintNFT(deployer.address, uri, 10, 0, 100, 1000))
                        .to.emit(market, "TokenListed1155").withArgs(deployer.address, 0, 100, 1000, 2);
                });
                it("add new nft", async function () {
                    await market.addNFT(NFTAddress, 1, 100, 999)
                    expect(expect(await market._listingIds1155()).to.be.equal(2))
                    NFTAddress = await market.listingNFT(1);
                    contract = new ethers.Contract(NFTAddress, abi, deployer);
                    expect(await contract.balanceOf(deployer.address, 1)).to.be.equal(999);
                });
                it("add new nft with another account would be reverted", async function () {
                    await expect(market.connect(acc01).addNFT(NFTAddress, 1, 100, 1000))
                        .to.be.revertedWith("only owner can mint new nft");
                });
                it("add contribution", async function () {
                    //    let addContribution = await market.addUsersContributions(contract.address,acc02.address,20);
                    expect(await market.addUsersContributions(contract.address, acc02.address, 20)).to.be.emit(market, "newContributionAdded").withArgs(contract.address, acc02.address, 20);
                    expect(await contract.getUsersContributions(acc02.address)).to.be.equal(20);

                });
            })
            describe("purchase NFT", function () {
                it("purchase with acc01", async function () {
                    const tokenId = 0;
                    const amount = 2;
                    const price = 100;
                    let valuePerEther = amount * price;
                    let valuePerWei = ethers.utils.parseUnits(valuePerEther.toString(), "ether");

                    expect(await market.connect(acc01).purchaseNFT(NFTAddress, tokenId, amount, { value: valuePerWei }))
                        .to.be.emit(market, "TokenSold1155").withArgs(acc01.address, tokenId, amount, price);
                    expect(await ethers.provider.getBalance(market.address))
                        .to.be.equal(ethers.utils.parseUnits((0.02 * valuePerEther).toString(), "ether"));
                    await contract.safeTransferFrom(
                        deployer.address,
                        acc01.address,
                        0,
                        2, 0x00
                    );

                    await expect(await contract.balanceOf(acc01.address, 0))
                        .to.be.equal(2);
                    expect(await ethers.provider.getBalance(contract.address))
                        .to.be.equal(ethers.utils.parseUnits((0.98 * valuePerEther).toString(), "ether"));


                });
                it("purchase with acc01 should be reverted ", async function () {
                    const tokenId = 0;
                    const amount = 2;
                    const price = 100;
                    let valuePerEther = amount * price;
                    let valuePerWei = ethers.utils.parseUnits(valuePerEther.toString(), "ether");

                    expect(await market.connect(acc01).purchaseNFT(NFTAddress, tokenId, amount, { value: valuePerWei }))
                        .to.be.emit(market, "TokenSold1155").withArgs(acc01.address, tokenId, amount, price);
                    await expect(contract.connect(acc01).safeTransferFrom(deployer.address, acc01.address, 0, 2, 0x00))
                        .to.be.reverted;
                    // .to.be.revertedWithCustomError(contract,"ERC1155MissingApprovalForAll");
                });
            })
            describe("withDraw", function () {
                it("withDraw with acc02", async function () {
                    let beforeWithdraw = await ethers.provider.getBalance(acc02.address);
                    await market.addUsersContributions(contract.address, acc02.address, 20);
                    await market.connect(acc01).purchaseNFT(NFTAddress, 0, 2, { value: ethers.utils.parseUnits("200", "ether") })
                    expect(await contract.getUsersContributions(acc02.address)).to.be.equal(20);
                    await contract.connect(acc02).withdraw();
                    await expect((await ethers.provider.getBalance(acc02.address)).gt(beforeWithdraw)).to.be.true;
                });
            })
        })
    })
})