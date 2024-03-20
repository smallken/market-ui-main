import { useState, useEffect } from 'react'
import { ethers } from "ethers";
import erc20TokenAbi from "./abis/erc20TokenAbi.json"

import erc721abi from "./abi/erc721Abi.json";
// import erc721abi from "../out/ERC721/ERC721.sol/ERC721.json";
import erc2612abi from "./abi/erc2612Abi.json";
import nftMarketabi from "./abi/nftmarketAbi.json";

const nftMarketAddress = "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707"
const erc721Address = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"
const erc2612Address = "0x5FbDB2315678afecb367f032d93F642f64180aa3"
// 用anvil本地网络
// 部署合约为：0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266



function NFTMarket() {
    const [erc20Contrct, setErc20Contract] = useState<ethers.Contract | null>(null)
    const [erc721Contract, setErc721Contract] = useState<ethers.Contract | null>(null)
    const [nftContract, setNftContract] = useState<ethers.Contract | null>(null)
    const [signer, setSigner] = useState<ethers.Signer | null>(null)
    const [balance, setBalance] = useState<string>("0")
    const [mintAmount, setMintAmount] = useState<string>("0")

    const [amount, setAmount] = useState<string>("0")
    const [walletAddr, setWalletAddr] = useState<string>("0x0")
    const [erc20Addr, setErc20Arr] = useState<string>("0x0")
    const [contractAddress, setContractAddress] = useState<string>("0x0")
    const [address, setAddress] = useState('');
    const [totalTransfer, setTotalTransfer] = useState('');
    const [nftReceiveAddress, setNftReceiveAddress] = useState<string>("0x0");
    const [tokenURI, setTokenURI] = useState<string>('');
    const [currentAddress, setCurrentAddress] = useState('');
    // const [mockNFTList, setMockNFTList] = useState([]);
    const [mockNFTList, setMockNFTList] = useState<{ id: any; token: any; belongTo: string; isListed: boolean; price: number}[]>([]);
    // const  mockNFTList = [];

    const localNodeUrl = "http://localhost:8545";

    
    useEffect(() => {
        handleConnect();


    }, [])

    const handleConnect = async () => {
        console.log("handleConnect");
        let signerObj: ethers.Signer | null = null;
        let provider: ethers.Provider | null = null;
        if (window.ethereum) {
            // https://rpc.ankr.com/polygon_mumbai
            provider = new ethers.BrowserProvider(window.ethereum);
            // 创建 JsonRpcProvider 提供者
            // provider = new ethers.providers.JsonRpcProvider(localNodeUrl);
            // let currentProvider = new web3.providers.HttpProvider('http://localhost:5173');
            // provider = new ethers.providers.Web3Provider(currentProvider);

            // provider = new ethers.providers.JsonRpcProvider('https://rpc.ankr.com/polygon_mumbai', {
            //     ensAddress: null // 禁用 ENS
            // });
        } else {
            provider = new ethers.BrowserProvider(window.ethereum);
            // provider = new ethers.providers.JsonRpcProvider(localNodeUrl);
        }
        console.log("get provider");
        if (provider == null) {
            console.log("provider is null");
            return;
        }
        signerObj = await provider.getSigner();
        console.log("get signer");
        if (signerObj == null) {
            console.log("signerObj is null");
            return;
        }
        console.log("erc2612Address: " + erc2612Address);
        console.log("signerObj: " + signerObj);
        let erc20ContractObj = new ethers.Contract(erc2612Address, erc2612abi, signerObj);
        let erc721ContractObj = new ethers.Contract(erc721Address, erc721abi, signerObj);
        let nftContractObj = new ethers.Contract(nftMarketAddress, nftMarketabi, signerObj);

        console.log("get erc20ContractObj ok:", erc20ContractObj);
        let walletAddrObj = await signerObj.getAddress();
        console.log("get walletAddrObj from signerObj:" + walletAddrObj);
        let erc20Balance = await erc20ContractObj.balanceOf(walletAddrObj);
        console.log("erc20Balance:", erc20Balance)
        setWalletAddr(walletAddrObj);
        setErc20Contract(erc20ContractObj);
        setErc721Contract(erc721ContractObj);
        setNftContract(nftContractObj);
        setBalance(ethers.formatUnits(erc20Balance, 18));
        // setBalance(erc20Balance);
        console.log("signerObj:", signerObj);
        setSigner(signerObj);
        setCurrentAddress(walletAddrObj);


    }



    const showWallet = async () => {
        console.log("showWallet");
        if (signer == null) {
            console.log("signer is null");
        } else {
            console.log("signer is not null");
            setWalletAddr(await signer?.getAddress());
        }
    }


    // const balanceOfAddress = async () => {
    //     if (signer == null) {
    //         console.log("signer is null");
    //         return;
    //     }

    //     if (erc20Contrct == null) {
    //         console.log("erc20Contrct is null");
    //         return;
    //     }
    //     let erc20Balance = await erc20Contract.balanceOf(walletAddrObj);
    // }


    const mint = async () => {
        
        if (signer == null) {
            console.log("signer is null");
            return;
        }

        if (erc20Contrct == null) {
            console.log("erc20Contrct is null");
            return;
        }

        let tx = await erc20Contrct.mint(walletAddr, ethers.parseUnits(mintAmount, 18));
        console.log(tx);
        await tx.wait();
        setBalance(ethers.formatUnits(await erc20Contrct.balanceOf(walletAddr), 18));
    }

    const transfer = async () => {
        if (erc20Contrct == null) {
            console.log("erc20Contrct is null");
            return;
        }
        // erc20Contrct.approve(address,totalTransfer);
        // 这里不用approve，因为默认单位是wei，所以把输入来的转成wei
        const weiValue = ethers.parseEther(totalTransfer);
        console.log("transefer:", weiValue);
        await erc20Contrct.transfer(address, weiValue);
    }

    const permit = async () => {
        if (erc20Contrct == null) {
            console.log("erc20Contrct is null");
            return;
        }
        // const nonce = await token?.read.nonces([address]);
        // console.log("nonce:" + nonce);
    
        // const deadline = BigInt(Math.floor(Date.now() / 1000) + 100_000);    
        // const amount = parseUnits('1', 18);
    
        // const chainId = await publicClient.getChainId();
        
        // const domainData : TypedDataDomain =  {
        //     name: 'ERC2612',
        //     version: '1',
        //     chainId: chainId,
        //     verifyingContract: erc2612Address
        // }
        // const types = {
        //     Permit: [
        //       {name: "owner", type: "address"},
        //       {name: "spender", type: "address"},
        //       {name: "value", type: "uint256"},
        //       {name: "nonce", type: "uint256"},
        //       {name: "deadline", type: "uint256"}
        //     ]
        // }
    
        // const message = {
        //     owner: address,
        //     spender: tokenBankAddress,
        //     value: amount,
        //     nonce,
        //     deadline
        // }
    
        // const signature = await walletClient.signTypedData({
        //   account: address,
        //   domain: domainData,
        //   types,
        //   primaryType: 'Permit',
        //   message: message,
        // })
    
        // console.log(signature);
    
        // const [r, s, v] = [
        //   slice(signature, 0, 32),
        //   slice(signature, 32, 64),
        //   slice(signature, 64, 65),
        // ];
    
        // const hash = await tokenBank.write.permitDeposit([address, amount, deadline, hexToNumber(v), r, s],   
        //   {account: address})
    
        // console.log(`deposit hash: ${hash} `);
    
        // await publicClient.getTransactionReceipt({
        //   hash: hash
        // })
    
        // refreshDeposited();
        // // erc20Contrct.depoistePermit();
        // signer?.signTypedData();


    }


    const mintNFT = async () => {

        if (erc721Contract == null) {
            console.log("erc20Contrct is null");
            return;
        }
        // 创建过滤器对象,这样获取事件。
        const filter = erc721Contract.filters.MintNFT();
        console.log("erc721contract:", erc721Contract);
        await erc721Contract.mint(nftReceiveAddress, tokenURI);
        // 监听事件
        erc721Contract.on(filter, (result) => {
            // 在事件回调函数中获取返回值
            console.log("result:", result);
            console.log("evetn result.args:", result.args);
            const returnValue = result.args;
            console.log('Event Return Value0:', returnValue[0]);
            console.log('Event Return Value1:', returnValue[1]);

            const newMember = {
                id: mockNFTList.length + 1,
                token: returnValue[0],
                belongTo: nftReceiveAddress,
                isListed: false,
                price: 0,
              };
    
              setMockNFTList([...mockNFTList, newMember]);
            //   setMockNFTList(mockNFTList.push(newMember));
            // mockNFTList.push(newMember);


        });
           
        //   setMockNFTList((mockNFTList) => [...mockNFTList, newMember]);

       
    }
    console.log(mockNFTList)

    const handleBuy = (nftId) => {
        // 处理买入按钮点击事件
        // 在这里编写你的逻辑，例如弹出购买对话框或向后端发送购买请求
        console.log(`Buy NFT ${nftId}`);
    };

    const unList = (nftId) => {
        // 处理上架/下架按钮点击事件
        // 在这里编写你的逻辑，例如向后端发送请求来切换上架状态
        console.log(`Toggled listing for NFT ${nftId}`);
    };

    const onList = (nftId) => {
        // 处理上架/下架按钮点击事件
        // 在这里编写你的逻辑，例如向后端发送请求来切换上架状态
        if (nftContract == null) {
            console.log("nftContract is null");
            return;
        }
        console.log("nft:", mockNFTList[nftId-1])
        console.log("mockNFTList[nftId-1].price:",mockNFTList[nftId-1].price);
        console.log("token:",mockNFTList[nftId-1].token);
        nftContract.onList(mockNFTList[nftId-1].token, mockNFTList[nftId-1].price);
        console.log("nftContract.onList");
    };


    const approve = async () => {
        if (signer == null) {
            console.log("signer is null");
            return;
        }

        if (erc20Contrct == null) {
            console.log("erc20Contrct is null");
            return;
        }

        let tx = await erc20Contrct.approve(NFTMarketArr, ethers.parseUnits(amount, 18));
        console.log(tx);
        await tx.wait();
    }



    return (
        <div>
            <h3>NFTMarket</h3>
            <button onClick={handleConnect}>connect Wallet</button>
            WalletAddr: {walletAddr}
            <br></br>
            balance: {balance}
            <br></br>
            {/* <input type="text" placeholder="enter amount" value={mintAmount} onChange={(event) => setMintAmount(event.target.value)} />
                <button onClick={mint}>mint</button>
                <br></br> */}
            <br></br>
            <input type="text" placeholder="enter amount" value={contractAddress} onChange={(event) => setContractAddress(event.target.value)} />
            <button onClick={transfer}>balance</button>
            <br></br>
            <br></br>
            <div>
                <h2>转账</h2>
                <label>
                    Address:
                    <input type="text" value={address} onChange={(event) => setAddress(event.target.value)} />
                </label>
                <br />
                <label>
                    Amount:
                    <input type="text" value={totalTransfer} onChange={(event) => setTotalTransfer(event.target.value)} />
                </label>
                <br />
                <button onClick={transfer}>Transfer</button>
            </div>
            <br></br>
                <h2>Permit</h2>
                <button onClick={permit}>Permit</button>
            <br></br>
            <h2></h2>
            <h2>Mint NFT</h2>
            <label>
                ReceiveAddress:
                <input type="text" value={nftReceiveAddress} onChange={(event) => setNftReceiveAddress(event.target.value)} />
            </label>
            <br />
            <label>
                tokenURI:
                <input type="text" value={tokenURI} onChange={(event) => setTokenURI(event.target.value)} />
            </label>
            <br />
            <button onClick={mintNFT}>MINT</button>
            <br></br>
            <br></br>

            <h1>NFT Market</h1>
            {mockNFTList.map((nft) => (
                <div key={nft.id}>
                    <p>NftToken:{nft.token.toString()}</p>
                    <p>Holder:{nft.belongTo}</p>
                    {/* {nft.belongTo == currentAddress ? } */}
                    {nft.belongTo === currentAddress ? (
                        nft.isListed ? (
                            <button onClick={() => unList(nft.id)}>下架</button>
                        ) : (
                            // <button onClick={() => onList(nft.id)}>上架</button>
                            <div>
                                <input
                                    type="number"
                                    placeholder="上架价格"
                                    onChange={(event) => {
                                        const price = event.target.valueAsNumber;
                                        // onList(nft.id, price);
                                        nft.price = price;
                                    }}
                                />
                                <button onClick={() => onList(nft.id)}>上架</button>
                            </div>
                        )
                    ) : (
                        <button onClick={() => handleBuy(nft.id)}>买入</button>
                    )}
                </div>
            ))}

        </div>
    )
}


export default NFTMarket;
