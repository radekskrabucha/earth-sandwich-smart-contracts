// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@lukso/lsp-smart-contracts/contracts/LSP8IdentifiableDigitalAsset/LSP8IdentifiableDigitalAsset.sol";

contract EarthSandwichNFT is LSP8IdentifiableDigitalAsset {
  // Structure to represent a sandwich
  struct Sandwich {
    address owner; // The owner (SandwichOwner) of the sandwich
    address[] participants; // List of participants (SandwichParticipants)
    bool isFinalized; // Flag to check if the sandwich is finalized
  }

  // Structure to store participant's data
  struct ParticipantData {
    bool hasAccepted; // Flag to check if the participant has accepted
    string ipfsHash; // IPFS hash for the participant's metadata
  }

  // Mapping from sandwich ID to its details
  mapping(bytes32 => Sandwich) public sandwiches;
  // Mapping from sandwich ID and participant address to their data
  mapping(bytes32 => mapping(address => ParticipantData))
    public sandwichParticipants;
  // Mapping from an owner address to their sandwich IDs
  mapping(address => bytes32[]) public ownerToSandwiches;
  // Mapping from a participant address to their sandwich IDs
  mapping(address => bytes32[]) public participantToSandwiches;

  // Constructor
  constructor(
    string memory name,
    string memory symbol,
    address newOwner
  )
    LSP8IdentifiableDigitalAsset(name, symbol, newOwner, 2) // Using UNIQUE_ID type
  {
    // Additional constructor logic if needed
  }

  // Function to initiate a sandwich and invite participants
  function initiateSandwich(
    address[] memory participants,
    bytes32 sandwichId
  ) public {
    Sandwich storage sandwich = sandwiches[sandwichId];
    sandwich.owner = msg.sender; // Set the initiator as the owner
    sandwich.participants = participants; // Set the invited participants
    sandwich.isFinalized = false; // Mark as not finalized

    ownerToSandwiches[msg.sender].push(sandwichId); // Record sandwich under owner
    for (uint i = 0; i < participants.length; i++) {
      participantToSandwiches[participants[i]].push(sandwichId); // Record sandwich under each participant
    }
  }

  // Function for a participant to accept the invitation
  function acceptInvitation(bytes32 sandwichId, string memory ipfsHash) public {
    require(isParticipant(sandwichId, msg.sender), "Not a participant"); // Ensure sender is a participant

    ParticipantData storage participantData = sandwichParticipants[sandwichId][
      msg.sender
    ];
    participantData.hasAccepted = true; // Mark as accepted
    participantData.ipfsHash = ipfsHash; // Store the IPFS hash
  }

  // Private helper function to check if an address is a participant in a given sandwich
  function isParticipant(
    bytes32 sandwichId,
    address user
  ) private view returns (bool) {
    Sandwich memory sandwich = sandwiches[sandwichId];
    for (uint i = 0; i < sandwich.participants.length; i++) {
      if (sandwich.participants[i] == user) {
        return true; // User is a participant
      }
    }
    return false; // User is not a participant
  }

  // Function to finalize the sandwich and mint the NFT
  function finalizeSandwichAndMintNFT(
    bytes32 sandwichId,
    string memory finalIpfsHash
  ) public {
    Sandwich storage sandwich = sandwiches[sandwichId];

    // Check that the caller is the SandwichOwner
    require(msg.sender == sandwich.owner, "Caller is not the SandwichOwner");

    // Check all participants have accepted
    for (uint i = 0; i < sandwich.participants.length; i++) {
      require(
        sandwichParticipants[sandwichId][sandwich.participants[i]].hasAccepted,
        "Not all participants have accepted"
      );
    }

    // Check the sandwich is not already finalized
    require(!sandwich.isFinalized, "Sandwich already finalized");

    // Mint the NFT with the final metadata IPFS hash
    bytes32 tokenId = keccak256(
      abi.encodePacked(sandwichId, msg.sender, block.timestamp)
    ); // Unique tokenId
    _mint(msg.sender, tokenId, false, ""); // Mint the NFT
    _setData(tokenId, bytes(finalIpfsHash)); // Set the IPFS hash as metadata

    // Update the sandwich status
    sandwich.isFinalized = true;
  }

  // Additional functions for finalizing and minting will go here

  // Additional functions and logic will go here
  // Function to get list of sandwich IDs where the user is the owner
  function getOwnedSandwiches(
    address user
  ) public view returns (bytes32[] memory) {
    return ownerToSandwiches[user];
  }

  // Function to get list of sandwich IDs where the user is a participant
  function getParticipatedSandwiches(
    address user
  ) public view returns (bytes32[] memory) {
    return participantToSandwiches[user];
  }

  // Function to get detailed information about a sandwich
  function getSandwichDetails(
    bytes32 sandwichId
  )
    public
    view
    returns (address owner, address[] memory participants, bool isFinalized)
  {
    Sandwich memory sandwich = sandwiches[sandwichId];
    return (sandwich.owner, sandwich.participants, sandwich.isFinalized);
  }
}
