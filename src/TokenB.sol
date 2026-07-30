// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
// tokenb
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenB is ERC20 {
    constructor() ERC20("TokenB", "TKB") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
    // function authorizeLiqidity() external {
    //    tokenB.approve(msg.sender, amountB); 
    //     swap.addLiquidity(amountA, amountB); 

    // }
}