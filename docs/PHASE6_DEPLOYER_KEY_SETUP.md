# Phase 6 — Deployer Key Setup & Contract Deployment

You (the user) need to do these 3 steps before the backend blockchain integration can go live. The whole process takes ~5 minutes and uses **free testnet MATIC** (no real money).

---

## What you're doing (in plain English)

1. **Generate a new EVM wallet** (a public address + private key). This wallet will:
   - Deploy the `Voting.sol` contract to Polygon Amoy
   - Pay gas for every on-chain vote commit (the backend will use this same key)
2. **Get free test MATIC** from a Polygon faucet (testnet token with no value)
3. **Deploy the contract** — outputs a contract address that the backend will use

The contract is already written and tested (5/5 tests pass). The deploy script is already written. You just need to provide the key + run the deploy.

---

## Step 1 — Generate a deployer key

Open **Git Bash** and run:

```bash
cd /e/SecureVote/contracts
node -e "const {ethers}=require('ethers'); const w=new ethers.Wallet(require('crypto').randomBytes(32)); console.log('ADDRESS='+w.address); console.log('PRIVATE_KEY='+w.privateKey);" > .env
cat .env
```

**Expected output** (example, yours will be different):

```
ADDRESS=0xAbCdEf1234567890abcdef1234567890AbCdEf12
PRIVATE_KEY=0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcd
```

**Copy both lines** and save them somewhere temporary (you'll paste them back to me in chat). The `.env` file is in `.gitignore` so it won't be committed — but the key only ever exists on your local machine + the Wrangler secret (also gitignored).

---

## Step 2 — Get free test MATIC (Amoy)

1. Open **https://faucet.polygon.technology/** in your browser
2. Select network: **Polygon Amoy**
3. Paste your **ADDRESS** (the one from Step 1, e.g. `0xAbCdEf...`)
4. Complete the CAPTCHA
5. Click **Submit**
6. Wait ~30 seconds. You'll see a tx hash confirming the faucet sent ~0.5 test MATIC

> **No real money involved.** Amoy is a testnet. The MATIC has no monetary value.

### Optional: verify the faucet worked

Visit **https://amoy.polygonscan.com/** and paste your address. You should see a balance of ~0.5 MATIC and a recent incoming tx from the faucet.

---

## Step 3 — Deploy the contract

After confirming you have test MATIC, run:

```bash
cd /e/SecureVote/contracts
npx hardhat run scripts/deploy-amoy.ts --network amoy
```

**Expected output** (example):

```
Deploying Voting.sol to amoy (chainId 80002)
Deployer: 0xAbCdEf1234567890abcdef1234567890AbCdEf12
Balance:  0.5 MATIC
Voting deployed at: 0xDeAdBeEf1234567890abcdef1234567890DeAdBeef

Next steps:
1. Save the address to contracts/.env as VOTING_CONTRACT_ADDRESS=0xDeAdBeEf...
2. Set it as a wrangler secret in the api/ worker: wrangler secret put VOTING_CONTRACT_ADDRESS
3. Fund this deployer with test MATIC: https://faucet.polygon.technology/
4. Verify on https://amoy.polygonscan.com/address/0xDeAdBeEf...
```

**The deploy may take 15–30 seconds** (Amoy is fast but contract deployment still needs a few block confirmations).

---

## Step 4 — Send the outputs to me

Once the deploy finishes, paste me these 3 things in chat:

1. **The deployed contract address** (e.g. `0xDeAdBeEf...`)
2. **The deployer private key** (the `0x...` line from your `.env`)
3. **A link to the verified contract on PolygonScan** (e.g. `https://amoy.polygonscan.com/address/0xDeAdBeEf...`)

I'll then:

- Set `VOTING_CONTRACT_ADDRESS` and `PRIVATE_KEY` as encrypted Wrangler secrets on the `securevote-api` worker
- Re-deploy the backend with blockchain enabled
- Run a full end-to-end test:
  - Register a user
  - Upload a real KYC document (ID photo)
  - Admin approves in the web portal
  - Cast a vote → backend sends `commitVote` tx to Amoy → you can see it on PolygonScan within 30 seconds
  - Public verify endpoint returns the on-chain tx hash + block number + merkle proof
- Commit the final code + update the tech doc

---

## Troubleshooting

### "insufficient funds for gas"
- You didn't get the faucet MATIC yet, or it hasn't propagated. Wait 1 minute and retry. Check your address on amoy.polygonscan.com to confirm the balance.

### "nonce has already been used"
- Rare. Run `npx hardhat run scripts/deploy-amoy.ts --network amoy` again.

### "invalid private key"
- The `0x` prefix is required. Make sure the `.env` line starts with `0x`.

### Deploy takes >2 minutes
- Amoy can be slow under load. Wait. If it times out, the deploy likely still went through — check the address on PolygonScan.

---

## Security notes

- The deployer key is a **testnet-only** key. It holds no real assets and is published in plain text in the Wrangler secret.
- It will hold **only test MATIC** (~0.5 from the faucet). Top it up if it runs out (the backend will use it for ~0.001 MATIC per vote commit).
- Never reuse this key for mainnet or any real-value wallet.
- The `.env` file in `contracts/` and the Wrangler secret are both gitignored. The key never enters git history.

---

## Estimated cost

| Item | Cost |
|---|---|
| Contract deployment | ~0.05 test MATIC |
| Per-vote `commitVote` tx | ~0.001 test MATIC |
| Per-election `finalize` tx | ~0.01 test MATIC |
| **Total for full demo** | **< 0.1 test MATIC** |
| **Real money** | **$0** (testnet has no monetary value) |

The 0.5 MATIC from the faucet is more than enough for hundreds of demo votes.

---

*Once you've done all 3 steps, paste the outputs back and I'll wire up the backend + run the end-to-end test.*
