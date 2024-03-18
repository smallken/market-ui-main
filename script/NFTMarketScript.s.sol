// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../contract/v2-swap/NFTMarket.sol";

contract NFTMarketScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // NFT nft = new NFT("NFT_tutorial", "TUT", "baseUri");
        // MyEIP2612:
        //0x5FbDB2315678afecb367f032d93F642f64180aa3
        // MyERC721:
        //0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
        // NFTMarket token = new NFTMarket();
        
        vm.stopBroadcast();
    }
}
