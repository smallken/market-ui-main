pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./MyErc20.sol";

contract Mining {
    MyErc20 public token;
    using SafeERC20 for IERC20; 
    uint256 lastBlockNumber;
    address internal immutable WETH;
    IUniswapV2Router02 public swapRouter;
    uint256 totalStake;
    struct AccountMintToken {
        uint accountStakeAmount;
        uint accountBlock;
        uint earn;
    }
    mapping(address => AccountMintToken) accountToStruct; 
    address[] listAccounts;
     constructor (address tokenAddress, address _WETH, address uniSwapRouter) {
        token = MyErc20(tokenAddress);
        WETH = _WETH;
        lastBlockNumber = block.number;
        swapRouter = IUniswapV2Router02(uniSwapRouter);
    }

    // 质押ETH获得token,每个区块得到10个token
     function depositeEth(uint ethAmount, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address sender , uint deadline) public {
        // 存ETH，获得Fee
      (uint amountToken, uint amountETH, ) =  swapRouter.addLiquidityETH{value: ethAmount}(address(token), amountTokenDesired, amountTokenMin, amountETHMin, sender, deadline);
        if (accountToStruct[sender].accountStakeAmount == 0 && accountToStruct[sender].accountBlock == 0) {
            AccountMintToken memory account;
            account.accountBlock = block.number;
            account.accountStakeAmount = amountETH;
            accountToStruct[sender] = account;
            listAccounts.push(sender);
        } else {
            caculateEarn();
            accountToStruct[sender].accountStakeAmount += ethAmount;
        }
    }

    function removeEth(uint liquidity, uint amountAMin, uint amountBMin,address to, uint deadline) public {
        (uint amountToken, uint amountETH) = swapRouter.removeLiquidityETH(address(token), liquidity, amountAMin, amountBMin, to, deadline);
        caculateEarn();
        accountToStruct[to].accountBlock = 0;

    }
    function caculateEarn() internal {
        for (uint i = 0; i < listAccounts.length; i++) {
             AccountMintToken storage a = accountToStruct[listAccounts[i]];
             a.earn = (block.number - a.accountBlock) * 10 / totalStake * a.accountStakeAmount;
             a.accountBlock = block.number;
        }
    }

    function withdrawToken(address sender) public {
        AccountMintToken storage a = accountToStruct[sender];
        token.mint(sender, a.earn);
        a.earn = 0;
    }



}