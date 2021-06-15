const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('RPS', async function () {
  let RPS, rps, owner, alice, bob;
  const PRICE = ethers.utils.parseEther('0.001');
  const DEPOSIT = ethers.utils.parseEther('0.01');
  const ROCK = 1;
  const SCISSOR = 2;
  const PAPER = 3;
  beforeEach(async function () {
    ;[owner, alice, bob] = await ethers.getSigners();
    RPS = await ethers.getContractFactory('RPS');
    rps = await RPS.connect(owner).deploy(PRICE);
    await rps.deployed();
  });
  describe('Party', async function () {
    beforeEach(async function () {
      await rps.connect(alice).createParty(bob.address);
      await rps.connect(bob).joinParty(alice.address);
    });
    it('Should asign good oponent to party creator', async function () {
      expect(await rps.connect(alice).opponent()).to.equal(bob.address);
    });
    it('Should asign good oponent to party joiner', async function () {
      expect(await rps.connect(bob).opponent()).to.equal(alice.address);
    });
  });
  describe('Play', async function () {
    beforeEach(async function () {
      await rps.connect(alice).deposit({ value: DEPOSIT });
      await rps.connect(bob).deposit({ value: DEPOSIT });
      await rps.connect(alice).createParty(bob.address);
      await rps.connect(bob).joinParty(alice.address);
    });
    it('Should decrease alice balance', async function () {
      await rps.connect(alice).play(ROCK);
      expect(await rps.connect(alice).balance()).to.equal(DEPOSIT);
    });
  });
});
