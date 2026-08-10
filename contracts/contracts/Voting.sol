// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SecureVote Voting
 * @notice Anchors SecureVote ballots on Polygon Amoy.
 *
 * Flow:
 *   1. Owner calls `createElection(id, startsAt, endsAt)` when an election is created.
 *   2. When a voter casts a ballot, the backend calls `commitVote(electionId, voteHash)`
 *      where `voteHash` is a SHA-256 of the encrypted receipt payload.
 *   3. When the election closes, the backend calls `finalize(electionId, merkleRoot)`
 *      to anchor the Merkle root of all vote hashes.
 *   4. The `VoteCommitted` and `ElectionFinalized` events are picked up by a
 *      Cloudflare Worker cron listener as a backup audit trail.
 */
contract Voting is Ownable {
    struct Election {
        string id;        // backend UUID
        uint256 startsAt;
        uint256 endsAt;
        bytes32 merkleRoot;
        bool finalized;
    }

    mapping(string => Election) public elections;
    mapping(string => mapping(address => bool)) public hasVoted;
    mapping(string => bytes32[]) public voteHashes;

    event ElectionCreated(string indexed id, uint256 startsAt, uint256 endsAt);
    event VoteCommitted(
        string indexed electionId,
        address indexed voter,
        bytes32 indexed voteHash
    );
    event ElectionFinalized(
        string indexed id,
        bytes32 indexed merkleRoot,
        uint256 voteCount
    );

    error ElectionNotFound();
    error NotInWindow();
    error AlreadyVoted();
    error AlreadyFinalized();
    error BadWindow();

    constructor() Ownable(msg.sender) {}

    function createElection(
        string calldata id,
        uint256 startsAt,
        uint256 endsAt
    ) external onlyOwner {
        if (endsAt <= startsAt) revert BadWindow();
        elections[id] = Election(id, startsAt, endsAt, bytes32(0), false);
        emit ElectionCreated(id, startsAt, endsAt);
    }

    function commitVote(
        string calldata electionId,
        bytes32 voteHash
    ) external {
        Election storage e = elections[electionId];
        if (bytes(e.id).length == 0) revert ElectionNotFound();
        if (e.finalized) revert AlreadyFinalized();
        if (block.timestamp < e.startsAt) revert NotInWindow();
        if (block.timestamp > e.endsAt) revert NotInWindow();
        if (hasVoted[electionId][msg.sender]) revert AlreadyVoted();

        hasVoted[electionId][msg.sender] = true;
        voteHashes[electionId].push(voteHash);
        emit VoteCommitted(electionId, msg.sender, voteHash);
    }

    function finalize(
        string calldata electionId,
        bytes32 merkleRoot
    ) external onlyOwner {
        Election storage e = elections[electionId];
        if (bytes(e.id).length == 0) revert ElectionNotFound();
        e.finalized = true;
        e.merkleRoot = merkleRoot;
        emit ElectionFinalized(electionId, merkleRoot, voteHashes[electionId].length);
    }

    // --- views ---

    function getVoteCount(string calldata electionId) external view returns (uint256) {
        return voteHashes[electionId].length;
    }

    function getVoteHashes(string calldata electionId) external view returns (bytes32[] memory) {
        return voteHashes[electionId];
    }

    function getElection(string calldata id) external view returns (
        string memory, uint256, uint256, bytes32, bool
    ) {
        Election storage e = elections[id];
        return (e.id, e.startsAt, e.endsAt, e.merkleRoot, e.finalized);
    }
}
