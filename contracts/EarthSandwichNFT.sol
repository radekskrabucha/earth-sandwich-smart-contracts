// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@lukso/lsp-smart-contracts/contracts/LSP8IdentifiableDigitalAsset/LSP8IdentifiableDigitalAsset.sol";

contract EarthSandwichNFT is LSP8IdentifiableDigitalAsset {
  struct Participant {
    bool hasAccepted;
    string metadataIPFSHash; // Metadata stored on IPFS
  }

  struct Sandwich {
    string name;
    address owner;
    mapping(address => Participant) participants;
    bool isFinalized;
    bytes32[] participantAddresses;
  }

  mapping(bytes32 => Sandwich) public sandwiches;
  mapping(address => bytes32[]) public ownedSandwiches;
  mapping(address => bytes32[]) public participatedSandwiches;
  mapping(bytes32 => address[]) private sandwichParticipantsList;

  // Constructor and other functions will be added here...
  constructor(
    string memory name,
    string memory symbol,
    address newOwner
  ) LSP8IdentifiableDigitalAsset(name, symbol, newOwner, 2) {
    // Additional constructor logic if needed
  }

  // Function to initiate a sandwich
  function initiateSandwich(
    string memory name,
    bytes32 sandwichId,
    address[] memory participantAddresses
  ) public {
    require(
      sandwiches[sandwichId].owner == address(0),
      "Sandwich already exists"
    );

    Sandwich storage sandwich = sandwiches[sandwichId];
    sandwich.name = name;
    sandwich.owner = msg.sender;
    sandwich.isFinalized = false;

    for (uint i = 0; i < participantAddresses.length; i++) {
      sandwich.participants[participantAddresses[i]] = Participant(false, "");
    }

    sandwichParticipantsList[sandwichId] = participantAddresses;
    ownedSandwiches[msg.sender].push(sandwichId);
  }

  // Function for participants to accept an invitation
  function acceptInvitation(
    bytes32 sandwichId,
    string memory metadataIPFSHash
  ) public {
    require(
      sandwiches[sandwichId].owner != address(0),
      "Sandwich does not exist"
    );
    require(
      isParticipant(sandwichId, msg.sender),
      "Not a participant of this sandwich"
    );

    Participant storage participant = sandwiches[sandwichId].participants[
      msg.sender
    ];
    participant.hasAccepted = true;
    participant.metadataIPFSHash = metadataIPFSHash;

    // Add the participant's address to their list of participated sandwiches
    participatedSandwiches[msg.sender].push(sandwichId);
  }

  // Helper function to check if an address is a participant of the sandwich
  function isParticipant(
    bytes32 sandwichId,
    address user
  ) private view returns (bool) {
    address[] memory participants = sandwichParticipantsList[sandwichId];
    for (uint i = 0; i < participants.length; i++) {
      if (participants[i] == user) {
        return true;
      }
    }
    return false;
  }

  // Function to finalize the sandwich and mint the NFT
  function finalizeAndMint(
    bytes32 sandwichId,
    string memory finalMetadataIPFSHash
  ) public {
    Sandwich storage sandwich = sandwiches[sandwichId];

    require(
      msg.sender == sandwich.owner,
      "Only the owner can finalize and mint"
    );
    require(!sandwich.isFinalized, "Sandwich is already finalized");

    // Check if all participants have accepted
    for (uint i = 0; i < sandwichParticipantsList[sandwichId].length; i++) {
      address participantAddress = sandwichParticipantsList[sandwichId][i];
      require(
        sandwich.participants[participantAddress].hasAccepted,
        "Not all participants have accepted"
      );
    }

    // Mint the NFT
    bytes32 tokenId = keccak256(
      abi.encodePacked(sandwichId, msg.sender, block.timestamp)
    );
    _mint(msg.sender, tokenId, false, "");
    _setData(keccak256("LSP4TokenURI"), bytes(finalMetadataIPFSHash));

    sandwich.isFinalized = true;
  }

  // Function to get sandwiches initiated by a user
  function getOwnedSandwiches(
    address user
  ) public view returns (bytes32[] memory) {
    return ownedSandwiches[user];
  }

  // Function to get sandwiches where the user is a participant
  function getParticipatedSandwiches(
    address user
  ) public view returns (bytes32[] memory) {
    return participatedSandwiches[user];
  }

  // Function to get detailed information about a sandwich
  function getSandwichDetails(
    bytes32 sandwichId
  )
    public
    view
    returns (
      string memory name,
      address owner,
      bool isFinalized,
      address[] memory participantAddresses,
      string[] memory participantMetadata
    )
  {
    Sandwich storage sandwich = sandwiches[sandwichId];
    participantAddresses = sandwichParticipantsList[sandwichId];
    participantMetadata = new string[](participantAddresses.length);

    for (uint i = 0; i < participantAddresses.length; i++) {
      participantMetadata[i] = sandwich
        .participants[participantAddresses[i]]
        .metadataIPFSHash;
    }

    return (
      sandwich.name,
      sandwich.owner,
      sandwich.isFinalized,
      participantAddresses,
      participantMetadata
    );
  }
}
