# RoboNet Smart Contracts

On-chain episode registry for robot skill sharing on Base.

## EpisodeRegistry

Robots record learned skills (episodes) on-chain, enabling verifiable skill sharing and reputation building.

### Features
- Record episodes with task metadata (name, category, success rate, HF repo link)
- On-chain upvoting (one vote per address per episode)
- Query episodes by robot address
- Fully compatible with ERC-8004 agent identities

### Build & Test

```bash
cd contracts
forge build
forge test -vv
```

### Deploy to Base Sepolia

```bash
export PRIVATE_KEY=0x...
forge script script/Deploy.s.sol --rpc-url https://sepolia.base.org --broadcast --verify
```

### Contract Interface

```solidity
// Record a skill episode
function recordEpisode(
    string robotId,
    string taskName,
    string taskCategory,
    bool success,
    uint16 completionRate,  // basis points (10000 = 100%)
    string hfRepo,
    string metadataURI
) returns (uint256 episodeId)

// Upvote an episode
function upvote(uint256 episodeId)

// Query
function getEpisode(uint256 episodeId) returns (Episode)
function getRobotEpisodes(address robot) returns (uint256[])
function getEpisodeCount() returns (uint256)
```
