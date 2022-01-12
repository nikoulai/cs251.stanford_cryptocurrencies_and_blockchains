const { expect } = require("chai");
const { ethers } = require("hardhat");
const { before } = require("underscore");

async function init(exchange_contract,token_contract,owner) {
      var poolState = await getPoolState(exchange_contract, owner);
      if (poolState['token_liquidity'] === 0
        && poolState['eth_liquidity'] === 0) {
        // Call mint twice to make sure mint can be called mutliple times prior to disable_mint
        const total_supply = 10000000000;
        await token_contract.connect(owner)._mint(total_supply / 2);
        await token_contract.connect(owner)._mint(total_supply / 2);
        await token_contract.connect(owner)._disable_mint(); //.send({ from: web3.eth.defaultAccount, gas: 999999 });
        await token_contract.connect(owner).approve(exchange_contract.address, total_supply);//.send({ from: web3.eth.defaultAccount });
        // initialize pool with equal amounts of ETH and tokens, so exchange rate begins as 1:1

        const options = {
		value: ethers.utils.parseUnits(total_supply.toString(), "wei"),
    
	   };
     ethers.utils
        // await exchange_contract.connect(owner).createPool(total_supply , options);
        await exchange_contract.createPool(total_supply , options);

        // All accounts start with 0 of your tokens. Thus, be sure to swap before adding liquidity.
      }
    }

    async function getPoolState(exchange_contract, owner) {
      // read pool balance for each type of liquidity
      let liquidity_tokens = await exchange_contract.connect(owner).token_reserves(); //.call({ from: web3.eth.defaultAccount });
      let liquidity_eth = await exchange_contract.connect(owner).eth_reserves(); //.call({ from: web3.eth.defaultAccount });
      return {
        token_liquidity: liquidity_tokens * 10 ** (-18),
        eth_liquidity: liquidity_eth * 10 ** (-18),
        token_eth_rate: liquidity_tokens / liquidity_eth,
        eth_token_rate: liquidity_eth / liquidity_tokens
      };
    }

describe("Alma Exchange", function () {
  let almaInst;
  let exInst;
  let owner;
  let addrs;

  beforeEach(async function () {

    [owner, ...addrs] = await ethers.getSigners();

    const AlmaInu = await ethers.getContractFactory("AlmaInu");
    const alma = await AlmaInu.deploy();
    await alma.deployed();

    almaInst = alma;

    console.log("Alma deployed to:", alma.address);

    // We get the contract to deploy
    const Exchange = await hre.ethers.getContractFactory("AlmaExchange");
    const exchange = await Exchange.deploy(alma.address);
    await exchange.deployed();

    console.log("Exchange deployed to:", exchange.address);

    exInst = exchange;

    let total_supply = 200;
//     const options = { value: ethers.utils.parse(total_supply.toString()) }
//     await exchange.removeLiquidity(200 , options);



    await init(exInst,almaInst,owner);

  });

  it("Call to TransferFrom should fail due to insuffient Ethers", async function () {

    const addLiquidity = exInst.connect(addrs[0]).addLiquidity();//.send({value: 1});
    await expect(addLiquidity).to.be.revertedWith("msg.value should be greater than zero");



  });

  it("Call to TransferFrom should fail due to insuffient tokens", async function () {

    const options = { value: ethers.utils.parseEther("1.0") }

    await exInst.connect(addrs[0]).priceToken();//.send({value: 1});
    // await exInst.connect(addrs[0]).addLiquidity(options);//.send({value: 1});
    // await expect(addLiquidity).to.be.revertedWith("msg.value should be greater than zero");

  });

});