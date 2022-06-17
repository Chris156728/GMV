import React, {useState} from "react";

export default function MyTokens(props) {

	const [userTokens, setUserTokens] = useState(null);
	const [tokenURIs, setTokenURIs] = useState([]);

	// Populate userTokens with an array of token IDs belonging to the curent wallet address.
	const GetUserTokens = async () => {
		if(!props || !props.contract) return;
		const userTokens = await props.contract.methods.tokensOfOwner(props.address).call();
		setUserTokens(userTokens);
	};

	// Populate the setTokenURIs variable with token URIs belonging to the curent wallet address.
	const GetTokenURIs = async (userTokens) => {
		let uripfx = 'https://ipfs.io/ipfs/';
		if(!userTokens || !userTokens.length) return;
		let tokens = [];
		
		// Taking advantage of the fact that token IDs are an auto-incrementing integer starting with 1.
		// Starting with userTokens and counting down to 1 gives us the tokens in order of most recent.
		for(let id of userTokens){
			try{
				// Get the metadata URI associated with the token
				let tokenURI = await props.contract.methods.tokenURI(id).call();
				// Fetch the json metadata the token points to
				console.log('nftid',id);
				let nftinfo = await props.contract.methods.getNFTinfo(id, props.address, 1661254708).call();
				console.log(nftinfo[0],nftinfo[1]);
				let response = await fetch(uripfx+tokenURI.substring(7));
				let metaData = await response.json();
				// Add the image url if available in the metadata.
				let imguri = uripfx + metaData.image.substring(7);
				if(metaData && metaData.image)
					tokens.push(imguri);//metaData.image);
			}catch(e){
				// Either the contract call or the fetch can fail. You'll want to handle that in production.
				console.error('Error occurred while fetching metadata.')
				continue;
			}
		}

		// Update the list of available asset URIs
		if(tokens.length) setTokenURIs([...tokens]);
	};

	const getGP = async (idx) => {
		//const contractAddress = "0x4C32F7e1cA4F24d936110e17248587b2093F74c4";
		console.log('claim: ', idx);
		try{
			// Estimate the gas required for the transaction
			//console.log('caddress', contractAddress, 'waddress', props.address);
			
			//let uresult = await usdc.methods.approve(contractAddress, 1000001).send({ from: props.address })
			//console.log('uresult', uresult);
			let gasLimit = await props.contract.methods.gptransfer(idx,0,1661254708).estimateGas(
				{ 
					from: props.address, 
					value: 10000000000000000
				}
			);
			// Call the mint function.
			
			let result = await props.contract.methods.gptransfer(idx,0, 1661254708)
				.send({ 
					from: props.address, 
					value: 10000000000000000,
					// Setting the gasLimit with the estimate accuired above helps ensure accurate estimates in the wallet transaction.
					gasLimit: gasLimit
				});

			// Output the result for the console during development. This will help with debugging transaction errors.
			console.log('result', result);

			// Refresh the gallery
			//CheckAssetURIs();
			GetUserTokens();
			GetTokenURIs(userTokens);
		}catch(e){
			console.error('There was a problem while claiming', e);
		}
	};

	// Handle contract unavailable. 
	// This is an extra precaution since the user shouldn't be able to get to this page without connecting.
	if(!props.contract) return (<div className="page error">Contract Not Available</div>);

	// Get all token IDs associated with the wallet address when the component mounts.
	if(!userTokens) GetUserTokens();

	// Set up the list of available token URIs when the component mounts.
	if(userTokens && !tokenURIs.length) GetTokenURIs(userTokens);

	// Display the personal token gallery
	return (
		<div className="page my-tokens">
			<h2>Private Gallery</h2>
			{tokenURIs.map((uri, idx) => (
				<div  onClick={() => getGP(idx)} key={idx}>
					<img src={uri} alt={'token '+idx} />
				</div>
			))}
		</div>
	);
}