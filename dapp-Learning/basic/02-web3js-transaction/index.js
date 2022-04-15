const Web3 = require('web3');
const fs = require('fs');

//合约文件被编译后的对象，这个对象中包含着二机制字节码于 ABI
const contractOfIncrementer = require('./compile');

require('dotenv').config();
const privatekey = process.env.PRIVATE_KEY;

/*
   -- Define Provider --
*/
// 构建 web3 对象，ProviderRPC 是设置 web3 交互的网络
const providerRPC = {
  development: 'https://kovan.infura.io/v3/' + process.env.INFURA_ID
};
const web3 = new Web3(providerRPC.development); //Change to correct network

// 根据私钥推导出账户地址
const account = web3.eth.accounts.privateKeyToAccount(privatekey);
// 封装成一个对象
const account_from = {
  privateKey: privatekey,
  accountAddress: account.address,
};

// 在部署合约的时候，需要用到俩个重要的参数，就是合约对于的 bytecode 与 abi。可以从 contractOfIncrementer 编译后的二进制对象取出 二机制字节码 与 Abi 接口
const bytecode = contractOfIncrementer.evm.bytecode.object;
const abi = contractOfIncrementer.abi;

/*
*
*
*   -- Verify Deployment --
*

*/
const Trans = async () => {
  console.log('============================ 1. Deploy Contract');
  console.log(`Attempting to deploy from account ${account.address}`);

  //根据 ABI 接口构建合约的实列
  const deployContract = new web3.eth.Contract(abi);

  // 创建合约交易
  // 调用 deployContract.deploy 接口，我们创建了部署合约的二机制交易，这里，此交易还没有发送到区块链的网络
  const deployTx = deployContract.deploy({
    data: bytecode,     //部署合约的交易，需要传入编译合约后二进制字节码
    arguments: [5],     //这是往构造函数传入的参数
  });


  // 为这笔交易签名
  const createTransaction = await web3.eth.accounts.signTransaction(
    {
      data: deployTx.encodeABI(),
      gas: 8000000,                     //gas 的多少
    },
    account_from.privateKey             //签名需要私钥
  );

  // 部署合约， 使用 sendSignedTransaction 接口发送签名后的交易
  // 这里使用发送签名后的交易到区块链网络，同时会返回交易的回执，从返回的交易返回中可以得到此次部署合约的地址
  const createReceipt = await web3.eth.sendSignedTransaction(
    createTransaction.rawTransaction
  );
  console.log(`Contract deployed at address: ${createReceipt.contractAddress}`);

  const deployedBlockNumber = createReceipt.blockNumber;

  /*
   *
   *
   *
   * -- Verify Interface of Increment --
   *
   *
   */
  // Create the contract with contract address
  console.log();
  console.log(
    '============================ 2. Call Contract Interface getNumber'
  );
  // 通过已经部署的合约地址加载与链上交互合约的实列
  // 1.上述，我们是先构造了一个合约实列，然后再通过发送合约部署交易，实现合约实列上链，以便后续进行相应的交易操作。
  // 2.但同时，我们也可以直接加载一个已经上链的合约实列，这样就可以直接对合约进行操作，避免了中间部署的过程
  let incrementer = new web3.eth.Contract(abi, createReceipt.contractAddress);

  console.log(
    `Making a call to contract at address: ${createReceipt.contractAddress}`
  );

  // 调用合约的只读接口
  // 不管是通过部署创建的合约实列，还是通过加载已经部署的合约创建的合约实列，再拥有一个已经上链的合约实列后，就可以和合约进行交互
  // 合约接口分为只读和交易接口，其中只读接口不会修改区块的数据，而交易接口调用会在区块链网络上修改了数据，调用合约的 getNumber 接口后
  // 获取合约中的公共变量 number　的数值
  // .call() 就会发送了这笔交易，这样是能用于只读方法，应为写入方法需要签名才可以
  let number = await incrementer.methods.getNumber().call();
  // number 就是返回来的值
  console.log(`The current number stored is: ${number}`);

  // Add 3 to Contract Public Variable
  
  console.log();
  console.log(
    '============================ 3. Call Contract Interface increment'
  );
  const _value = 3;
  
  // 写入方法调用需要先构造交易
  let incrementTx = incrementer.methods.increment(_value);

  // 为这笔交易签名
  let incrementTransaction = await web3.eth.accounts.signTransaction(
    {
      to: createReceipt.contractAddress,     //合约地址
      data: incrementTx.encodeABI(),         //这笔交易的字节码，等价于合约中的 abi.encodeWithSignature("increment(uint256)", _value) 函数
      gas: 8000000,
    },
    account_from.privateKey
  );

  // 发送交易
  const incrementReceipt = await web3.eth.sendSignedTransaction(
    incrementTransaction.rawTransaction
  );

  // incrementReceipt.transactionHash 就这笔交易的哈希值
  console.log(`Tx successful with hash: ${incrementReceipt.transactionHash}`);

  number = await incrementer.methods.getNumber().call();
  console.log(`After increment, the current number stored is: ${number}`);

  /*
   *
   *
   *
   * -- Verify Interface of Reset --
   *
   *
   */
  console.log();
  console.log('============================ 4. Call Contract Interface reset');
  const resetTx = incrementer.methods.reset();

  const resetTransaction = await web3.eth.accounts.signTransaction(
    {
      to: createReceipt.contractAddress,
      data: resetTx.encodeABI(),
      gas: 8000000,
    },
    account_from.privateKey
  );

  const resetcReceipt = await web3.eth.sendSignedTransaction(
    resetTransaction.rawTransaction
  );
  console.log(`Tx successful with hash: ${resetcReceipt.transactionHash}`);
  number = await incrementer.methods.getNumber().call();
  console.log(`After reset, the current number stored is: ${number}`);

  /*
   *
   *
   *
   * -- Listen to Event Increment --
   *
   *
   */
  console.log();
  console.log('============================ 5. Listen to Events');
  console.log(' Listen to Increment Event only once && continuouslly');

  // kovan don't support http protocol to event listen, need to use websocket
  // more details , please refer to  https://medium.com/blockcentric/listening-for-smart-contract-events-on-public-blockchains-fdb5a8ac8b9a
  // 监听事件
  // 在合约接口调用中，除了接口返回的结果外，唯一能获取接口处理信息的方法便是交易的事件
  // , 在接口中，通过触发一个事件，然后再外部捕获区块产生的事件，就可以获取到相应的内部信息
  const web3Socket = new Web3(
    new Web3.providers.WebsocketProvider(
      'wss://kovan.infura.io/ws/v3/' + process.env.INFURA_ID
    )
  );
  incrementer = new web3Socket.eth.Contract(abi, createReceipt.contractAddress);

  // 定义一个一次性的事件
  // 在合约中，第一次触发了 Increment 事件时，会回调这个方法，但是再次触发就不回调，所有也称为一次性事件
  incrementer.once('Increment', (error, event) => {
    console.log('I am a onetime event listner, I am going to die now');
  });

  // 定义持续性事件
  // 在合约中，无论触发了多少次 Increment 的事件，都会回调这个方法
  incrementer.events.Increment(() => {
    console.log('I am a longlive event listner, I get a event now-------------------------------------------------');
  });

  // 发送交易触发事件
  for (let step = 0; step < 5; step++) {
    incrementTransaction = await web3.eth.accounts.signTransaction(
      {
        to: createReceipt.contractAddress,
        data: incrementTx.encodeABI(),
        gas: 8000000,
      },
      account_from.privateKey
    );

    await web3.eth.sendSignedTransaction(incrementTransaction.rawTransaction);

    if (step == 4) {
      // 清除所有的事件监听
      web3Socket.eth.clearSubscriptions();
      console.log('Clearing all the events listeners !!!!');
    }
  }

  /*
   *
   *
   *
   * -- Get past events --
   *
   *
   */
  console.log();
  console.log('============================ 6. Going to get past events');

  // 获取触发的事件
  // 获取在 deployedBlockNumber 这个区块触发了 Increment 的事件
  const pastEvents = await incrementer.getPastEvents('Increment', {
    fromBlock: deployedBlockNumber,
    toBlock: 'latest',
  });

  pastEvents.map((event) => {
    //遍历事件对象
    // console.log(event);
  });

  /*
   *
   *
   *
   * -- Check Transaction Error --
   *
   *
   */
  console.log();
  console.log('============================ 7. Check the transaction error');
  incrementTx = incrementer.methods.increment(1);
  incrementTransaction = await web3.eth.accounts.signTransaction(
    {
      to: createReceipt.contractAddress,
      data: incrementTx.encodeABI(),
      gas: 8000000,
    },
    account_from.privateKey
  );

  //我们发送一条交易时，可以在后面 .on 来监听这条交易的状态
  await web3.eth
    .sendSignedTransaction(incrementTransaction.rawTransaction)
    .on('error', console.error)    //合约发生错误就回调这个函数
    .on('confirmation', function(confNumber, receipt){
      console.log("--------------------------------------------------------------------");
      console.log(confNumber);
      console.log(receipt);       //这笔交易的信息
    })
    .once("transactionHash", function(hash){
      console.log(hash);
    })
    .once("receipt", function(receipt){   //交易完成回调这个方法
      console.log(receipt);
    })
    
};

Trans()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
