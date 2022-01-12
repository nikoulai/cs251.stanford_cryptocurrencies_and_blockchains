const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  const Alma = await hre.ethers.getContractFactory("AlmaInu");
  const alma = await Alma.deploy();

  await alma.deployed();

  console.log("Alma deployed to:", alma.address);
  // We get the contract to deploy
  const Exchange = await hre.ethers.getContractFactory("AlmaExchange");
  const exchange = await Exchange.deploy(alma.address);

  await exchange.deployed();

  console.log("Exchange deployed to:", exchange.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
