// scripts/upgrade_xiroNft.js
const { ethers, upgrades } = require('hardhat');

async function main () {
  const XiroNFT3 = await ethers.getContractFactory('XiroNFT3');
  console.log('Upgrading XiroNFT...');
  await upgrades.upgradeProxy('0xAEdB23fE0Fa0B7eE0FD69606f51388778a41a460', XiroNFT3);
  console.log('XiroNFT upgraded');
}

main();