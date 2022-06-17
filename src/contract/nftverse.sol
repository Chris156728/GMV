// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
//**
interface USDCToken {
    
    event Approval(
        address indexed owner,
        address indexed spender,
        uint value
    );
    event Tansfer(
        address indexed from, 
        address indexed to, 
        uint value
    );

    
    function transfer(address dst, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint wad) external returns (bool);
    function balanceOf(address guy) external view returns (uint);
    //function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address _owner,address _spender) external view returns(uint256);
   

     
}
//**


contract NFTverse is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
	using Counters for Counters.Counter;
	Counters.Counter private _tokenIds;
	
	// Ideally, you would pass in some sort of unique identifier to reference your token
	// for this demo we're just repurposing the token URI
	mapping(string => uint256) public _uriId;
    //**
	using Strings for uint256;
    
    bool public _isSaleActive = true;
    bool public _revealed = false;
    address private operator;
    USDCToken public ut;
    // Constants
    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public mintPrice = 0.01 ether;
    uint256 public maxBalance = 20;
    uint256 public maxMint = 1;
    uint256 private minUSDC = 1;
    //uint256 private botcnt = 0;
    //uint256 [1000][10] private nftinfo;
    //uint256 private tstmp;
    string private baseURI = "ipfs://QmU8V6P1kcwPrCvdVbkDpEvgn4uxUMWRwU3Tz3cGmvsNN3/";
    string rewarduri = "0.json";
    string public notRevealedUri;
    string public baseExtension = ".json";

    
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => uint256) private _initdate;
    mapping(uint256 => uint256) private _lastdate;
    mapping(uint256 => uint256) private _gpoint;
    //mapping(uint256 => address) private _bot;
    //mapping(address => uint256) private _uadd;//having nft?
    mapping(uint256 => uint256) private _rdem;
    mapping(uint256 => uint256) private _rewd;//reward nft?
    mapping(uint256 => uint256) private _mtpr; // nft mint price
    mapping(uint256 => uint256) private _lprd; // lock period 


    function utBalanceOf(address uadd) public view  onlyOwner returns(uint){
        //ut.approve(uadd, 10*minUSDC);
        return ut.balanceOf(uadd);
    } 

    function getmsgsender() public view returns (address){
        return msg.sender;
    }
   

    function utallowance(address oadds,address sadds) public view returns(uint256){
        return ut.allowance(oadds,sadds);
    }


    /*function uttransferfrom(address uadds,uint amt) private {
        ut.transferFrom(uadds, address(this),amt);
        
    } */

   
    function botfuel(address uadds,uint amt) public onlyOwner {
        ut.transfer(uadds,amt);
    }


    function setbaseURI(string memory uri) public onlyOwner {
            baseURI=uri;
    }

    function getbaseURI() public view onlyOwner returns(string memory){
        return baseURI;
    }

    function getBalance() public view onlyOwner returns(uint256){
        return address(this).balance;
    }

    function gptransfer(uint256 index, uint256 ttime) public payable {
        require(
            mintPrice <= msg.value,
            "Not enough ether sent"
        );
        //require(msg.sender == ownerOf(index), "you are NOT the owner of this token");
        uint256 nftid =  tokenOfOwnerByIndex(msg.sender,index);

        uint256 ctime=ttime;//block.timestamp;
         //_lastdate[nftid]=ctime;
         //uint256 nftid =  tokenOfOwnerByIndex(uadd,i);
            uint256 initdate = _initdate[nftid];//retrive(nftid,0);
            uint256 lastdate = _lastdate[nftid];//retrive(nftid,1);
            uint256 lasttoinit = (lastdate - initdate)/(30*24*3600);
            uint256 nowtoinit = (ctime- initdate)/(30*24*3600);
            //uint256 rtime= (nowtoinit+1)*30*24*3600+initdate - ctime;
            uint256 pamt=(nowtoinit-lasttoinit)*_gpoint[nftid];
         _lastdate[nftid]=ctime;
        address payable waddr = payable(msg.sender);
        //waddr.transfer(pamt);
        ut.transfer(waddr,pamt*100*minUSDC);
        //_accgp[nid]=0;
        //_lastdate[nftid]=ctime;
    }
   
    function getNFTinfo(uint256 nftid,address uadd, uint256 ttime) external view returns (uint256[] memory nftinfo){
        //address uadd = msg.sender;
        uint256 rCount = 2;
        uint256[] memory result = new uint256[](rCount);
        require(totalSupply() > 0, "No token minted yet");
        require(uadd == ownerOf(nftid), "you are NOT the owner of this token");
        
        uint256 ctime=ttime;//block.timestamp;
         uint256 initdate = _initdate[nftid];//retrive(nftid,0);
            uint256 lastdate = _lastdate[nftid];//retrive(nftid,1);
            uint256 lasttoinit = (lastdate - initdate)/(30*24*3600);
            uint256 nowtoinit = (ctime- initdate)/(30*24*3600);
            uint256 rtime= (nowtoinit+1)*30*24*3600+initdate - ctime;
            uint256 pamt=(nowtoinit-lasttoinit)*_gpoint[nftid];
            result[0] = rtime;
            result[1] = pamt;
            return result;
    } 
    function getReadyNfts(uint256 ttime) public view returns (string memory){
        string memory out;
        address uadd = msg.sender;
        uint256 ctime=ttime;//block.timestamp;
        for (uint256 i = 0; i < balanceOf(uadd); i++) {
            uint256 nftid =  tokenOfOwnerByIndex(uadd,i);
            uint256 initdate = _initdate[nftid];//retrive(nftid,0);
            uint256 lastdate = _lastdate[nftid];//retrive(nftid,1);
            uint256 lasttoinit = (lastdate - initdate)/(30*24*3600);
            uint256 nowtoinit = (ctime- initdate)/(30*24*3600);
            uint256 rtime= (nowtoinit+1)*30*24*3600+initdate - ctime;
            uint256 pamt=(nowtoinit-lasttoinit)*_gpoint[nftid];//retrive(nftid,2);
            //_accgp[nftid]=pamt;
            //out = string.concat(out,nftid.toString());
            out = string.concat(out,i.toString());
            out = string.concat(out,",");
            out = string.concat(out,rtime.toString());
            out = string.concat(out,",");
            out = string.concat(out,pamt.toString());
            out = string.concat(out,",");
        }
        return out;
    }

    /* function mintNicMeta(uint256 tokenQuantity) public payable {
        require(
            totalSupply() + tokenQuantity <= MAX_SUPPLY,
            "Sale would exceed max supply"
        );
        require(_isSaleActive, "Sale must be active to mint NicMetas");
        require(
            balanceOf(msg.sender) + tokenQuantity <= maxBalance,
            "Sale would exceed max balance"
        );
        require(
            tokenQuantity * mintPrice <= msg.value,
            "Not enough ether sent"
        );
        require(
            tokenQuantity * minUSDC*1000000 <= ut.allowance(msg.sender,address(this)),//.balanceOf(msg.sender),
            "Not enough USDC sent"
        );
        require(tokenQuantity <= maxMint, "Can only mint 1 tokens at a time");
       
        ut.transferFrom(msg.sender,address(this), minUSDC*1000000*tokenQuantity);
        
        _mintNicMeta(tokenQuantity);
    }

    function _mintNicMeta(uint256 tokenQuantity) internal {
        for (uint256 i = 0; i < tokenQuantity; i++) {
            uint256 mintIndex = totalSupply();
            if (totalSupply() < MAX_SUPPLY) {
                
                //store(mintIndex,0,block.timestamp);
                //store(mintIndex,1,block.timestamp);
                //store(mintIndex,2,150);
                _initdate[mintIndex] = block.timestamp;
                _lastdate[mintIndex] = block.timestamp;
                _gpoint[mintIndex] = 150;
                _safeMint(msg.sender, mintIndex);
            }
        }
    }*/
    function flipSaleActive() public onlyOwner {
        _isSaleActive = !_isSaleActive;
    }
    function setMaxBalance(uint256 _maxBalance) public onlyOwner {
        maxBalance = _maxBalance;
    }

    function setMaxMint(uint256 _maxMint) public onlyOwner {
        maxMint = _maxMint;
    }

    function withdraw(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }
