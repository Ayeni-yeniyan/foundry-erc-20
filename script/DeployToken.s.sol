// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {SamToken} from "src/SamToken.sol";
import {Script} from "forge-std/Script.sol";

contract DeployToken is Script {
    uint256 public constant INITIAL_SUPPLY = 100 ether;

    function run() public returns (SamToken) {
        vm.startBroadcast();
        SamToken samToken = new SamToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return samToken;
    }
}
