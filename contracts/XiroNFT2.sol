// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract XiroNFT2 is Initializable, ERC721Upgradeable, OwnableUpgradeable, UUPSUpgradeable {

    using StringsUpgradeable for uint256;

    uint public constant MAX_SUPPLY = 10;
    uint public price;
    uint public tokenId;
    mapping(uint => bool) public onSale;
    mapping(uint => uint) public salePrice;
    string _baseUri;
    string _contractUri;

    
    function initialize() public initializer {
        __ERC721_init(
            "Xiro", "XIRO"
        );
        __Ownable_init();
        __UUPSUpgradeable_init();
        _contractUri = "ipfs://QmNLzE11Kz5XfztRVh1woS4bG61x7MFkB25CKFSStu6nAZ/0.json";
        price = 0.01 ether;
    }

    event MsgVal(uint val);
    event NftListed(uint tokenId, uint salePrice);

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId), "URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _tokenId.toString(),".json")) : '';
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseUri;
    }

    function mint() public payable {
        require(msg.value >= price, "Ether sent is not sufficient.");
        require(tokenId < MAX_SUPPLY, "Sold out!");
        _safeMint(msg.sender, tokenId);
        tokenId++;
         _safeMint(msg.sender, tokenId);
        tokenId++;
        emit MsgVal(msg.value);
    }

    function listNFT(uint _tokenId, uint _salePrice) public {
        require(ownerOf(_tokenId) == msg.sender);
        require(onSale[_tokenId] == false, "The NFT is already listed.");
        require(_salePrice > 0, "Sale price can't be 0.");
        salePrice[_tokenId] = _salePrice;
        onSale[_tokenId] = true;
        setApprovalForAll(address(this), true);
        emit NftListed(_tokenId, _salePrice);
    }

    function delistNFT(uint _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender);
        require(onSale[_tokenId] == true, "The NFT isn't listed.");
        onSale[_tokenId] = false;
        salePrice[_tokenId] = 0;
    }

    function buyNFT(uint _tokenId) public payable {
        require(ownerOf(_tokenId) != msg.sender, "You already own this NFT.");
        require(onSale[_tokenId] == true, "The NFT isn't listed.");
        require(msg.value >= salePrice[_tokenId], "Amount paid can't be less than price.");
        onSale[_tokenId] = false;
        address nftOwner = ownerOf(_tokenId);
        IERC721Upgradeable(address(this)).safeTransferFrom(nftOwner, msg.sender, _tokenId);
        onSale[_tokenId] = false;
        salePrice[_tokenId] = 0;
    }

    function contractURI() public view returns (string memory) {
        return _contractUri;
    }
    
    function setBaseURI(string memory newBaseURI) external onlyOwner {
        _baseUri = newBaseURI;
    }
    
    function setContractURI(string memory newContractURI) external onlyOwner {
        _contractUri = newContractURI;
    }

    function setPrice(uint newPrice) external onlyOwner {
        price = newPrice;
    }
    
    function withdrawAll() external onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
