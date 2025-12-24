// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { ERC2981 } from "@openzeppelin/contracts/token/common/ERC2981.sol";

contract NeuroSymbOracles is ERC721, Ownable, ERC2981 {
    using Counters for Counters.Counter;
    using Strings for uint256;

    /*//////////////////////////////////////////////////////////////
                                CONFIG
    //////////////////////////////////////////////////////////////*/

    uint256 public constant MAX_SUPPLY = 1000;
    uint8 public constant EVOLUTION_THRESHOLD = 5;

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    Counters.Counter private _tokenIdCounter;

    string public initialBaseURI;
    string public evolvedBaseURI;

    mapping(uint256 => uint8) public transferCount;
    mapping(uint256 => bool) public evolved;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event Minted(uint256 indexed tokenId, address to);
    event MetadataEvolved(uint256 indexed tokenId);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory _initialBaseURI)
        ERC721("NeuroSymb Oracles", "NSO")
        Ownable(msg.sender)
    {
        initialBaseURI = _initialBaseURI;
        _setDefaultRoyalty(msg.sender, 1000); 
    }

    /*//////////////////////////////////////////////////////////////
                                  MINT
    //////////////////////////////////////////////////////////////*/

    function mint(address to) public onlyOwner returns (uint256) {
        require(_tokenIdCounter.current() < MAX_SUPPLY, "Max supply reached");

        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();

        _safeMint(to, tokenId);
        emit Minted(tokenId, to);

        return tokenId;
    }

    function batchMint(address to, uint256 amount) public onlyOwner {
        for (uint256 i = 0; i < amount; i++) {
            mint(to);
        }
    }

    /*//////////////////////////////////////////////////////////////
                              TRANSFERS
    //////////////////////////////////////////////////////////////*/

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override returns (address from) {
        from = super._update(to, tokenId, auth);

        // Ignore mint & burn
        if (from == address(0) || to == address(0)) {
            return from;
        }

        unchecked {
            transferCount[tokenId]++;
        }

        if (
            !evolved[tokenId] &&
            transferCount[tokenId] >= EVOLUTION_THRESHOLD &&
            bytes(evolvedBaseURI).length > 0
        ) {
            evolved[tokenId] = true;
            emit MetadataEvolved(tokenId);
        }

        return from;
    }

    /*//////////////////////////////////////////////////////////////
                              METADATA
    //////////////////////////////////////////////////////////////*/

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        _requireOwned(tokenId);

        string memory base = evolved[tokenId]
            ? evolvedBaseURI
            : initialBaseURI;

        return string.concat(base, tokenId.toString(), ".json");
    }

    /*//////////////////////////////////////////////////////////////
                                ADMIN
    //////////////////////////////////////////////////////////////*/

    function setInitialBaseURI(string memory newURI) public onlyOwner {
        initialBaseURI = newURI;
    }

    function setEvolvedBaseURI(string memory newURI) public onlyOwner {
        evolvedBaseURI = newURI;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC-2981
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
