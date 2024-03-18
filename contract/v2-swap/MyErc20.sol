pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyErc20 is ERC20Permit{
    constructor(string memory name, string memory symbol) ERC20(name, symbol) ERC20Permit(name) {
       
    }

    function mint(address sender, uint amount) public {
         _mint(sender, amount);
    }

}