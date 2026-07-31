// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
// token A
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenA is ERC20 {
    constructor() ERC20("TokenA", "TKA") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    // function authorizeLiqidity() external {

    //     tokenA.approve(msg.sender, amountA);
    //     swap.addLiquidity(amountA, amountB);

    // }
}
