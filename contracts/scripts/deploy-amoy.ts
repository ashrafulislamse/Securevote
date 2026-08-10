import { ethers, network } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying Voting.sol to ${network.name} (chainId ${network.config.chainId})`);
  console.log(`Deployer: ${deployer.address}`);
  console.log(`Balance:  ${ethers.formatEther(await ethers.provider.getBalance(deployer.address))} MATIC`);

  const Voting = await ethers.getContractFactory("Voting");
  const voting = await Voting.deploy();
  await voting.waitForDeployment();

  const address = await voting.getAddress();
  console.log(`\nVoting deployed at: ${address}`);
  console.log(`\nNext steps:`);
  console.log(`1. Save the address to contracts/.env as VOTING_CONTRACT_ADDRESS=${address}`);
  console.log(`2. Set it as a wrangler secret in the api/ worker: wrangler secret put VOTING_CONTRACT_ADDRESS`);
  console.log(`3. Fund this deployer with test MATIC: https://faucet.polygon.technology/`);
  console.log(`4. Verify on https://amoy.polygonscan.com/address/${address}`);
}

main().catch((e) => { console.error(e); process.exit(1); });