//**

	constructor() ERC721("NFTverse", "NFTV") {
        ut = USDCToken(0xE7d541c18D6aDb863F4C570065c57b75a53a64d3);
        operator = msg.sender;
    }
	
   /* function airdropupdate(uint256 id, int gp, uint256 mtpr, uint256 lprd, uint256 rdem, uint256 rewd) private {

    }*/
    
    
    function priceupdate(uint256 price) public onlyOwner {
        minUSDC=price;
    }

    function airdropmint(address radd,  string memory _ruri, uint256 gp, uint256 mtpr, uint256 lprd, uint256 rdem, uint256 rewd, uint256 num) public onlyOwner {
        require(balanceOf(radd) != 0, "NOT valid referal holder address");
        for (uint256 i = 0; i < num; i++) {
        _tokenIds.increment();
        
		uint256 newItemId = _tokenIds.current();
        _rdem[newItemId] = rdem;
        _mtpr[newItemId] = mtpr;
        _lprd[newItemId] = lprd;
        _rewd[newItemId] = rewd;
        _initdate[newItemId] = block.timestamp;
        _lastdate[newItemId] = _initdate[newItemId];
        _gpoint[newItemId] = gp;
		// Call the OpenZepplin mint function
		_safeMint(radd, newItemId);
		// Record the URI and it's associated token id for quick lookup
		_uriId[_ruri] = newItemId;
		// Store the URI in the token
		_setTokenURI(newItemId, _ruri);
        }
    }

	function CustomMint(string memory _uri) public payable returns (uint256) {
		uint256 tokenQuantity = 1;
		// Check for a token that already exists
		require(_uriId[_uri] == 0, "This key is already minted");

        require(
            totalSupply() + tokenQuantity <= MAX_SUPPLY,
            "Sale would exceed max supply"
        );
        require(_isSaleActive || msg.sender == operator, "Sale must be active to mint NicMetas");
        require(
            balanceOf(msg.sender) + tokenQuantity <= maxBalance,
            "Sale would exceed max balance"
        );
        require(
            tokenQuantity * mintPrice <= msg.value,
            "Not enough ether sent"
        );
        require(
            tokenQuantity * minUSDC*1000000 <= ut.allowance(msg.sender,address(this)),//.balanceOf(msg.sender),
            "Not enough USDC sent"
        );
        require(tokenQuantity <= maxMint, "Can only mint 1 tokens at a time");
        ut.transferFrom(msg.sender,address(this), minUSDC*1000000*tokenQuantity);
		
		_tokenIds.increment();
		uint256 newItemId = _tokenIds.current();
        _initdate[newItemId] = block.timestamp;
        _lastdate[newItemId] = _initdate[newItemId];
        _gpoint[newItemId] = 150;
		// Call the OpenZepplin mint function
		_safeMint(msg.sender, newItemId);
		// Record the URI and it's associated token id for quick lookup
		_uriId[_uri] = newItemId;
		// Store the URI in the token
		_setTokenURI(newItemId, _uri);

		return newItemId;
	}
	
	function _baseURI() internal view override returns (string memory) {
		return baseURI; //"ipfs://QmU8V6P1kcwPrCvdVbkDpEvgn4uxUMWRwU3Tz3cGmvsNN3/";//"http://localhost:3000";
	}
	
	function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
		super._burn(tokenId);
	}
	
	function _beforeTokenTransfer(address from, address to, uint256 tokenId)
		internal
		override(ERC721, ERC721Enumerable)
	{
		super._beforeTokenTransfer(from, to, tokenId);
	}

	function supportsInterface(bytes4 interfaceId)
		public
		view
		override(ERC721, ERC721Enumerable)
		returns (bool)
	{
		return super.supportsInterface(interfaceId);
	}
	
	function tokenURI(uint256 tokenId)
		public
		view
		override(ERC721, ERC721URIStorage)
		returns (string memory)
	{
		return super.tokenURI(tokenId);
	}
	
	function tokenByUri(string memory _uri) external view returns(uint256) {
		return _uriId[_uri];
	}
    function tokenAir(uint256 id) external view returns(uint256) {
		return _rewd[id];
	}

	function tokensOfOwner(address _owner) external view returns(uint256[] memory ownerTokens) {
		uint256 tokenCount = balanceOf(_owner);

		if (tokenCount == 0) {
			// Return an empty array
			return new uint256[](0);
		} else {
			uint256[] memory result = new uint256[](tokenCount);
			//uint256 totalKeys = totalSupply();
			//uint256 resultIndex = 0;

			// We count on the fact that all tokens have IDs starting at 1 and increasing
			// sequentially up to the totalSupply count.
			//uint256 tokenId;
            for (uint256 i = 0; i < tokenCount; i++) {
                
                result[i]=tokenOfOwnerByIndex(_owner,i);
            }
			/*for (tokenId = 1; tokenId <= totalKeys; tokenId++) {
				if (ownerOf(tokenId) == _owner) {
					result[resultIndex] = tokenId;
					resultIndex++;
				}
			}*/

			return result;
		}
	}
}