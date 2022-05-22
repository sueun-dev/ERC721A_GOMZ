// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "https://github.com/sueun-dev/ERC721A_GOMZ/blob/main/contracts/ERC721A.sol";
import "https://github.com/sueun-dev/ERC721_GOMZ/blob/master/contracts/access/Ownable.sol";

contract GomzV1 is ERC721A, Ownable {
    uint256 MAX_MINTS = 3;
    uint256 public MAX_SUPPLY = 2022;
    uint256 public PRICE_PER_ETH = 0.0002 ether;
    uint256 public WL_PRICE_PER_ETH = 0.0001 ether;

    mapping(address => bool) public whitelisted;
    uint256 public numWhitelisted;
    uint16 WL_MAX_SUPPLY = 1200;

    string private _baseTokenURI;
    string public notRevealedUri;

    uint256 public constant maxPurchase = 3;

    bool public isSale = false;
    bool public WLisSale = false;
    bool public revealed = false;

    constructor(string memory baseTokenURI, string memory _initNotRevealedUri) ERC721A("Gomz_NFT", "GOMZ") {
        _baseTokenURI = baseTokenURI;
        setNotRevealedURI(_initNotRevealedUri);
    }

    function mintByETH(uint256 quantity) external payable {
        require(isSale, "Not Start");
        require(quantity + _numberMinted(msg.sender) <= MAX_MINTS, "Exceeded the limit");
        require(totalSupply() + quantity <= MAX_SUPPLY, "Not enough tokens left");
        require(msg.value >= (PRICE_PER_ETH * quantity), "Not enough ether sent");
        _safeMint(msg.sender, quantity);
    }

    function WLmintByETH(uint256 quantity) external payable {
        require(WLisSale, "Not Start");
        require(whitelisted[msg.sender] == true, "You are not white list");
        require(quantity + _numberMinted(msg.sender) <= MAX_MINTS, "Exceeded the limit");
        require(totalSupply() + quantity <= WL_MAX_SUPPLY, "Not enough tokens left");
        require(msg.value >= (WL_PRICE_PER_ETH * quantity), "Not enough ether sent");
        _safeMint(msg.sender, quantity);
    }

    function developerPreMint(uint256 quantity) external payable {
        require(!isSale, "Not Start");
        require(quantity + _numberMinted(msg.sender) <= 600, "Exceeded the limit"); // 600개까지 딱 가지고있을수있음
        require(totalSupply() + quantity <= 600, "Not enough tokens left"); // 토큰 600개 제한
        _safeMint(msg.sender, quantity);
    }

    function withdraw() external payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function reveal() public onlyOwner {
        revealed = true;
    }

    function getBaseURI() public view returns (string memory) {
        return _baseURI();
    }

    function _baseURI() internal view virtual override returns (string memory) {

        if(revealed) { 
            return notRevealedUri; 
        }

        return _baseTokenURI;
    }

    function setSale() public onlyOwner {
        isSale = !isSale;
    }

    function WLsetSale() public onlyOwner {
        WLisSale = !WLisSale;
    }

    function publicSale() public onlyOwner{
        PRICE_PER_ETH = 0.0002 ether;
    }

    function WLpublicSale() public onlyOwner { 
        WL_PRICE_PER_ETH = 0.0001 ether;
    }

    function getWLpublicSale() public view returns (uint256) {
        return WL_PRICE_PER_ETH;
    }

    function getpublicSale() public view returns (uint256) {
        return PRICE_PER_ETH;
    }

    function increasePrice() public onlyOwner {
        PRICE_PER_ETH += 0.2 ether;
    }

    function addWhitelist(address[] memory _users) public onlyOwner {
        uint size = _users.length;
       
        for (uint256 i=0; i< size; i++){
            address user = _users[i];
            whitelisted[user] = true;
        }

        numWhitelisted += _users.length;
    }

    function removeWhitelist(address[] memory _users) public onlyOwner {
        uint size = _users.length;
        
        for (uint256 i=0; i< size; i++){
            address user = _users[i];
            whitelisted[user] = false;
        }
    }

}
