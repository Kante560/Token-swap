// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {TokenA} from "../src/TokenA.sol";
import {TokenB} from "../src/TokenB.sol";
import {SimpleSwap} from "../src/SimpleSwap.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();

        TokenA tokenA = new TokenA();
        TokenB tokenB = new TokenB();
        SimpleSwap swap = new SimpleSwap(address(tokenA), address(tokenB));

        // seed the pool so it's tradeable on arrival
        tokenA.approve(address(swap), 200_000e18);
        tokenB.approve(address(swap), 100_000e18);
        swap.addLiquidity(200_000e18, 100_000e18);

        vm.stopBroadcast();

        console.log("TokenA:    ", address(tokenA));
        console.log("TokenB:    ", address(tokenB));
        console.log("SimpleSwap:", address(swap));
    }
}