pragma solidity ^0.8.13;
// 要有这个IERC721Receiver才能接收
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
// node_modules/@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./uniswpV2/UniswapV2Pair.sol";
import {Test, console} from "forge-std/Test.sol";



interface IMyERC721 {
    function safeTransferFrom(address, address, uint256) external ;
    function ownerOf(uint) external returns (address);
    function approve(address, uint256) external ;
} 
interface IGetPrice {
    function getLatestPrice() external returns(uint);
}
contract NFTMarket is IERC721Receiver{

    IMyERC721 public nft;
    IERC20 public token;
    using SafeERC20 for IERC20; 
    IUniswapV2Router02 public swapRouter;
    address internal immutable WETH;
    address internal linkOracl;
    // using的要for类型
    // 是否上架
    mapping(uint => Status) public isOnSale;
  
    //判断是否存在
    mapping(uint => bool) private tokenExit;
    
    struct  Detail {
        address owner;
        uint256 price;
    }
    mapping(uint => Detail) public list;
    // 分别代表下架，上架，已售
     enum Status {OffSale, OnSale, Sold}
     // NFT交易费
    uint256 constant FEE_RATE = 3;  // 百分之0.3
    uint256 constant FEE_DECIMALS = 1000;  // 小数点位数
    // 字段：总质押量
    uint256 totalDeposit;
    // fee总量
    uint256 totalFee;
    mapping(address => uint) earnToAddress;
    mapping(address => uint) depoisterAmount;
    // 每份E：fee/totalDeposit
    uint EachFeePerStake;
    // 保存eran到数组，以便遍历
    address[] earnList;
    constructor (address nftAddress, address tokenAddress, address uniSwapRouter, address _WETH) {
        nft = IMyERC721(nftAddress);
        token = IERC20(tokenAddress);
        swapRouter = IUniswapV2Router02(uniSwapRouter);
        WETH = _WETH;
        // linkOracl = _linkOracl;
        
    }
    error notOnSaled();
    error isOnSaled();
    error noEnoughBalance();
    error notOwner();
    error noThisNFT();
    // 上架
    function onList(uint tokenID, uint price) public{
        // 上架就是把上架者的地址，tokenID，还有加钱放上去
        // require(nft.ownerOf(tokenID) == msg.sender, "ttt");
        if (isOnSale[tokenID] == Status.OnSale) {
            revert isOnSaled();
        }
        nft.safeTransferFrom(msg.sender,address(this),tokenID);
        // approve获取权限
        nft.approve(msg.sender, tokenID);
        setList(tokenID, msg.sender, price);
        isOnSale[tokenID] = Status.OnSale;
    }

    function setList(uint _token, address owner, uint256 price) public  {
        Detail memory de  =  Detail(owner, price);
        tokenExit[_token] = true;
        list[_token] = de;
    }

    function updateList(uint _token, address changeOwner, uint256 price) public {
        if(tokenExit[_token]){
            Detail memory de  =  Detail(changeOwner, price);
            list[_token] = de;
        }else{
            revert() ;
        }
    }

    // 要有这个方法才不报Contract 'NFTMarket' should be marked as abstract"
    function onERC721Received(
        address /*operator*/,
        address /*from*/,
        uint256 /*tokenId*/,
        bytes calldata  /*data*/
    ) external override pure returns (bytes4) {
      return this.onERC721Received.selector;
    }

    function buyNFT(uint tokenID, uint amount) public {
        uint fee = calculateFee(amount);
        if (isOnSale[tokenID] != Status.OnSale) {
            revert notOnSaled();
        }
        if (!tokenExit[tokenID]) revert noThisNFT();
        // 判断加钱是否少于上架加钱
        if (amount < list[tokenID].price) {
            revert noEnoughBalance();
        }
        nft.safeTransferFrom(address(this), msg.sender, tokenID);
        // 转交易费
        totalFee += fee;
        if (totalDeposit > 0) EachFeePerStake = totalFee / totalDeposit;
        token.approve(address(this), amount);
        token.safeTransferFrom(msg.sender, list[tokenID].owner, amount-fee);
        token.safeTransferFrom(msg.sender, address(this), fee);
        isOnSale[tokenID] = Status.Sold;
        updateList(tokenID, msg.sender, amount);
    }

    function calculateFee(uint256 amount) public pure returns (uint256) {
        uint256 fee = (amount * FEE_RATE) / FEE_DECIMALS;
        return fee;
    }

    // 下架
    function unList(uint tokenID) public{
        if (isOnSale[tokenID] != Status.OnSale) {
            revert notOnSaled();
        }
        // 判断是否Owner
        if (msg.sender != list[tokenID].owner) {
            revert notOwner();
        }
        nft.safeTransferFrom(address(this), msg.sender, tokenID);
        isOnSale[tokenID] = Status.OffSale;
    }

    // function getAmount(uint256 in) public returns(){
    // }
    function swap(address tokenSender, IERC20 tokenIn, uint256 amountIn, uint256 amountOutMin, uint deadline) public 
    returns (uint[] memory amounts) {
        // amountOutMin是前端调了getAmountOut
        // console.log("before swap");
        IERC20(tokenIn).approve(address(this), amountIn);
        IERC20(tokenIn).transferFrom(tokenSender, address(this), amountIn);
        console.log();
        // console.log("after swap");
        address[] memory path;
        // amountOut.mulDiv();
        // 以太转
        // 大概过程是：ETH转到此合约地址，然后再存款，最后再存到Pair对里。
        // 转账这里的逻辑不是太清楚，如果要转ETH,收到确定的token，设置了滑点。这个怎么设？滑点如果是3%，那么就是最少
        // 收到本该收到的+-3%.
        if (address(tokenIn) == WETH) {
            console.log("getIn swap address == weth");
            console.log("contract balance:", IERC20(WETH).balanceOf(address(this)));
            path = new address[](2);
            path[0] = WETH;
            path[1] = address(token);
           amounts = swapRouter.swapExactETHForTokens{value: amountIn}(amountOutMin, path, tokenSender, deadline);
        } else {
            // 币与币转，本该判断是否有path，这里默认没有
            path[0] = address(tokenIn);
            path[1] = WETH;
            path[2] = address(token);
           amounts = swapRouter.swapExactTokensForTokens(amountIn, amountOutMin, path, tokenSender, deadline);
        }
            // amounts = swapRouter.swapTokensForExactTokens(amountOut, amountInMax, path, tokenSender, deadline);
    }

    function buyNftThroughSwap(address tokenSender, IERC20 tokenIn, uint256 amountIn, uint nftID, uint deadline) public {
        // 根据nftID，找到对应的价格，价格就是最低的minAmoutOut
        uint256 amountOutMin = list[nftID].price;
        uint[] memory accoumts = swap(tokenSender, tokenIn, amountIn, amountOutMin, deadline);
        buyNFT(nftID, accoumts[accoumts.length-1]);
         

    }
    function getHash() public returns(bytes32 codeHash){
        bytes32 a = keccak256(type(UniswapV2Pair).creationCode);
        console.log("keccak256");
        console.logBytes32(a);
        return a;
    }

    function depositeEth(uint ethAmount, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address sender , uint deadline) public {
        // 存ETH，获得Fee
        (uint amountToken, uint amountETH, ) = swapRouter.addLiquidityETH{value: ethAmount}(address(token), amountTokenDesired, amountTokenMin, amountETHMin, sender, deadline);
        addDepositCountEarn(amountETH, sender, true);
    }

    function removeEth(uint liquidity, uint amountAMin, uint amountBMin,address to, uint deadline) public {
        (uint amountToken, uint amountETH) = swapRouter.removeLiquidityETH(address(token), liquidity, amountAMin, amountBMin, to, deadline);
        addDepositCountEarn(amountETH, to, false);
    }

    // 提取fee
    function withdrawFee(address withdrawer) public {
        uint acoumtFeeLast = earnToAddress[withdrawer];
        require(acoumtFeeLast > 0, "balance must bigger than 0!");
        token.transferFrom(address(this), withdrawer, acoumtFeeLast);
        earnToAddress[withdrawer] = 0;
        for (uint i = 0; i < earnList.length; i++) {
            if (earnList[i] == withdrawer) {
                earnList[i] == earnList[earnList.length-1];
                earnList.pop();
                break;
            }
        }
    } 
    // 质押和非质押都算用户所得
    function addDepositCountEarn(uint ethAmount, address depositer, bool isCreased) internal{
        if (isCreased) {
            depoisterAmount[depositer] += ethAmount;
        } else {
            depoisterAmount[depositer] -= ethAmount;
        }
        // 遍历Map，把eran都要算出来
        if (totalDeposit > 0 ) EachFeePerStake = totalFee/totalDeposit;
        if (earnList.length > 0 ){
            for (uint i = 0; i < earnList.length; i++) {
                earnToAddress[earnList[i]] += depoisterAmount[earnList[i]] * EachFeePerStake;
            }
        }
    }

    //先不用，不同网络
    // function getPrice() public returns (uint){
    //     uint price = IGetPrice(linkOracl).getLatestPrice();
    //     console.log("price:", price);
    // }

}