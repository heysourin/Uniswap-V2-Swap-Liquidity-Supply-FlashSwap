// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/UniswapV2Swap.sol";
import "../src/interface/IWETH.sol";

address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

contract UniswapV2SwapTest is Test {
    IWETH private weth = IWETH(WETH);
    IERC20 private dai = IERC20(DAI);
    IERC20 private usdc = IERC20(USDC);

    // UniswapV2Swap public myContract;
    UniswapV2Swap private uni = new UniswapV2Swap();

    function testExample() public {
        assertTrue(true);
    }

    //Todo: TEST: Swap WETH to DAI (WETH in DAI out):
    function testSwapSingleHopExactAmountIn() public {
        uint wethAmount = 10 ** 18;

        weth.deposit{value: wethAmount}(); //Solidity "send" operator (curly braces {}) used to send the ETH to the contract.
        weth.approve(address(uni), wethAmount);

        uint256 daiAmountMin = 1; //amountOutMin~ we expect to receive

        uint256 daiAmountOut = uni.swapSingleHopExactAmountIn(
            wethAmount, // amountIn
            daiAmountMin //amountOutMin
        );

        // console.log("DAI", daiAmountOut);
        assertGe(daiAmountOut, daiAmountMin, "amount out < min"); // we have set minAmountOut so we are obviously getting that but we may get even greater than that.
    }

    // Swap DAI -> WETH -> USDC
    function testSwapMultiHopExactAmountIn() public {
        //Swap WETH -> DAI
        uint256 wethAmount = 10 ** 18; //1 ether
        weth.deposit{value: wethAmount}();
        weth.approve(address(uni), wethAmount);

        uint256 daiAmountMin = 1; //1 wei
        uni.swapSingleHopExactAmountIn(wethAmount, daiAmountMin);

        //Swap DAI -> WETH -> USDC
        uint256 daiAmountIn = 10 ** 18;
        dai.approve(address(uni), daiAmountIn);

        uint256 usdcAmountOutMin = 1;

        uint256 usdcAmountOut = uni.swapMultiHopExactAmountIn(
            daiAmountIn,
            usdcAmountOutMin
        );

        console.log("USDC", usdcAmountOut);
        assertGe(usdcAmountOut, usdcAmountOutMin, "Amount out < min");
    }

    // Swap WETH -> DAI
    function testSwapSingleHopExactAmountOut() public {
        uint wethAmount = 1e18;
        weth.deposit{value: wethAmount}();
        weth.approve(address(uni), wethAmount);

        uint daiAmountDesired = 1e18;
        uint daiAmountOut = uni.swapSingleHopExactAmountOut(
            daiAmountDesired,
            wethAmount
        );

        console.log("DAI", daiAmountOut);
        assertEq(
            daiAmountOut,
            daiAmountDesired,
            "amount out != amount out desired"
        );
    }

    // Swap DAI -> WETH -> USDC
    function testSwapMultiHopExactAmountOut() public {
        // Swap WETH -> DAI
        uint wethAmount = 1e18;
        weth.deposit{value: wethAmount}();
        weth.approve(address(uni), wethAmount);

        // Buy 100 DAI
        uint daiAmountOut = 100 * 1e18;
        uni.swapSingleHopExactAmountOut(daiAmountOut, wethAmount);

        // Swap DAI -> WETH -> USDC
        dai.approve(address(uni), daiAmountOut);

        uint amountOutDesired = 1e6;
        uint amountOut = uni.swapMultiHopExactAmountOut(
            amountOutDesired,
            daiAmountOut
        );

        console.log("USDC", amountOut);
        assertEq(
            amountOut,
            amountOutDesired,
            "amount out != amount out desired"
        );
    }
}
