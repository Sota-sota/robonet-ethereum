#!/bin/bash
# RoboNet on-chain demo script
# Demonstrates robot agents recording and sharing skills on Base

set -e
export PATH="$HOME/.foundry/bin:$PATH"

RPC_URL="${RPC_URL:-http://localhost:8545}"
REGISTRY="${REGISTRY:-0xE512A824d38D2DB43DB2964e344aa4082616F4f9}"

# Robot wallets (Anvil default accounts)
ROBOT1_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
ROBOT2_KEY="0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d"

echo "========================================="
echo "  RoboNet On-Chain Demo"
echo "  The Social Network for Physical AI Robots"
echo "========================================="
echo ""

echo "📡 Contract: $REGISTRY"
echo "🔗 Network: Base Sepolia (forked)"
echo ""

# 1. Robot G1 records a successful box stacking episode
echo "🤖 Robot G1 recording episode: box_stacking (SUCCESS, 100%)"
cast send --private-key $ROBOT1_KEY --rpc-url $RPC_URL \
  $REGISTRY \
  "recordEpisode(string,string,string,bool,uint16,string,string)" \
  "g1_sim_001" "box_stacking" "manipulation/stacking" true 10000 \
  "https://huggingface.co/datasets/orboh/box-stacking-001" \
  "ipfs://QmRoboNetEpisode001" \
  --json | python3 -c "import json,sys; d=json.load(sys.stdin); print(f'  ✅ TX: {d[\"transactionHash\"]}')"

echo ""

# 2. Robot G1 records a failed walking episode
echo "🤖 Robot G1 recording episode: walk_forward (FAILED, 30%)"
cast send --private-key $ROBOT1_KEY --rpc-url $RPC_URL \
  $REGISTRY \
  "recordEpisode(string,string,string,bool,uint16,string,string)" \
  "g1_sim_001" "walk_forward" "locomotion/walking" false 3000 \
  "" "" \
  --json | python3 -c "import json,sys; d=json.load(sys.stdin); print(f'  ✅ TX: {d[\"transactionHash\"]}')"

echo ""

# 3. Robot SO-ARM records a pick-and-place episode
echo "🦾 Robot SO-ARM recording episode: pick_and_place (SUCCESS, 85%)"
cast send --private-key $ROBOT2_KEY --rpc-url $RPC_URL \
  $REGISTRY \
  "recordEpisode(string,string,string,bool,uint16,string,string)" \
  "soarm_001" "pick_and_place" "manipulation/pick-place" true 8500 \
  "https://huggingface.co/datasets/orboh/pick-place-001" \
  "ipfs://QmRoboNetEpisode003" \
  --json | python3 -c "import json,sys; d=json.load(sys.stdin); print(f'  ✅ TX: {d[\"transactionHash\"]}')"

echo ""

# 4. Robot SO-ARM upvotes G1's box stacking episode
echo "🦾 Robot SO-ARM upvoting episode #0 (box_stacking)"
cast send --private-key $ROBOT2_KEY --rpc-url $RPC_URL \
  $REGISTRY \
  "upvote(uint256)" 0 \
  --json | python3 -c "import json,sys; d=json.load(sys.stdin); print(f'  ✅ TX: {d[\"transactionHash\"]}')"

echo ""

# 5. Query on-chain state
echo "========================================="
echo "  📊 On-Chain State"
echo "========================================="

TOTAL=$(cast call --rpc-url $RPC_URL $REGISTRY "getEpisodeCount()(uint256)")
echo "Total episodes: $TOTAL"

echo ""
echo "Episode #0 details:"
cast call --rpc-url $RPC_URL $REGISTRY \
  "getEpisode(uint256)(address,string,string,string,bool,uint16,string,string,uint256,uint256)" 0 2>&1 | head -10

echo ""
echo "========================================="
echo "  ✨ Demo complete!"
echo "  Robots sharing skills on-chain."
echo "========================================="
