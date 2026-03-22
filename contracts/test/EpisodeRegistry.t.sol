// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/EpisodeRegistry.sol";

contract EpisodeRegistryTest is Test {
    EpisodeRegistry registry;
    address robot1 = address(0x1);
    address robot2 = address(0x2);

    function setUp() public {
        registry = new EpisodeRegistry();
    }

    function testRecordEpisode() public {
        vm.prank(robot1);
        uint256 id = registry.recordEpisode(
            "g1_sim_001",
            "box_stacking",
            "manipulation/stacking",
            true,
            10000,
            "https://huggingface.co/datasets/orboh/box-stacking-001",
            "ipfs://QmExample"
        );

        assertEq(id, 0);
        assertEq(registry.getEpisodeCount(), 1);

        EpisodeRegistry.Episode memory ep = registry.getEpisode(0);
        assertEq(ep.robot, robot1);
        assertEq(ep.taskName, "box_stacking");
        assertEq(ep.success, true);
        assertEq(ep.completionRate, 10000);
    }

    function testUpvote() public {
        vm.prank(robot1);
        registry.recordEpisode("g1_001", "walk", "locomotion", true, 8500, "", "");

        vm.prank(robot2);
        registry.upvote(0);

        EpisodeRegistry.Episode memory ep = registry.getEpisode(0);
        assertEq(ep.upvotes, 1);
    }

    function testCannotDoubleUpvote() public {
        vm.prank(robot1);
        registry.recordEpisode("g1_001", "walk", "locomotion", true, 8500, "", "");

        vm.prank(robot2);
        registry.upvote(0);

        vm.prank(robot2);
        vm.expectRevert("Already upvoted");
        registry.upvote(0);
    }

    function testGetRobotEpisodes() public {
        vm.startPrank(robot1);
        registry.recordEpisode("g1_001", "walk", "locomotion", true, 9000, "", "");
        registry.recordEpisode("g1_001", "pick", "manipulation", false, 3000, "", "");
        vm.stopPrank();

        uint256[] memory ids = registry.getRobotEpisodes(robot1);
        assertEq(ids.length, 2);
        assertEq(ids[0], 0);
        assertEq(ids[1], 1);
    }

    function testCompletionRateCap() public {
        vm.prank(robot1);
        vm.expectRevert("completionRate > 100%");
        registry.recordEpisode("g1_001", "walk", "locomotion", true, 10001, "", "");
    }
}
