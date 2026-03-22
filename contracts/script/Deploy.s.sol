// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/EpisodeRegistry.sol";

contract DeployEpisodeRegistry is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        EpisodeRegistry registry = new EpisodeRegistry();
        console.log("EpisodeRegistry deployed at:", address(registry));

        vm.stopBroadcast();
    }
}
