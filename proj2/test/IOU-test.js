const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("IOU", function () {
  it("Should return the new greeting once it's changed", async function () {
    let user1, user2, user;

    const IOU = await ethers.getContractFactory("IOU");
    const iou = await IOU.deploy();
    await iou.deployed();

    [user1, user2, user3] = await ethers.getSigners();

    await iou.connect(user1).add_IOU(user2.address, 10);
    expect(await iou.lookup(user1.address,user2.address)).to.equal(10);
    await iou.connect(user1).add_IOU(user2.address, 10);
    expect(await iou.lookup(user1.address,user2.address)).to.equal(20);

    // const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // // wait until the transaction is mined
    // await setGreetingTx.wait();

    // expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
