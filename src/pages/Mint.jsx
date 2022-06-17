import React, { useState } from 'react';
import usdc from "./usdc";

// IMPORTANT NOTE: In this example, the URI is used as a unique key to identify
// a token associated with an asset. This is fine for demonstration, but in a 
// production project you should have a unique key associated with the asset
// and store that in the contract along with the URI.
export default function Mint(props) {
	let imgbase = 'https://ipfs.io/ipfs/QmVaaDwixStwnwrYFaQ4hNf9LVfKiHwFZ7A2bWS8KFccA2/';
	const [assetURIs, setAssetURIs] = useState([]);
	
	// Populate the assetURIs variable with tokens that are not yet minted.
	const CheckAssetURIs = async () => {
		let uris = [];
		
		// For this demo there are only 4 assets, named sequentially. 
		for(let idx = 1; idx <= 9; idx++ ){
			let base ='';// 'ipfs://QmU8V6P1kcwPrCvdVbkDpEvgn4uxUMWRwU3Tz3cGmvsNN3/';
			let ext = idx+'.json';//'/token_data/exobit_'+idx+'.json';
			let uri= base+ext;
			// Call the contract and get the id of the uri. If the uri doesn't belong to a token, it will return 0.
			let tokenId = await props.contract.methods.tokenByUri(uri).call();
			// The token ID comes in as a string. "0" means that uri is not associated with a token.
			if(tokenId === "0") uris.push(uri);
		}

		// Update the list of available asset URIs
		if(uris.length) setAssetURIs([...uris]);
	}

	// Handle the click to mint
	const DoMint = async (tokenURI) => {
		const contractAddress = "0x7a7b4757543987dD07936D473Ead236ebcdc4999";
		const nAddress = "0x0000000000000000000000000000000000000000";
		console.log('minting: ', tokenURI);
		try{
			// Estimate the gas required for the transaction
			//console.log('caddress', contractAddress, 'waddress', props.address);
			
			let uresult = await usdc.methods.approve(contractAddress, 1000001).send({ from: props.address })
			//console.log('uresult', uresult);
			let gasLimit = await props.contract.methods.CustomMint(tokenURI,nAddress,0,0).estimateGas(
				{ 
					from: props.address, 
					value: 10000000000000000
				}
			);
			// Call the mint function.
			
			let result = await props.contract.methods.CustomMint(tokenURI,nAddress,0,0)
				.send({ 
					from: props.address, 
					value: 10000000000000000,
					// Setting the gasLimit with the estimate accuired above helps ensure accurate estimates in the wallet transaction.
					gasLimit: gasLimit
				});

			// Output the result for the console during development. This will help with debugging transaction errors.
			console.log('result', result);

			// Refresh the gallery
			CheckAssetURIs();

		}catch(e){
			console.error('There was a problem while minting', e);
		}
	};

	// Handle contract unavailable. 
	// This is an extra precaution since the user shouldn't be able to get to this page without connecting.
	if(!props.contract) return (<div className="page error">Contract Not Available</div>);

	// Set up the list of available token URIs when the component mounts.
	if(!assetURIs.length) CheckAssetURIs();

	// Display the minting gallery
	return (
		<div className="page mint">
			<h2>Click on an image to mint a token</h2>
			{assetURIs.map((uri, idx) => (
					<div onClick={() => DoMint(uri)} key={idx}>
						<img src={(imgbase)+uri.replace('.json', '.png')} alt={''+(idx+1)} />
					</div>
				)
			)}
		</div>
	);
}