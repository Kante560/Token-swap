// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
//simple swap
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleSwap is ERC20 {
    IERC20 public tokenA;
    IERC20 public tokenB;
    uint256 public constant RATIO = 2; // 2 TokenA per 1 TokenB
    using SafeERC20 for IERC20;

    constructor(address _tokenA, address _tokenB) ERC20("SimpleSwap LP", "SS-LP") {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }
    event SwappedAforB(address indexed user, uint256 amountIn, uint256 amountOut);
    event SwappedBforA(address indexed user, uint256 amountIn, uint256 amountOut);
    event LiquidityAdded(address indexed user, uint256 amountA, uint256 amountB, uint256 liquidity);
    event LiquidityRemoved(address indexed user, uint256 amountA, uint256 amountB);

    function swapAforB(uint256 _sumA) external {
        uint256 reserveB = tokenB.balanceOf(address(this));
        uint256 amountB = _sumA / RATIO;
        require(amountB > 0, "amount too small");
        require(amountB <= reserveB, "Low on token B");
        tokenA.safeTransferFrom(msg.sender, address(this), _sumA); // pull IN — someone else's tokens
        tokenB.safeTransfer(msg.sender, amountB); // send OUT — the contract's own tokens
        emit SwappedAforB(msg.sender, _sumA, amountB);
    }

    function swapBforA(uint256 _sumB) external {
        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 amountA = _sumB * RATIO;
        require(amountA > 0, "amount too small");
        require(amountA <= reserveA, "low on token A");
        tokenB.safeTransferFrom(msg.sender, address(this), _sumB); 
        tokenA.safeTransfer(msg.sender, amountA);
        emit SwappedBforA(msg.sender, _sumB, amountA);
    }


function addLiquidity(uint256 _amountA, uint256 _amountB) external returns (uint256 liquidity) {
    require(_amountA > 0 && _amountB > 0, "zero deposit");
    require(_amountA == _amountB * RATIO, "invalid ratio");

    uint256 reserveA = tokenA.balanceOf(address(this)); 
    uint256 supply = totalSupply();

     

    if (supply == 0) {
        liquidity = _amountA;                                 
    } else {
        require(reserveA > 0, "reserve drained");
        liquidity = (_amountA * supply) / reserveA;
    }

    require(liquidity > 0, "insufficient liquidity minted");

    _mint(msg.sender, liquidity);                           

    tokenA.safeTransferFrom(msg.sender, address(this), _amountA);  
    tokenB.safeTransferFrom(msg.sender, address(this), _amountB);

    emit LiquidityAdded(msg.sender, _amountA, _amountB, liquidity);
}


    function removeLiquidity(uint256 _liquidity) external {
        uint256 totalA = tokenA.balanceOf(address(this));
        uint256 totalB = tokenB.balanceOf(address(this));
        uint256 supply = totalSupply();
        require(supply > 0, "no liquidity");

        uint256 payableA = (totalA * _liquidity) / supply;
        uint256 payableB = (totalB * _liquidity) / supply;
        require(payableA > 0 && payableB > 0, "insufficient liquidity to withdraw");

        _burn(msg.sender, _liquidity);

        tokenA.safeTransfer(msg.sender, payableA);
        tokenB.safeTransfer(msg.sender, payableB);
        emit LiquidityRemoved(msg.sender, payableA, payableB);
    }

    function ReserveA() external view returns(uint256){
        return tokenA.balanceOf(address(this));
    }

    function ReserveB() external view returns(uint256){
        return tokenB.balanceOf(address(this));
    }




    

    
}
