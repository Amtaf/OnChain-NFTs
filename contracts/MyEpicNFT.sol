// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// We need to import the helper functions from the contract that we copy/pasted.
import {Base64} from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    //Counters.Counter public _tokenIdd;

    string svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
        string svgPartTwo= "' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string[] firstWords = [
        "Humungous",
        "Clean",
        "Generous",
        "Mysterious",
        "Wonderful",
        "Creepy"
    ];
    string[] secondWords = [
        "Blue",
        "Pale",
        "Spiral",
        "Sharp",
        "Round",
        "Yellow"
    ];
    string[] thirdWords = ["Whale", "Steak", "Bat", "Bike", "Fire", "House"];
    // Get fancy with it! Declare a bunch of colors.
    string[] colors = ["red", "#08C2A8", "black", "yellow", "blue", "green"];

    event newEpicNFTMinted(address sender, uint256 tokenId);

    constructor() ERC721("SquareNFT", "SQUARE") {
        console.log("Woah this is my NFT");
    }

    // I create a function to randomly pick a word from each array.
    function pickRandomFirstWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        // I seed the random generator. More on this in the lesson.
        uint256 rand = random(
            string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId)))
        );
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId)))
        );
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId)))
        );
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    // Same old stuff, pick a random color.
    function pickRandomColor(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("COLOR", Strings.toString(tokenId)))
        );
        rand = rand % colors.length;
        return colors[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function totalMintedSoFar() public view returns (uint256) {
        return _tokenIds.current();
    }

    function makeAnEpicNFT() public {
        // We go and randomly grab one word from each of the three arrays.
        uint256 newItemId = _tokenIds.current();
        require(
            newItemId < 50,
            "50 NFTs have already been minted try again later"
        );

        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combinedWord = string(
            abi.encodePacked(first, second, third)
        );

        // Add the random color in.
        string memory randomColor = pickRandomColor(newItemId);
        // I concatenate it all together, and then close the <text> and <svg> tags.
        string memory finalSvg = string(
            abi.encodePacked(
                svgPartOne,
                randomColor,
                svgPartTwo, 
                combinedWord,
                "</text></svg>"
            )
        );

        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");

        _safeMint(msg.sender, newItemId);

        // We'll be setting the tokenURI later!
        _setTokenURI(newItemId, finalTokenUri);
        _tokenIds.increment();
        console.log(
            "An NFT w/ ID %s has been minted to %s",
            newItemId,
            msg.sender
        );

        emit newEpicNFTMinted(msg.sender, newItemId);
    }
}
