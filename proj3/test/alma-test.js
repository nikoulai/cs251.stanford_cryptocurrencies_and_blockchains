const { expect } = require("chai");
const { ethers } = require("hardhat");
const { before } = require("underscore");

describe("AlmaInu", function () {
  let almaInst;
  let owner;
  let addrs;

  beforeEach(async function () {
    const AlmaInu = await ethers.getContractFactory("AlmaInu");
    const alma = await AlmaInu.deploy();
    await alma.deployed();

    almaInst = alma;

    console.log("Alma deployed to:", alma.address);

    [owner, ...addrs] = await ethers.getSigners();
  });

  it("_mint should update total supply", async function () {


    const initialSupply = 20000;

    await almaInst._mint(initialSupply);

    const totalSupply = await almaInst.totalSupply();

    expect((await almaInst.totalSupply()).toNumber()).to.equal(initialSupply);


    //double the total supply
    await almaInst._mint(initialSupply);
    expect((await almaInst.totalSupply()).toNumber()).to.equal(2 * initialSupply);

  });

  it("_mint should update owner's balance", async function () {


    const initialSupply = 20000;

    await almaInst._mint(initialSupply);

    const totalSupply = await almaInst.totalSupply();

    expect((await almaInst.balanceOf(owner.address)).toNumber()).to.equal(initialSupply);


    //double the total supply
    await almaInst._mint(initialSupply);
    expect((await almaInst.balanceOf(owner.address)).toNumber()).to.equal(2 * initialSupply);

  });

  it("mint call should fail after _disable_mint is called", async function () {

    //disable minting
    await almaInst._disable_mint();
    const mint = almaInst._mint(1);
    await expect(mint).to.be.revertedWith("Minting has been disabled.");

  });



});
