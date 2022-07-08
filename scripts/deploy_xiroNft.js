// scripts/deploy_xiroNft.js
const { ethers, upgrades } = require('hardhat');

async function main () {
  const XiroNFT = await ethers.getContractFactory('XiroNFT');
  console.log('Deploying XiroNFT...');
  const xiroNFT = await upgrades.deployProxy(XiroNFT, [], { initializer: 'initialize', kind:'uups' });
  await xiroNFT.deployed();
  console.log('XiroNFT deployed to:', xiroNFT.address);
}

main();