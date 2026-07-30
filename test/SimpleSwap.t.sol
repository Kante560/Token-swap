// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SimpleSwap} from "../src/SimpleSwap.sol";
import {TokenA} from "../src/TokenA.sol";
import {TokenB} from "../src/TokenB.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";



contract SimpleSwapTest is Test {
    SimpleSwap public swap;
    TokenA public tokenA;
    TokenB public tokenB;

    address public alice = address(0x1);

    function setUp() public {
        tokenA = new TokenA();
        tokenB = new TokenB();
        swap = new SimpleSwap(address(tokenA), address(tokenB));
    }

    // function test_AddLiquidity() public {
    //     // 1 grant token pull permission

    //     tokenA.approve(address(swap), 1000e18);
    //     tokenB.approve(address(swap), 500e18);

    //     //2 carry out swap
    //     swap.addLiquidity(1000e18, 500e18);

    //     assertEq(tokenA.balanceOf(address(swap)), 1000e18);
    //     assertEq(tokenB.balanceOf(address(swap)), 500e18);
    // }

    //Swapping token A for B
    function test_swapAforB() public {
        tokenA.approve(address(swap), 1000e18);
        tokenB.approve(address(swap), 500e18);
        swap.addLiquidity(1000e18, 500e18);

        tokenA.approve(address(swap), 100e18);

        uint256 balBefore = tokenB.balanceOf(address(this));
        swap.swapAforB(100e18);

        assertEq(tokenA.balanceOf(address(swap)), 1100e18);
        assertEq(tokenB.balanceOf(address(this)) - balBefore, 50e18);
    }

    // //when token is finished

    function test_revertWhen_pool_empty() public {
        tokenA.approve(address(swap), 100e18);
        vm.expectRevert("Low on token B");
        swap.swapAforB(10e18);
    }

    // when user wants to swap lower than token ratio/worth

    function test_revert_amount_too_small() public {
        // add liquidity
        tokenA.approve(address(swap), 100e18);
        tokenB.approve(address(swap), 50e18);
        swap.addLiquidity(100e18, 50e18);
        //initiate swap
        vm.expectRevert("amount too small");
        swap.swapAforB(1);
    }

    //swapping token B for A

    function test_swapBforA() public {
        //add liquidity
        tokenA.approve(address(swap), 100e18);
        tokenB.approve(address(swap), 50e18);
        swap.addLiquidity(100e18, 50e18);

        tokenB.approve(address(swap), 5e18);

        //initialize swap
        swap.swapBforA(5e18);

        //assert balance
        assertEq(tokenA.balanceOf(address(swap)), 90e18);
        assertEq(tokenB.balanceOf(address(swap)), 55e18);
    }

    function test_revert_on_no_approval() public {
        tokenA.approve(address(swap), 100e18);
        tokenB.approve(address(swap), 50e18);
        swap.addLiquidity(100e18, 50e18);

        //initialize swap
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector,address(swap),0,5e18));
        swap.swapBforA(5e18);
    }

    function test_swap_as_externalUser() public {
        tokenA.approve(address(swap), 200e18);
        tokenB.approve(address(swap), 100e18);
        swap.addLiquidity(200e18, 100e18);

        tokenA.transfer(alice, 100e18);

        vm.startPrank(alice);
        tokenA.approve(address(swap),100e18);
        swap.swapAforB(100e18);
        vm.stopPrank();

        assertEq(tokenA.balanceOf(alice),0);
        assertEq(tokenB.balanceOf(alice), 50e18);
    }

    function testFuzz_swapAforB(uint256 _amountIn) public {
        _amountIn = bound(_amountIn, 11, 11100e18);

        tokenA.approve(address(swap), 1000e18);
        tokenB.approve(address(swap), 500e18);
        swap.addLiquidity(1000e18, 500e18);

        tokenA.approve(address(swap), 100e18);

        swap.swapAforB(100e18);

        assertEq(tokenA.balanceOf(address(swap)), 1100e18);
        assertEq(tokenB.balanceOf(address(swap)), 450e18);


    }
}
 