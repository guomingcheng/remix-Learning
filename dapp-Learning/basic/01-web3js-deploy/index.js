
//引入了三个依赖包
let Web3 = require('web3');                     //作用： 与区块链交互
let solc = require('solc');                     //作用： 编译合约文件
let fs = require('fs');                         //作用： 读取文件中的内容

// 出于安全考虑, 私钥没有进行硬编码, 而是通过环境变量的方式进行获取. 启动测试时, dotenv 插件自动读取 
// .env 配置文件中的配置项, 然后加载为环境变量, 之后在代码中可以通过 process.env 读取私钥 ( 也包括其他环境变量 )
require('dotenv').config();

//读取 .env.example 文件中的 PRIVATE_KEY 值，这个值是账户的私钥
const privatekey = process.env.PRIVATE_KEY;

// 读取 Incrementer.sol 合约文件中的内容，以 uft-8 的格式 
const source = fs.readFileSync('Incrementer.sol', 'utf8');

// 创建一个需要编译的合约的对象。
const input = {
  language: 'Solidity',

  //源文件，文件名称 ==》 文件中的内容
  sources: {
    'Incrementer.sol': {
      content: source,
    },
  }, 
  settings: {
    outputSelection: {
      '*': {
        '*': ['*'],
      },
    },
  },
};

//编译 input 内的合约对象
const tempFile = JSON.parse(solc.compile(JSON.stringify(input)));
//取出一个合约编译对象，因为一个 input 可以包含多个合约文件，每个合约文件也可能包含多个 contract。我们就需要指定那个合约文件中的那个 contract
const contractFile = tempFile.contracts['Incrementer.sol']['Incrementer'];

// 获取 contractFile（Incrementer）合约二进制字节码，这个是用于部署合约到链上使用的
const bytecode = contractFile.evm.bytecode.object;
// 获取 二进制 ABI 接口，这个用于与合约交互用的
const abi = contractFile.abi;

// 创建一个 web3 对象，参数是一个主链或者测试链的网络，web3 交互将都是与这个网络来进行
const web3 = new Web3('https://ropsten.infura.io/v3/' + process.env.INFURA_ID);    //INFURA_ID 值是一个  infura 项目的 ID

// 根据私钥计算出账户地址
const account = web3.eth.accounts.privateKeyToAccount(privatekey);

// 把私密与账户地址封装成一个对象
const account_from = {
  privateKey: privatekey,
  accountAddress: account.address,
};

/*
  创建一个异步部署函数
   -- Deploy Contract --
*/
const Deploy = async () => {
  // 根据 abi 接口获取一个交互的实列
  const deployContract = new web3.eth.Contract(abi);

  // 部署合约的交易, 这里, 此交易还没有发送到区块链网络, 即合约还没有被创建
  const deployTx = deployContract.deploy({
    data: bytecode,                 //合约的字节码
    arguments: [0],                 //合约的构造函数的参数设置 Pass arguments to the contract constructor on deployment(_initialNumber in Incremental.sol)
  });

  console.log(deployTx.encodeABI());

  // 为这笔交易签名
  const deployTransaction = await web3.eth.accounts.signTransaction(
    {
      data: deployTx.encodeABI(),
      gas: 3000000,
    },
    account_from.privateKey
  );

  //发送这笔交易
  const deployReceipt = await web3.eth.sendSignedTransaction(deployTransaction.rawTransaction);

  // Your deployed contrac can be viewed at: https://kovan.etherscan.io/address/${deployReceipt.contractAddress}
  // You can change kovan in above url to your selected testnet.
  console.log(`Contract deployed at address: ${deployReceipt.contractAddress}`);
};

// We recommend this pattern to be able to use async/await everywhere
//函数调用
Deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

