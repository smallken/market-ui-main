pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface  IMyErc20 {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external  ;
}
contract Bank {
    mapping (address => uint) public depoists;
    address token;
    constructor (address erc20Address) {
        token = erc20Address;
    }

    function dipositTranser(address user, uint value) public {
        ERC20(token).transferFrom(user, address(this), value);
        depoists[user] += value;
    }

    function deposit(uint value) public {
        ERC20(token).transfer(address(this), value);
        depoists[msg.sender] += value;
    }

    function tokensReceived(address sender, uint amount) external returns (bool) {
        require(msg.sender == token, "invalid");
        depoists[sender] += amount;
        return true;
    }

    function tokenPermit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s) external {
            
        ERC20Permit(token).permit(owner, spender, value, deadline, v, r, s);
        ERC20(token).transferFrom(owner, spender, value);
    }
}