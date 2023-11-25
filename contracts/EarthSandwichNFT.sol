// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@lukso/lsp-smart-contracts/contracts/LSP8IdentifiableDigitalAsset/LSP8IdentifiableDigitalAsset.sol";

contract EarthSandwichNFT is LSP8IdentifiableDigitalAsset {
  struct Participant {
    bool hasAccepted;
    string metadataIPFSHash;
  }

  struct Sandwich {
    string name;
    address owner;
    mapping(address => Participant) participants;
    bool isFinalized;
  }

  mapping(bytes32 => Sandwich) public sandwiches;
  mapping(address => bytes32[]) public ownedSandwiches;
  mapping(address => bytes32[]) public participatedSandwiches;
  mapping(bytes32 => address[]) private sandwichParticipantsList;
  mapping(bytes32 => bool) public isSandwichMinted;
  mapping(bytes32 => string) private sandwichMetadataHash;

  constructor(
    address _owner
  ) LSP8IdentifiableDigitalAsset("EarthSandwich", "ESAND", _owner, 2) {}

  function initiateSandwich(
    string memory name,
    address[] memory participantAddresses
  ) public {
    bytes32 sandwichId = keccak256(
      abi.encodePacked(msg.sender, block.timestamp, name)
    );

    require(
      sandwiches[sandwichId].owner == address(0),
      "Sandwich already exists"
    );

    Sandwich storage sandwich = sandwiches[sandwichId];
    sandwich.name = name;
    sandwich.owner = msg.sender;
    sandwich.isFinalized = false;

    for (uint i = 0; i < participantAddresses.length; i++) {
      if (!isParticipant(sandwichId, participantAddresses[i])) {
        sandwich.participants[participantAddresses[i]] = Participant(false, "");
        participatedSandwiches[participantAddresses[i]].push(sandwichId);
      }
    }

    sandwichParticipantsList[sandwichId] = participantAddresses;
    ownedSandwiches[msg.sender].push(sandwichId);
  }

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
    require(!participant.hasAccepted, "Already accepted");

    participant.hasAccepted = true;
    participant.metadataIPFSHash = metadataIPFSHash;
  }

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

  function finalizeAndMint(
    bytes32 sandwichId,
    string memory finalMetadataIPFSHash,
    address to
  ) public {
    Sandwich storage sandwich = sandwiches[sandwichId];

    require(
      msg.sender == sandwich.owner,
      "Only the owner can finalize and mint"
    );
    require(!sandwich.isFinalized, "Sandwich is already finalized");

    for (uint i = 0; i < sandwichParticipantsList[sandwichId].length; i++) {
      address participantAddress = sandwichParticipantsList[sandwichId][i];
      require(
        sandwich.participants[participantAddress].hasAccepted,
        "Not all participants have accepted"
      );
    }

    bytes32 tokenId = keccak256(
      abi.encodePacked(sandwichId, msg.sender, block.timestamp)
    );
    _mint(to, tokenId, false, "");
    _setData(keccak256("LSP4TokenURI"), bytes(finalMetadataIPFSHash));

    isSandwichMinted[sandwichId] = true;
    sandwich.isFinalized = true;
    sandwichMetadataHash[sandwichId] = finalMetadataIPFSHash;
  }

  function getSandwichParticipantDetails(
    bytes32 sandwichId,
    address participant
  ) public view returns (bool hasAccepted, string memory participantMetadata) {
    return (
      sandwiches[sandwichId].participants[participant].hasAccepted,
      sandwiches[sandwichId].participants[participant].metadataIPFSHash
    );
  }

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

  function getSandwichMetadata(
    bytes32 sandwichId
  ) public view returns (string memory) {
    require(isSandwichMinted[sandwichId], "Sandwich has not been minted yet");

    return sandwichMetadataHash[sandwichId];
  }

  function getMintedSandwichesByOwner(
    address owner
  ) public view returns (bytes32[] memory) {
    bytes32[] memory temp = new bytes32[](ownedSandwiches[owner].length);
    uint count = 0;
    for (uint i = 0; i < ownedSandwiches[owner].length; i++) {
      bytes32 sandwichId = ownedSandwiches[owner][i];
      if (isSandwichMinted[sandwichId]) {
        temp[count] = sandwichId;
        count++;
      }
    }
    bytes32[] memory result = new bytes32[](count);
    for (uint i = 0; i < count; i++) {
      result[i] = temp[i];
    }
    return result;
  }

  function getUnmintedSandwichesByOwner(
    address owner
  ) public view returns (bytes32[] memory) {
    bytes32[] memory temp = new bytes32[](ownedSandwiches[owner].length);
    uint count = 0;
    for (uint i = 0; i < ownedSandwiches[owner].length; i++) {
      bytes32 sandwichId = ownedSandwiches[owner][i];
      if (!isSandwichMinted[sandwichId]) {
        temp[count] = sandwichId;
        count++;
      }
    }
    bytes32[] memory result = new bytes32[](count);
    for (uint i = 0; i < count; i++) {
      result[i] = temp[i];
    }
    return result;
  }

  function getUnmintedSandwichesByParticipant(
    address participant
  ) public view returns (bytes32[] memory) {
    bytes32[] memory temp = new bytes32[](
      participatedSandwiches[participant].length
    );
    uint count = 0;
    for (uint i = 0; i < participatedSandwiches[participant].length; i++) {
      bytes32 sandwichId = participatedSandwiches[participant][i];
      if (!isSandwichMinted[sandwichId]) {
        temp[count] = sandwichId;
        count++;
      }
    }
    bytes32[] memory result = new bytes32[](count);
    for (uint i = 0; i < count; i++) {
      result[i] = temp[i];
    }
    return result;
  }

  function getMintedSandwichesWithMetadata(
    address user
  ) public view returns (bytes32[] memory, string[] memory) {
    uint count = 0;
    for (uint i = 0; i < ownedSandwiches[user].length; i++) {
      if (isSandwichMinted[ownedSandwiches[user][i]]) {
        count++;
      }
    }

    bytes32[] memory ids = new bytes32[](count);
    string[] memory metadataHashes = new string[](count);
    uint index = 0;
    for (uint i = 0; i < ownedSandwiches[user].length; i++) {
      bytes32 sandwichId = ownedSandwiches[user][i];
      if (isSandwichMinted[sandwichId]) {
        ids[index] = sandwichId;
        metadataHashes[index] = sandwichMetadataHash[sandwichId];
        index++;
      }
    }

    return (ids, metadataHashes);
  }

  function getMintedSandwichesParticipatedWithMetadata(
    address user
  ) public view returns (bytes32[] memory, string[] memory) {
    uint count = 0;
    for (uint i = 0; i < participatedSandwiches[user].length; i++) {
      if (isSandwichMinted[participatedSandwiches[user][i]]) {
        count++;
      }
    }

    bytes32[] memory ids = new bytes32[](count);
    string[] memory metadataHashes = new string[](count);
    uint index = 0;
    for (uint i = 0; i < participatedSandwiches[user].length; i++) {
      bytes32 sandwichId = participatedSandwiches[user][i];
      if (isSandwichMinted[sandwichId]) {
        ids[index] = sandwichId;
        metadataHashes[index] = sandwichMetadataHash[sandwichId];
        index++;
      }
    }

    return (ids, metadataHashes);
  }
}
