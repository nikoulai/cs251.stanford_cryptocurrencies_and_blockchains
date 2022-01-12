// =================== CS251 DEX Project =================== // 
//        @authors: Simon Tao '22, Mathew Hogan '22          //
// ========================================================= //    
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import '../interfaces/erc20_interface.sol';
import '../libraries/safe_math.sol';
import './token.sol';
import 'hardhat/console.sol';


contract AlmaExchange {
    using SafeMath for uint;
    address public admin;

    address tokenAddr ; //= address(0x5FbDB2315678afecb367f032d93F642f64180aa3) ;                              // TODO: Paste token contract address here.
    AlmaInu private token; // = AlmaInu(tokenAddr);         // TODO: Replace "Token" with your token class.             

    // Liquidity pool for the exchange
    uint public token_reserves = 0;
    uint public eth_reserves = 0;

    // Constant: x * y = k
    uint public k;
    
    // liquidity rewards
    uint private swap_fee_numerator = 0;       // TODO Part 5: Set liquidity providers' returns.
    uint private swap_fee_denominator = 100;
    
    event AddLiquidity(address from, uint amount);
    event RemoveLiquidity(address to, uint amount);
    event Received(address from, uint amountETH);

    
    mapping(address => uint) shares;
    uint total_shares;
    constructor(address _tokenAddrStr) 
    {
        tokenAddr = _tokenAddrStr;
        admin = msg.sender;
        token = AlmaInu(tokenAddr);
    }
    
    modifier AdminOnly {
        require(msg.sender == admin, "Only admin can use this function!");
        _;
    }

    // Used for receiving ETH
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    fallback() external payable{}

    // Function createPool: Initializes a liquidity pool between your Token and ETH.
    // ETH will be sent to pool in this transaction as msg.value
    // amountTokens specifies the amount of tokens to transfer from the liquidity provider.
    // Sets up the initial exchange rate for the pool by setting amount of token and amount of ETH.
    function createPool(uint amountTokens)
        external
        payable
        AdminOnly
    {
        // require pool does not yet exist
        require (token_reserves == 0, "Token reserves was not 0");
        require (eth_reserves == 0, "ETH reserves was not 0.");

        // require nonzero values were sent
        require (msg.value > 0, "Need ETH to create pool.");
        require (amountTokens > 0, "Need tokens to create pool.");

        token.transferFrom(msg.sender, address(this), amountTokens);
        eth_reserves = msg.value;
        token_reserves = amountTokens;
        k = eth_reserves.mul(token_reserves);

        console.log("eth_reserves", eth_reserves);
        console.log("token_reserves", token_reserves);
        // TODO: Keep track of the initial liquidity added so the initial provider
        //          can remove this liquidity
        shares[msg.sender] = msg.value;
        total_shares = eth_reserves;
    }

    // ============================================================
    //                    FUNCTIONS TO IMPLEMENT
    // ============================================================
    /* Be sure to use the SafeMath library for all operations! */
    
    // Function priceToken: Calculate the price of your token in ETH.
    // You can change the inputs, or the scope of your function, as needed.
    function priceToken() 
        public 
        view
        returns (uint)
    {
        /******* TODO: Implement this function *******/
        /* HINTS:
            Calculate how much ETH is of equivalent worth based on the current exchange rate.
        */
        return eth_reserves.div(token_reserves);
        
    }

    // Function priceETH: Calculate the price of ETH for your token.
    // You can change the inputs, or the scope of your function, as needed.
    function priceETH()
        public
        view
        returns (uint)
    {
        /******* TODO: Implement this function *******/
        /* HINTS:
            Calculate how much of your token is of equivalent worth based on the current exchange rate.
        */

        return token_reserves.div(eth_reserves);
    }


    /* ========================= Liquidity Provider Functions =========================  */ 

    // Function addLiquidity: Adds liquidity given a supply of ETH (sent to the contract as msg.value)
    // You can change the inputs, or the scope of your function, as needed.
    function addLiquidity() 
        external 
        payable
    {
        /******* TODO: Implement this function *******/
        /* HINTS:
            Calculate the liquidity to be added based on what was sent in and the prices.
            If the caller possesses insufficient tokens to equal the ETH sent, then transaction must fail.
            Update token_reserves, eth_reserves, and k.
            Emit AddLiquidity event.
        */

        require(msg.value > 0, "msg.value should be greater than zero.");

        uint required_tokens = msg.value.mul(token_reserves).div(eth_reserves);

        bool transfered = token.transferFrom(msg.sender,address(this),required_tokens);
        require(transfered, "Could not transfer tokens to exchange.");

        uint shares_minted = msg.value.mul(total_shares).div(eth_reserves);

        uint tokens_added = shares_minted.mul(token_reserves).div(total_shares);

        shares[msg.sender] = shares[msg.sender].add(shares_minted);

        total_shares = total_shares.add(shares_minted);
        eth_reserves = eth_reserves + msg.value;
        token_reserves = token_reserves + tokens_added;

        eth_reserves = eth_reserves.add(msg.value);
        token_reserves += token_reserves;

        emit AddLiquidity(msg.sender, shares_minted);
    }


    // Function removeLiquidity: Removes liquidity given the desired amount of ETH to remove.
    // You can change the inputs, or the scope of your function, as needed.
    function removeLiquidity(uint amountETH)
        public 
        payable
    {
        /******* TODO: Implement this function *******/
        /* HINTS:
            Calculate the amount of your tokens that should be also removed.
            Transfer the ETH and Token to the provider.
            Update token_reserves, eth_reserves, and k.
            Emit RemoveLiquidity event.
        */
        require(amountETH > 0, "Eth amount to withdraw should be positive.");

        uint shares_out = amountETH.mul(total_shares).div(eth_reserves);
        require(shares_out <= shares[msg.sender], "Not enought liquidity provided by user to withdraw so mush ETH.");

        shares[msg.sender] = shares[msg.sender].sub(shares_out);
        total_shares = total_shares.sub(shares_out);

        uint tokens_out = msg.value.mul(token_reserves).div(eth_reserves);

        //Update state
        eth_reserves = eth_reserves.sub(amountETH);
        token_reserves = token_reserves.sub(tokens_out);
        k = token_reserves * eth_reserves;

        payable(msg.sender).transfer(amountETH);
        token.transfer(msg.sender, tokens_out);

        emit RemoveLiquidity(msg.sender, shares_out);

    }

    // Function removeAllLiquidity: Removes all liquidity that msg.sender is entitled to withdraw
    // You can change the inputs, or the scope of your function, as needed.
    function removeAllLiquidity()
        external
        payable
    {
        /******* TODO: Implement this function *******/
        /* HINTS:
            Decide on the maximum allowable ETH that msg.sender can remove.
            Call removeLiquidity().
        */

        uint maxWithdraw = eth_reserves.mul(shares[msg.sender]).div(total_shares);

        removeLiquidity(maxWithdraw);
    }

    /***  Define helper functions for liquidity management here as needed: ***/



    /* ========================= Swap Functions =========================  */ 

    // Function swapTokensForETH: Swaps your token with ETH
    // You can change the inputs, or the scope of your function, as needed.
    function swapTokensForETH(uint amountTokens)
        external 
        payable
    {
        /******* TODO: Implement this function *******/
        /* HINTS:
            Calculate amount of ETH should be swapped based on exchange rate.
            Transfer the ETH to the provider.
            If the caller possesses insufficient tokens, transaction must fail.
            If performing the swap would exhaus total ETH supply, transaction must fail.
            Update token_reserves and eth_reserves.

            Part 4: 
                Expand the function to take in addition parameters as needed.
                If current exchange_rate > slippage limit, abort the swap.
            
            Part 5:
                Only exchange amountTokens * (1 - liquidity_percent), 
                    where % is sent to liquidity providers.
                Keep track of the liquidity fees to be added.
        */
        uint new_token_reserves = token_reserves + amountTokens;
        uint new_eth_reserves = k.div(amountTokens);
        uint eth_out = eth_reserves - new_eth_reserves;
        eth_reserves = new_eth_reserves;
        token_reserves = new_token_reserves;

        token.transferFrom(msg.sender, address(this), amountTokens);
        payable(msg.sender).transfer(eth_out);

        /***************************/
        // DO NOT MODIFY BELOW THIS LINE
        /* Check for x * y == k, assuming x and y are rounded to the nearest integer. */
        // Check for Math.abs(token_reserves * eth_reserves - k) < (token_reserves + eth_reserves + 1));
        //   to account for the small decimal errors during uint division rounding.
        uint check = token_reserves.mul(eth_reserves);
        if (check >= k) {
            check = check.sub(k);
        }
        else {
            check = k.sub(check);
        }
        assert(check < (token_reserves.add(eth_reserves).add(1)));
    }



    // Function swapETHForTokens: Swaps ETH for your tokens.
    // ETH is sent to contract as msg.value.
    // You can change the inputs, or the scope of your function, as needed.
    function swapETHForTokens()
        external
        payable 
    {
        /******* TODO: Implement this function *******/
        /* HINTS:
            Calculate amount of your tokens should be swapped based on exchange rate.
            Transfer the amount of your tokens to the provider.
            If performing the swap would exhaus total token supply, transaction must fail.
            Update token_reserves and eth_reserves.


            Part 4: 
                Expand the function to take in addition parameters as needed.
                If current exchange_rate > slippage limit, abort the swap. 
            
            Part 5: 
                Only exchange amountTokens * (1 - %liquidity), 
                    where % is sent to liquidity providers.
                Keep track of the liquidity fees to be added.
        */

        require(msg.value > 0, "Insufficient amount of ETH");
        uint new_eth_reserves = msg.value + eth_reserves;
        uint new_token_reserves = k.div(new_eth_reserves);

        uint tokens_removed = token_reserves.sub(new_token_reserves);
        eth_reserves = new_eth_reserves;
        token_reserves = new_token_reserves;
        token.transfer(msg.sender,tokens_removed);
        /**************************/
        // DO NOT MODIFY BELOW THIS LINE
        /* Check for x * y == k, assuming x and y are rounded to the nearest integer. */
        // Check for Math.abs(token_reserves * eth_reserves - k) < (token_reserves + eth_reserves + 1));
        //   to account for the small decimal errors during uint division rounding.
        uint check = token_reserves.mul(eth_reserves);
        if (check >= k) {
            check = check.sub(k);
        }
        else {
            check = k.sub(check);
        }
        assert(check < (token_reserves.add(eth_reserves).add(1)));
    }

    /***  Define helper functions for swaps here as needed: ***/

}
