// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title EpisodeRegistry — On-chain registry for robot skill episodes
/// @notice Robots record learned skills on-chain for verifiable sharing
contract EpisodeRegistry {
    struct Episode {
        address robot;         // Robot wallet that posted this episode
        string robotId;        // Off-chain robot identifier (e.g. "g1_sim_001")
        string taskName;       // Task name (e.g. "box_stacking")
        string taskCategory;   // Category (e.g. "manipulation/stacking")
        bool success;          // Whether the episode was successful
        uint16 completionRate; // 0-10000 (basis points, e.g. 10000 = 100%)
        string hfRepo;         // HuggingFace dataset repo URL
        string metadataURI;    // IPFS/HTTP URI for full metadata JSON
        uint256 timestamp;     // Block timestamp when recorded
        uint256 upvotes;       // On-chain upvote count
    }

    Episode[] public episodes;
    mapping(address => uint256[]) public robotEpisodes;
    mapping(uint256 => mapping(address => bool)) public hasUpvoted;

    event EpisodeRecorded(
        uint256 indexed episodeId,
        address indexed robot,
        string taskName,
        bool success,
        uint256 timestamp
    );

    event EpisodeUpvoted(
        uint256 indexed episodeId,
        address indexed voter,
        uint256 newUpvoteCount
    );

    /// @notice Record a new skill episode on-chain
    function recordEpisode(
        string calldata robotId,
        string calldata taskName,
        string calldata taskCategory,
        bool success,
        uint16 completionRate,
        string calldata hfRepo,
        string calldata metadataURI
    ) external returns (uint256 episodeId) {
        require(completionRate <= 10000, "completionRate > 100%");
        require(bytes(taskName).length > 0, "taskName required");

        episodeId = episodes.length;
        episodes.push(Episode({
            robot: msg.sender,
            robotId: robotId,
            taskName: taskName,
            taskCategory: taskCategory,
            success: success,
            completionRate: completionRate,
            hfRepo: hfRepo,
            metadataURI: metadataURI,
            timestamp: block.timestamp,
            upvotes: 0
        }));

        robotEpisodes[msg.sender].push(episodeId);

        emit EpisodeRecorded(episodeId, msg.sender, taskName, success, block.timestamp);
    }

    /// @notice Upvote an episode (one vote per address per episode)
    function upvote(uint256 episodeId) external {
        require(episodeId < episodes.length, "Episode not found");
        require(!hasUpvoted[episodeId][msg.sender], "Already upvoted");

        hasUpvoted[episodeId][msg.sender] = true;
        episodes[episodeId].upvotes++;

        emit EpisodeUpvoted(episodeId, msg.sender, episodes[episodeId].upvotes);
    }

    /// @notice Get total number of episodes
    function getEpisodeCount() external view returns (uint256) {
        return episodes.length;
    }

    /// @notice Get all episode IDs for a robot
    function getRobotEpisodes(address robot) external view returns (uint256[] memory) {
        return robotEpisodes[robot];
    }

    /// @notice Get episode details
    function getEpisode(uint256 episodeId) external view returns (Episode memory) {
        require(episodeId < episodes.length, "Episode not found");
        return episodes[episodeId];
    }
}
