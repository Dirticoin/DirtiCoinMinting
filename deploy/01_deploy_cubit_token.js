const contractName = "CuBitToken";

const  basisFeePoint = 10000 / 100;
const taxFees = [
  { name: "Aka", wallet: "0xdebA80e48666C77850E1ff58E9f5Ccb5EfB825dc", rate: 0.24 * basisFeePoint },
]

const deployFunction = async ({ getNamedAccounts, deployments, ethers, upgrades }) => {
  const { deploy } = deployments;
  const { root } = await getNamedAccounts();
  const isUpgrading = false;
  
  const Contract = await ethers.getContractFactory(`${contractName}`);
  if (isUpgrading) {
    console.log(`${contractName} upgrading...`);
    const proxyAddress = "";
    const contract = await upgrades.upgradeProxy( proxyAddress, Contract);
    console.log(`${contractName} tx:`, contract.deployTransaction.hash);
    await contract.deployed();
    console.log(`${contractName} address:`, contract.address);
  } else {
    console.log(`${contractName} deploying...`);
    const contract = await upgrades.deployProxy(
      Contract,
      ['UREWSCu', 'CuBit', '0', taxFees],
      { initializer: 'initialize' }
    );
    console.log(`${contractName} tx:`, contract.deployTransaction.hash);
    await contract.deployed();
    console.log(`${contractName} address:`, contract.address);  
  }
};

module.exports = deployFunction;
module.exports.tags = [contractName];

// npx hardhat deploy --network goerli --tags CuBitToken

// goerli: 

// npx hardhat verify --network goerli 