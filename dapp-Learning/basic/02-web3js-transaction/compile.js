const fs = require('fs');
const solc = require('solc');

// 以 utf8 方式加载合约
const source = fs.readFileSync('Incrementer.sol', 'utf8');

// 编译合约
const input = {
  language: 'Solidity',
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

const tempFile = JSON.parse(solc.compile(JSON.stringify(input)));
//获取编译后的 Incrementer 合约对象，
console.log(tempFile);
const contractOfIncrementer = tempFile.contracts['Incrementer.sol']['Incrementer'];

// 导出合约数据，可以使用 console 打印 contractFile 中的具体内容信息
module.exports = contractOfIncrementer;
