async function main() {

  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const ccc_governance = await ethers.getContractFactory("ccc_governance");
  const deployedContract = await ccc_governance.deploy();
  console.log("Deployed contract address:", deployedContract.address);

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

