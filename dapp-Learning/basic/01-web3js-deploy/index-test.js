import { ChainId, Token, WETH, TokenAmount,Trade, TradeType, Pair, Fetcher, Route } from "@uniswap/sdk";
import { pack, keccak256 } from "@ethersproject/solidity";
import { getCreate2Address } from "@ethersproject/address";
import  web3 from "web3"

const SHIBA = new Token(
  ChainId.MAINNET,
  "0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE",
  18
);  

// 创建一个交易对，SHIBA =》 WETH 的交易对
const SHIBAWETHPair = await Fetcher.fetchPairData(WETH[ChainId.MAINNET],SHIBA);
console.log(SHIBAWETHPair);

// 获取价格：一个 SHIAB 获取多少 WETH
// 获取价格：一个 WETH  获取多少 SHIBA

// 参数一是一个包含 pair 的数组，参数二是目标输出 TOken,


const route = new Route([SHIBAWETHPair], SHIBA);

console.log(route.midPrice.toSignificant(10)); // 比如 SHIB/WETH 交易对，目标 TOken 是 SHIBA, 那么这个数据就是 1 个 SHIAB 能换多少 WETH, 反之亦然
console.log(route.midPrice.invert().toSignificant(6)); // 这个就是 一个 WETH 换多少个 SHIBA

console.log();
console.log("下一个=================================================================================================================")

const USDC = new Token(
  ChainId.MAINNET,
  "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
  6
);
const DAI = new Token(
  ChainId.MAINNET,
  "0x57Ab1ec28D129707052df4dF418D58a2D46d5f51",
  18
);

const USDCWETHPair = await Fetcher.fetchPairData(DAI, WETH[ChainId.MAINNET]);
const DAIUSDCPair = await Fetcher.fetchPairData(DAI, USDC);

// WETH => USDC => DAI
const route2 = new Route([USDCWETHPair], WETH[ChainId.MAINNET]);

console.log(route2.midPrice.toSignificant(6)); // 202.081
console.log(route2.midPrice.invert().toSignificant(6)); // 0.00494851
/// console.log(route2)

console.log();
console.log("下一个=================================================================================================================")

const DAI2 = new Token(
    ChainId.MAINNET,
    "0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE",
    18
  );
  
  // note that you may want/need to handle this async code differently,
  // for example if top-level await is not an option
  const pair = await Fetcher.fetchPairData(DAI2, WETH[DAI2.chainId]);
  
  const route3 = new Route([pair], WETH[DAI2.chainId]);
  
  const trade = new Trade(
    route3,
    new TokenAmount(WETH[DAI.chainId], "20000000000000000000"),
    TradeType.EXACT_INPUT
  );
  
  console.log(trade.executionPrice.toSignificant(6));
  console.log(trade.nextMidPrice.toSignificant(6));

  console.log();
console.log("下一个=================================================================================================================")






// web3.eth.subscribe

// web3.eth.Contract

// web3.eth.personal

// web3.eth.ens

// web3.eth.Iban

// web3.eth.abi
//const account =  web3.eth.accounts.create("guomingcheng");
//console.log(account);

//console.log(web3.eth.abi.encodeFunctionSignature('myMethod(uint256,string)'))