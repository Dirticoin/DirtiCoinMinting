const contractName = "DIDToken";

const  basisFeePoint = 10000 / 100;
const taxFees = [
  // { name: "Charity", wallet: "", rate: 1 * basisFeePoint },
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
      ['DirtiCoin', 'DID', '0', taxFees],
      { initializer: 'initialize' }
    );
    console.log(`${contractName} tx:`, contract.deployTransaction.hash);
    await contract.deployed();
    console.log(`${contractName} address:`, contract.address);  
  }
};

module.exports = deployFunction;
module.exports.tags = [contractName];
