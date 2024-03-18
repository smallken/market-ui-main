// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// import "lib/chainlink/contracts/src/v0.7/interfaces/AggregatorV3Interface.sol";
contract GetPrice {

    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Goerli
     * Aggregator: ETH/USD
     * Address: 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
     */
    constructor() {
        priceFeed = AggregatorV3Interface(0x0715A7794a1dc8e42615F059dD6e406A6594651A);
    }

    /**
     * Returns the latest price
     * TODO: 不知道为什么调用会显示
     * cast call 0xDC3d5BD137a43dD0afC9F49CF5A74f68D8d41dA2  "getLatestPrice()(int)"
        Error: 
        contract 0xdc3d5bd137a43dd0afc9f49cf5a74f68d8d41da2 does not have any code
        后来改了AggregatorV3Interface，换了polygon的测试地址就OK了
     */
    function getLatestPrice() public view returns (int) {
        (
            /*uint80 roundID*/,
            int256 price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }

    
}
