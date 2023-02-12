// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./interface/IUniswapV2Router.sol";
import "./interface/IERC20.sol";

contract UniswapV2Swap {
    address private constant UNISWAP_V2_ROUTER =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    IUniswapV2Router private router = IUniswapV2Router(UNISWAP_V2_ROUTER);
    IERC20 private weth = IERC20(WETH);
    IERC20 private dai = IERC20(DAI);

    //Todo: Swap WETH to DAI (WETH in DAI out):
    /*`swapSingleHopExactAmountIn`: This function swaps WETH for DAI. The user specifies the amount of WETH they want to spend and the minimum amount of DAI they
     expect(amountOutMin) to receive. The function transfers the specified amount of WETH from the user to the CONTRACT and approves the Uniswap V2 Router to access it.
     The function then calls swapExactTokensForTokens on the router to execute the swap, passing the user's desired amounts, the token addresses for WETH and DAI, the user's
     address, and the current block's timestamp as arguments. The function returns the amount of DAI received from the swap.*/
    function swapSingleHopExactAmountIn(
        uint256 amountIn,
        uint256 amountOutMin
    ) external returns (uint256 amountOut) {
        weth.transferFrom(msg.sender, address(this), amountIn);
        weth.approve(address(router), amountIn);

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = DAI;

        uint256[] memory amounts = router.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp
        );

        // amounts[0] = WETH amount, amounts[1] = DAI amount
        return amounts[1];
    }

    //Todo: Swap DAI -> WETH -> USDC
    /*swapMultiHopExactAmountIn: This function swaps DAI for USDC, going through WETH as an intermediary token. The user specifies the amount of DAI they want to spend and the minimum amount of USDC 
    they expect to receive. The function transfers the specified amount of DAI from the user to the contract and approves the Uniswap V2 Router to access it. The function then calls 
    swapExactTokensForTokens on the router to execute the swap, passing the user's desired amounts, the token addresses for DAI, WETH, and USDC, the user's address, and the current block's
    timestamp as arguments. The function returns the amount of USDC received from the swap.
     */
    function swapMultiHopExactAmountIn(
        uint256 amountIn,
        uint256 amountOutMin
    ) external returns (uint256 amountOut) {
        //todo: WETH <-> DAI
        dai.transferFrom(msg.sender, address(this), amountIn);
        dai.approve(address(router), amountIn);

        address[] memory path = new address[](3);
        path[0] = DAI;
        path[1] = WETH;
        path[2] = USDC;

        uint[] memory amounts = router.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp
        );

        return amounts[2];
    }

    //Todo: Swap WETH to DAI(WETH in DAI out)
    /* swapSingleHopExactAmountOut: This function is similar to swapSingleExactAmountIn, but the user specifies the desired amount of DAI they want to receive instead of the amount of WETH they
    want to spend. The function transfers the maximum amount of WETH the user is willing to spend to the contract and approves the Uniswap V2 Router to access it. The function then calls 
    swapTokensForExactTokens on the router to execute the swap, passing the user's desired amount of DAI, the maximum amount of WETH they are willing to spend, the token addresses for WETH and DAI,
    the user's address, and the current block's timestamp as arguments. The function returns the amount of DAI received from the swap, and if the amount of WETH spent is less than the maximum amount
    the user was willing to spend, the contract refunds the difference to the user.
     */
    function swapSingleHopExactAmountOut(
        uint256 amountOutDesired,
        uint256 amountInMax
    ) external returns (uint256 amountOut) {
        weth.transferFrom(msg.sender, address(this), amountInMax);
        weth.approve(address(router), amountInMax);

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = DAI;

        uint[] memory amounts = router.swapTokensForExactTokens(
            amountOutDesired,
            amountInMax,
            path,
            msg.sender,
            block.timestamp
        );

        // Refund WETH to msg.sender
        if (amounts[0] < amountInMax) {
            weth.transfer(msg.sender, amountInMax - amounts[0]);
        }
        return amounts[1];
    }

    //Todo: Swap DAI -> WETH -> USDC
    /*
    swapMultiHopExactAmountOut: This function is similar to swapMultiHopExactAmountIn, but the user specifies the desired amount of USDC they want to receive instead of the amount of DAI they want to
    spend. The function transfers the maximum amount of DAI the user is willing to spend to the contract and approves the Uniswap V2 Router to access it. The function then calls 
    swapTokensForExactTokens on the router to execute the swap, passing the user's desired amount of USDC, the maximum amount of DAI they are willing to spend, the token addresses for DAI, WETH, 
    and USDC, the user's address, and the current block's timestamp as arguments. The function returns the amount of USDC received from the swap, and if the amount of DAI spent is less than the
    maximum amount the user was willing to spend, the contract refunds the difference to the user.  
   */
    function swapMultiHopExactAmountOut(
        uint256 amountOutDesired,
        uint256 amountInMax
    ) external returns (uint256 amountOut) {
        dai.transferFrom(msg.sender, address(this), amountInMax);
        dai.approve(address(router), amountInMax);

        address[] memory path = new address[](3);
        path[0] = DAI;
        path[1] = WETH;
        path[2] = USDC;

        uint[] memory amounts = router.swapTokensForExactTokens(
            amountOutDesired,
            amountInMax,
            path,
            msg.sender,
            block.timestamp
        );

        // Refund DAI to msg.sender
        if (amounts[0] < amountInMax) {
            dai.transfer(msg.sender, amountInMax - amounts[0]);
        }

        return amounts[2];
    }
}

//Note: Swap WETH -> DAI (Both the cases). But first one: You specify your desied amountIn(WETH in this case), and in second one you specify your desired amountOut(DAI in this case)

/* Note: The Uniswap Router is a periphery contract which means that it's not strictly necessary. But still you should use it due to the fact that it protects you against various kinds of attacks on 
your trades.

One of the attack vectors is frontrunning your trades. That means you enter your trade, some bot notices it in the Ethereum mempool (before it's executed), creates their own trade which gets executed
 before your trade and their trade makes your trade less profitable for you.

To prevent this kinds of attacks the router provides various mechanisms; one of them is that amountoutmin. You could just send X amount of Eth to Uniswap and say "give me the maximum amount of tokens
for this amount of Eth I give you" but that would be suspectible to frontrunning attacks. So you also need to specify how many tokens you want at minimum with amountoutmin. If the trading price has
shifted too much between when you send the transaction and when it gets executed your trade gets reverted.

So you have to know in advance how many tokens you'd like to get, at minimum.
*/
