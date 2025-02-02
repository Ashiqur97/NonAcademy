const hre = require("hardhat"); 

async function main() {
    const Ownable = await hre.ethers.getContractFactory("Ownable");
    console.log("Deploying Ownable...");
    const ownable = await Ownable.deploy();
    await ownable.waitForDeployment();
    console.log("Ownable deployed to:", await ownable.getAddress());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });