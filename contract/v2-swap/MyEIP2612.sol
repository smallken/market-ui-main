pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface TokenRecipient {
    function tokensReceived(address sender, uint amount) external returns (bool);
}
contract MyEIP2612 is ERC20Permit{
    constructor(string memory name, string memory symbol) ERC20(name, symbol) ERC20Permit(name) {
        _mint(msg.sender, 1000000 * 10**decimals() );
    }

    function  depoistePermit(
        address owner, 
        address spender, 
        uint value, 
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s ) public{
            
        permit(owner, spender, value, deadline, v, r, s);
        bool ifSucced = transferFrom(owner, spender, value);
        require(ifSucced, "Permit transfer failed!");
    }

    function transferWithCallback(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        require(recipient.code.length > 0, "only contract can use callback!") ;
        bool rv = TokenRecipient(recipient).tokensReceived(msg.sender, amount);
        require(rv, "No tokensReceived");
        return true;
    }

}