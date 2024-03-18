pragma solidity ^0.8.13;
// 要有这个IERC721Receiver才能接收
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
// node_modules/@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IMyERC721 {
    function safeTransferFrom(address, address, uint256) external ;
    function ownerOf(uint) external returns (address);
    function approve(address, uint256) external ;
} 
contract NFTMarket is IERC721Receiver{

    IMyERC721 public nft;
    IERC20 public token;
    using SafeERC20 for IERC20; 
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
     // Owner
    //  mapping(uint => address) public owner;
    constructor (address nftAddress, address tokenAddress) {
        nft = IMyERC721(nftAddress);
        token = IERC20(tokenAddress);
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
        // 必须是owner才能够修改
        // 买卖的话可以用ERC721调。但怎么调呢？要用IERC721Receiver
        // IMyERC721(address).safeTransferFrom(from, to, tokenID);
        // require(msg.value > amount, "balance is not enough");
        if (isOnSale[tokenID] != Status.OnSale) {
            revert notOnSaled();
        }
        if (!tokenExit[tokenID]) revert noThisNFT();
        // 判断加钱是否少于上架加钱
        // address originalOwner = nft.ownerOf(tokenID); 
        if (amount < list[tokenID].price) {
            revert noEnoughBalance();
        }
        nft.safeTransferFrom(address(this), msg.sender, tokenID);
        token.approve( list[tokenID].owner, amount);
        // 不用判断是否有足够的ammout，erc20会去判断
        token.safeTransferFrom(msg.sender, list[tokenID].owner, amount);
        isOnSale[tokenID] = Status.Sold;
        // owner[tokenID] = msg.sender;
        updateList(tokenID, msg.sender, amount);
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

    
}