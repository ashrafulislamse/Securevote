const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("Voting", function () {
  async function deploy() {
    const [owner, voter1, voter2] = await ethers.getSigners();
    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy();
    return { voting, owner, voter1, voter2 };
  }

  it("creates an election", async function () {
    const { voting, owner } = await deploy();
    const start = (await time.latest()) + 10;
    const end = start + 3600;
    await expect(voting.connect(owner).createElection("e1", start, end))
      .to.emit(voting, "ElectionCreated")
      .withArgs("e1", start, end);
  });

  it("rejects bad window", async function () {
    const { voting, owner } = await deploy();
    const t = await time.latest();
    await expect(voting.connect(owner).createElection("e1", t, t))
      .to.be.revertedWithCustomError(voting, "BadWindow");
  });

  it("rejects double vote", async function () {
    const { voting, owner, voter1 } = await deploy();
    const start = (await time.latest()) + 5;
    const end = start + 3600;
    await voting.connect(owner).createElection("e1", start, end);
    await time.increase(10);
    const h = ethers.keccak256(ethers.toUtf8Bytes("vote1"));
    await voting.connect(voter1).commitVote("e1", h);
    await expect(voting.connect(voter1).commitVote("e1", h))
      .to.be.revertedWithCustomError(voting, "AlreadyVoted");
  });

  it("rejects vote outside window", async function () {
    const { voting, owner, voter1 } = await deploy();
    const start = (await time.latest()) + 1000;
    const end = start + 1000;
    await voting.connect(owner).createElection("e1", start, end);
    await expect(voting.connect(voter1).commitVote("e1", ethers.ZeroHash))
      .to.be.revertedWithCustomError(voting, "NotInWindow");
  });

  it("finalizes with merkle root", async function () {
    const { voting, owner } = await deploy();
    const start = (await time.latest()) + 5;
    const end = start + 100;
    await voting.connect(owner).createElection("e1", start, end);
    await time.increase(200);
    const root = ethers.keccak256(ethers.toUtf8Bytes("root"));
    await expect(voting.connect(owner).finalize("e1", root))
      .to.emit(voting, "ElectionFinalized");
  });
});
