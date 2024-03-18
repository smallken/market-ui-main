// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../contract/v2-swap/MyEIP2612.sol";
import "forge-std/Test.sol";
import "../contract/v2-swap/MyERC721.sol";
import "../contract/v2-swap/NFTMarket.sol";
import "../contract/v2-swap/uniswpV2/UniswapV2Router02.sol";
import "../contract/v2-swap/uniswpV2/UniswapV2Factory.sol";
import "../contract/v2-swap/uniswpV2/WETH9.sol";

contract MyScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // NFT nft = new NFT("NFT_tutorial", "TUT", "baseUri");
        // 0x5FbDB2315678afecb367f032d93F642f64180aa3
        MyEIP2612 token = new MyEIP2612("Dragon", "DRG");
        console.log("token:");
        console.log(address(token));
        MyERC721 erc721token = new MyERC721();
        console.log("erc721token:");
        console.log(address(erc721token));
        //constructor (address nftAddress, address tokenAddress, address uniSwapRouter, 
        //address _WETH, address _linkOracl) 
        WETH9 weth = new WETH9();
        console.log("weth:");
        console.log(address(weth));
        UniswapV2Factory factory = new UniswapV2Factory(msg.sender);
        console.log("factory:");
        console.log(address(factory));
        UniswapV2Router02 router = new UniswapV2Router02(address(factory), address(weth));
        console.log("router:");
        console.log(address(router));
         NFTMarket nftMarket = new NFTMarket(address(erc721token), address(token), address(router), address(weth));
         console.log("nftMarket:");
        console.log(address(nftMarket));
        vm.stopBroadcast();
    }
}
