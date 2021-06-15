//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract RPS {
    using Address for address payable;
    mapping(address => uint) private _balances;
    mapping(address => address) private _opponents;
    mapping(address => uint) private _sign;
    uint private _price;

    constructor(uint price_) {
        _price == price_;
    }

    function balance() public view returns (uint) {
        return _balances[msg.sender];
    }

    function deposit() public payable returns(bool) {
        _balances[msg.sender] += msg.value;
        return true;
    }
    function withdraw() public returns (bool) {
        uint amount = _balances[msg.sender];
        _balances[msg.sender] = 0;
        payable(msg.sender).sendValue(amount);
        return true;
    }
    function play(uint sign) public returns (bool) {
        require(_opponents[msg.sender] != address(0));
        require(sign == 1 || sign == 2 || sign == 3);
        _sign[msg.sender] = sign;
        if (_sign[_opponents[msg.sender]] != 0) {
            uint res = _compare(_sign[_opponents[msg.sender]], _sign[msg.sender]);
            if (res == 0) {
                _balances[msg.sender] += _price / 2;
                _balances[_opponents[msg.sender]] += _price / 2;
            } else if (res == 1) {
                _balances[_opponents[msg.sender]] += _price;
            } else if (res == 2) {
                _balances[msg.sender] += _price;
            }
            _sign[_opponents[msg.sender]] = 0;
            _sign[msg.sender] = 0;
            _opponents[_opponents[msg.sender]] = address(0);
            _opponents[msg.sender] = address(0);
        }
        return true;
    }
    function _compare(uint sign1, uint sign2) private pure returns (uint res) {
        if (sign1 == sign2) return 0;
        if (sign1 == 1 && sign2 == 2) return 1;
        if (sign1 == 1 && sign2 == 3) return 2;
        if (sign1 == 2 && sign2 == 1) return 2;
        if (sign1 == 2 && sign2 == 3) return 1;
        if (sign1 == 3 && sign2 == 1) return 1;
        if (sign1 == 3 && sign2 == 2) return 2;
    }
}
