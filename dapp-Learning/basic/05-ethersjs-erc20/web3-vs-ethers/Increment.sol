// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Incrementer {
    uint256 public number;

    event Increment(uint256 value);
    event Descrement(uint256 value);

    event Reset();

    constructor(uint256 _initialNumber) {
        number = _initialNumber;
    }

    function increment(uint256 _value) public {
        require(_value > 0, 'increment value should be positive number');
        number = number + _value;
        emit Increment(_value);
    }

    function descrement(uint256 _value) external {
        require(_value < number, "can't be gretter than current value");
        number = number - _value;
        emit Descrement(_value);
    }

    function reset() public {
        number = 0;
        emit Reset();
    }

    function currentValue() public view returns (uint256) {
        return number;
    }
}
