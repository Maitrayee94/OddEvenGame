const hre = require("hardhat");

async function main() {
  const OddEven = await hre.ethers.getContractFactory("OddEven");

  const OddEvenV= await OddEven.deploy();

  await OddEvenV.deployed();
  console.log(`WordMixValidator contract address: ${OddEvenV.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });