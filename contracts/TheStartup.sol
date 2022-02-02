//SPDX-License-Identifier: MIT
pragma solidity  ^0.8.4;

// TODO: remove me before prod deploy
import "hardhat/console.sol";

contract TheStartup is ERC721, PaymentSplitter, Ownable {
    // Setup

    using Counters for Counters.Counter;
    Counters.Counter private _tokenSupply;

    // Public Properties

    bool public mintEnabled;
    bool public allowListMintEnabled;

    mapping(address => uint) public allowListMintCount;

    bytes32 public merkleRoot;

    // Private Properties

    string private _baseTokenURI;

    uint private price = 0.24 ether;

    address private teamWallet = 0x2d101d940BfB1d5a271D4e69016A159d958d1787;

    // Modifiers

    modifier isNotPaused(bool _enabled) {
        require(_enabled, "Mint paused");
        _;
    }

    // Constructor

    constructor(address[] memory _payees, uint256[] memory _shares) ERC721("The Startup", "FMC") PaymentSplitter(_payees, _shares) {
        _mintCards(teamWallet, 10);
    }

    // Mint Functions

    // Function requires a Merkle proof and will only work if called from the minting site.
    // Allows the allowList minter to come back and mint again if they mint under 3 max mints in the first transaction(s).
    function allowListMint(bytes32[] calldata _merkleProof, uint _amount) external payable isNotPaused(allowListMintEnabled) {
        require((_amount > 0 && _amount < 3), "Wrong amount");
        require(totalSupply() + _amount < 10_001, 'Exceeds max supply');
        require(allowListMintCount[msg.sender] + _amount < 3, "Can only mint 2");
        require(price * _amount == msg.value, "Wrong ETH amount");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), 'Not on the list');

        allowListMintCount[msg.sender] = allowListMintCount[msg.sender] + _amount;

        _mintCards(msg.sender, _amount);
    }

    function mint(uint _amount) external payable isNotPaused(mintEnabled) {
        require((_amount > 0 && _amount < 5), "Wrong amount");
        require(totalSupply() + _amount < 10_001, 'Exceeds max supply');
        require(price * _amount == msg.value, "Wrong ETH amount");

        _mintCards(msg.sender, _amount);
    }

    // Allows the team to mint Cards to a destination address
    function promoMint(address _to, uint _amount) external onlyOwner {
        require(_amount > 0, "Mint 1");
        require(totalSupply() + _amount < 10_001, 'Exceeds max supply');
        _mintCards(_to, _amount);
    }

    function _mintCards(address _to, uint _amount) internal {
        for(uint i = 0; i < _amount; i++) {
            _tokenSupply.increment();
            _safeMint(_to, totalSupply());
        }
    }

    function totalSupply() public view returns (uint) {
        return _tokenSupply.current();
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    // Ownable Functions

    function setMerkleRoot(bytes32 _root) external onlyOwner {
        merkleRoot = _root;
    }

    function setBaseURI(string memory baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function setAllowListMintEnabled(bool _val) external onlyOwner {
        allowListMintEnabled = _val;
    }

    function setMintEnabled(bool _val) external onlyOwner {
        mintEnabled = _val;
    }

    // Important: Set new price in wei (i.e. 24000000000000000 for 0.24 ETH)
    function setPrice(uint _newPrice) external onlyOwner {
        price = _newPrice;
    }

}
