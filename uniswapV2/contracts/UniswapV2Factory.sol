pragma solidity =0.5.16;

import './interfaces/IUniswapV2Factory.sol';
import './UniswapV2Pair.sol';

//uniswap工厂
contract UniswapV2Factory is IUniswapV2Factory {

    //包含 0.05% 的协议费用，如果将其打开，则此费用将发送到工厂合约设置的 feeTO 地址

    //如果设置了 feeTo 地址，则协议将开始收取 5 个基点的费用，这是所有流动性提供商赚取 30 个基点的费用 6 分之一。
    //也就是说，交易者的每一笔交易都需要支付 0.30% 的费用。
    //流动性提供商分配 0.30% 中的 83.3%的税费，则剩下的 16.6 将发送到 feeTO 地址

    //在交易时收取这 0.05 的费用会给每笔交易带来额外的 gas 成本，为避免这种情况。就仅在添加与提取流动性时才收取积累费用
    //合约计算累计费用，并在制造或销毁任何 LP 代币之前，立即向 feeTo 地址制造 LP 代币 
    address public feeTo; //收税存放的地址



    address public feeToSetter; //收税权限控制地址
    //配对映射,地址=>(地址=>地址)
    //映射关系：（token0 => token1 => 配对合约的地址）
    mapping(address => mapping(address => address)) public getPair;
    //保存所有配对合约的地址
    address[] public allPairs;
    //配对合约的Bytecode的hash
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(UniswapV2Pair).creationCode));
    //事件:配对被创建
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    /**
     * @dev 构造函数
     * @param _feeToSetter 管理人的地址，拥有的权限是可以设置当前 swap 是否收 0.3% 的税
     * 
     */
    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    /**
     * @dev 获取配对合约数组的长度
     */
    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    /**
     *
     * @param tokenA TokenA
     * @param tokenB TokenB
     * @return pair 配对地址
     * @dev 创建配对
     */
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        //确认tokenA不等于tokenB
        require(tokenA != tokenB, 'UniswapV2: IDENTICAL_ADDRESSES');

        //将tokenA和tokenB进行大小排序,确保tokenA小于tokenB
        //确保了传进来的交易对 ETH/USDT 还是 USDT/ETH, 都转化为固定的一方
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        //确认token0不等于0地址
        //只需要判断 token0 不是零地址即可，因为 token0 是小于 token1 的。当 token0 不是零地址那么 token1 就必定不是零地址
        require(token0 != address(0), 'UniswapV2: ZERO_ADDRESS');
        //确认配对映射中不存在token0=>token1
        //判断当前创建的交易对，还没有存在配对合约。因为不能再创建一个已经存在的配对合约
        require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS'); // single check is sufficient
        //给bytecode变量赋值"UniswapV2Pair"合约的创建字节码
        
        // 获取 UniswapV2Pairr 配对合约编译后的字节码
        // 通过 type() 方法，传入合约的名称，调用 creationCode ，就可以获得 UniswapV2Pair 合约编译后的字节码
        bytes memory bytecode = type(UniswapV2Pair).creationCode;

        //将token0和token1打包后创建哈希
        //运算哈希值，只要是 token0 与 token1, 的值是固定的，那么运算的哈希值 salt 也是固定的
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
       
       
        // 这俩步完成配对合约的部署与初始化
        //内联汇编
        //solium-disable-next-line
        assembly {
            //通过create2方法布署当前交易对的配对合约,并且加盐,返回地址到pair变量
            pair :=  create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        //调用pair地址的合约中的"initialize"方法,传入变量token0,token1
        //调用初始化方法
        IUniswapV2Pair(pair).initialize(token0, token1);

       
       
        //配对映射中设置token0=>token1=pair
        getPair[token0][token1] = pair;
        //配对映射中设置token1=>token0=pair
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        //配对数组中推入pair地址
        allPairs.push(pair);
        //触发配对成功事件
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    /**
     * @dev 设置收税地址
     * @param _feeTo 收税地址
     */
    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeTo = _feeTo;
    }

    /**
     * @dev 收税权限控制
     * @param _feeToSetter 转让管理人的地址
     */
    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}
