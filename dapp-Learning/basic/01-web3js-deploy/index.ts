import { ChainId, Token } from "@uniswap/sdk";

const chainId = ChainId.MAINNET;
const tokenAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F"; // DAI,must be checksummed
const decimals = 18; //精度

const DAI = new Token(chainId, tokenAddress, decimals);

console.log(DAI)