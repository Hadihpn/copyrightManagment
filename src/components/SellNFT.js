import Navbar from "./Navbar";
import { useState } from "react";
import { uploadFileToIPFS, uploadJSONToIPFS } from "../pinata";
import Marketplace from '../Marketplace.json';
import { useLocation } from "react-router";
import {ethers} from "ethers";
export default function SellNFT() {
    const [formParams, updateFormParams] = useState({ name: '', description: '', price: '' });
    const [fileURL, setFileURL] = useState(null);
    // const ethers = require("ethers");
    const [message, updateMessage] = useState('');
    const location = useLocation();

    async function OnChangeFile(e) {
        var file = e.target.files[0];

        try {
            const response = await uploadFileToIPFS(file);
            if (response.success === true) {
                console.log("Uploaded image to pinata", response.pinataURL);
                setFileURL(response.pinataURL);
            }
        } catch (e) {
            console.log("error during uplaod", e)
        }
    }
    async function uploadMetadataToIPFS(e) {
        const { name, description, price } = formParams;

        if (!name || !description || !fileURL)
            return;
        const nftJSON = {
            name, description, price, image: fileURL
        }
        try {
            const response = await uploadJSONToIPFS(nftJSON);
            if (response.success === true) {
                console.log("uploaded json to pinata", response);
                return response.pinataURL;
            }
        } catch (e) {
            console.log("error during uplaod", e)
        }
    }
    async function listNFT(e) {
        e.preventDefault();

        try {
            const metadataURL = await uploadMetadataToIPFS();
            console.log(metadataURL)
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            console.log(await signer.getAddress())
            updateMessage("Please wait .... uploading (upto 5 mins");
            console.log("Marketplace.address "+Marketplace.address)
            let contract = new ethers.Contract(Marketplace.address, Marketplace.abi, signer);
            console.log(contract)
            const price = ethers.utils.parseUnits(formParams.price, "ether");
            // mintNFT( uri, ownerContribution, tokenId, price, amount)
            let transaction = await contract.mintNFT("metadataURL", 10, price, 1000);
            await transaction.wait();
            alert("successfully upload")
            updateMessage("");
            updateFormParams({ name: "", description: "", price: "" });
            window.location.replace("/");
        } catch (e) {
            alert("error during uplaod", e)
        }
    }
    return (
        <div className="">
            <Navbar></Navbar>
            <div className="flex flex-col place-items-center mt-10" id="nftForm">
                <form className="bg-white shadow-md rounded px-8 pt-4 pb-8 mb-4">
                    <h3 className="text-center font-bold text-purple-500 mb-8">Upload your NFT to the marketplace</h3>
                    <div className="mb-4">
                        <label className="block text-purple-500 text-sm font-bold mb-2" htmlFor="name">NFT Name</label>
                        <input className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline" id="name" type="text" placeholder="Axie#4563" onChange={e => updateFormParams({ ...formParams, name: e.target.value })} value={formParams.name}></input>
                    </div>
                    <div className="mb-6">
                        <label className="block text-purple-500 text-sm font-bold mb-2" htmlFor="description">NFT Description</label>
                        <textarea className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline" cols="40" rows="5" id="description" type="text" placeholder="Axie Infinity Collection" value={formParams.description} onChange={e => updateFormParams({ ...formParams, description: e.target.value })}></textarea>
                    </div>
                    <div className="mb-6">
                        <label className="block text-purple-500 text-sm font-bold mb-2" htmlFor="price">Price (in ETH)</label>
                        <input className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline" type="number" placeholder="Min 0.01 ETH" step="0.01" value={formParams.price} onChange={e => updateFormParams({ ...formParams, price: e.target.value })}></input>
                    </div>
                    <div>
                        <label className="block text-purple-500 text-sm font-bold mb-2" htmlFor="image">Upload Image (&lt;500 KB)</label>
                        <input type={"file"} onChange={OnChangeFile}></input>
                    </div>
                    <br></br>
                    <div className="text-red-500 text-center">{message}</div>
                    <button onClick={listNFT} className="font-bold mt-10 w-full bg-purple-500 text-white rounded p-2 shadow-lg" id="list-button">
                        List NFT
                    </button>
                </form>
            </div>
        </div>
    )
}