// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}


interface IERC20{
    function mint(address _to, uint256 _amount) external  returns(bool);
    function maxSupply() external view returns (uint256);    
}

contract BlockRelease is Ownable{

    using SafeMath for uint256;

    IERC20 private _token;                    //�ͷŵ� ERC20 ���ҵ�ַ  
    
    uint256 private _rewardPerBlock;          //ÿ�������ͷŶ��ٱ�  
    uint256 private _startBlock;              //��¼�����ͷŵ����顣Ĭ�ϲ�����
    uint256 private _bonusEndBlock;           //��������
    uint256 private _count;                   //��¼

    //�����˵�����״̬
    struct Beneficiary{
        uint256 proportion;                       //һ��������� N �����ң���ǰ���������еİٷֱ�3333
        uint256 lastUpdateBlock;                  //�����ȡ�ͷŴ��ҵ�����
        uint256 suspendBlock;                     //ֹͣ����
    }
    mapping(address => Beneficiary) private _beneficiary;           //�����˵�ַ
    mapping(address => bool) private _isBeneficiary;                //�����жϵ�ַ�Ƿ��������� 1 00 00 00 00 00 00 00 00 00

    modifier onlyFiciary(address account){
        require(_isBeneficiary[account], 'BlockRelease: not the address of the beneficiary');
        _;
    }

// 2: 0x7Ce96cA58eD5a3adAc2a8653148FEF567cF5e00A
// 3: 0xbfC89e256EBcC0F5f3467Df4D05e6A3fe4A4998f
// 4: 0x5FB8bEF9257aC977D0D88669F4D642D2050cd584
    constructor(
        IERC20 token, 
        uint256 bonusEndBlock,          //22 500 000
        uint256 rewardPerBlock
    ){
        require(address(token) != address(0), 'BlockRelease: reward token address cannot be empty');
        require(rewardPerBlock > 0, 'BlockRelease: the token released by a block must be greater than 0');

        _token = token;
        _bonusEndBlock = bonusEndBlock;                         //1000000000000000000000000
        _rewardPerBlock = rewardPerBlock  * (10 ** 18);         //200000000000000000
                                                                //6 12 00 00 00 00 00 00 00 00
    }

    function startBlock() public view returns(uint256){ return _startBlock;}
    function bonusEndBlock() public view returns(uint256){ return _bonusEndBlock;}
    function rewardPerBlock() public view returns(uint256){ return _rewardPerBlock;}
    function beneficiarys(address account) public view returns(Beneficiary memory) {return _beneficiary[account];}

    function start() public onlyOwner{
        require(_startBlock == 0, 'BlockRelease: It can only be started once');
        _bonusEndBlock = _bonusEndBlock.add(block.number);
        _startBlock = block.number;
        require(
            _bonusEndBlock.sub(_startBlock).mul(_rewardPerBlock) <= _token.maxSupply() , 
            'BlockRelease: deposit balance first'
            );
    }

    //���������
    //ע��: �ٷֱ����������������67% ����ľ��� 76
    function addBeneficiary(
        address account, 
        uint256 proportion
    ) external onlyOwner{
        require(account != address(0), 'BlockRelease: address cannot be 0');
        require(_count.add(proportion) <= 1000, 'BlockRelease: share ratio must be greater than 0');

        _beneficiary[account] =  Beneficiary(proportion , 0 , 0);
        _isBeneficiary[account] = true;
        _count = _count.add(proportion);
    }

    function reward() external onlyFiciary(_msgSender()){

        uint256 unreleased = earned(_msgSender());
        require(unreleased > 0, 'BlockRelease: the release has not been started');
        if(_beneficiary[_msgSender()].suspendBlock > 0){
            _beneficiary[_msgSender()].lastUpdateBlock = _beneficiary[_msgSender()].suspendBlock;
        }else{
            _beneficiary[_msgSender()].lastUpdateBlock = block.number;
        }
        _token.mint(_msgSender(), unreleased);

    }

    /**
     * ��ѯ����
     * ���� account ���ͷŵĴ���
     **/
    function earned(address account) public view returns(uint256){

        if(_startBlock == 0){
            return 0;
        }else{
            //��ǰ���� - �������� =      �ͷ����� - �����˸������飩 = ���ͷ����� - (���ͷ����� - ����ǰ���� - ��ͣ���飩) * һ�������ͷŶ��ٱ� = �ͷ�����������ٴ��� * �����˵ı��� / 100 = ����ȡ�ͷŴ��ҵķݶ�
            uint256 blockHeigh = block.number <= _bonusEndBlock ? block.number : _bonusEndBlock;                //�߶ȵ�����ֵ����ʱ���ܱȽ����������
           // uint256 differenceHeighe = blockHeigh.sub(_startBlock);                                             //���ͷŴ��ҵ�����ֵ
            uint256 beneficiaryBlock = _beneficiary[account].lastUpdateBlock == 0? blockHeigh.sub(_startBlock) : blockHeigh.sub(_beneficiary[account].lastUpdateBlock);     //�����˿ɵ��ͷ�ֵ

            uint256 suspendBlock = _beneficiary[account].suspendBlock;                                     //ֹͣ�����ֵ����ʱ����
            uint256 proportion = _beneficiary[account].proportion;                                         //��ʱ���� 
            //��� suspendBlock ���� 0���������������ѱ�ֹͣ�ͷŴ���
            beneficiaryBlock = suspendBlock > 0 ? beneficiaryBlock.sub(blockHeigh.sub(suspendBlock)) : beneficiaryBlock;
            uint256 total = beneficiaryBlock.mul(_rewardPerBlock);  
            return total.mul(proportion).div(1000);     
        }
    }
    /**
     * ��ͣ����
     **/
    function suspend(address account) public onlyOwner onlyFiciary(account){
        _beneficiary[account].suspendBlock = block.number;
    }

    /**
     * ȡ������
     **/
    function cancel(address account) public onlyOwner{
        require(_beneficiary[account].suspendBlock > 0, 'BlockRelease: the beneficiary has not been suspended');
        //_beneficiary[account].lastUpdateBlock =  block.number;
        _beneficiary[account].suspendBlock = 0;
    }

    /**
     * �Ѿ�����������
     **/
     function produceBlock() public view returns(uint256){ 
         return _startBlock > 0 ? block.number - _startBlock : 0;
    }

}
