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
    
    event Deposit(address indexed sender, uint amount);
    event Withdrew(address indexed receiver, uint amount);
    event Played(address indexed p1, address indexed p2, uint s1, uint s2, uint winner);


    constructor(uint price_) {
        _price == price_;
    }

    function balance() public view returns (uint) {
        return _balances[msg.sender];
    }
    function opponent() public view returns (address) {
        return _opponents[msg.sender];
    }

    function deposit() public payable returns(bool) {
        _balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
        return true;
    }
    function withdraw() public returns (bool) {
        uint amount = _balances[msg.sender];
        _balances[msg.sender] = 0;
        payable(msg.sender).sendValue(amount);
        emit Withdrew(msg.sender, amount);
        return true;
    }
    function createParty(address opponent_) public returns (bool) {
        require(opponent() == address(0));
        _opponents[msg.sender] = opponent_;
        return true;
    }
    function joinParty(address opponent_) public returns (bool) {
        require(opponent() == address(0));
        require(_opponents[opponent_] != address(0));
        _opponents[msg.sender] = opponent_;
        return true;
    }
    function leaveParty() public returns (bool) {
        require(opponent() != address(0));
        _opponents[msg.sender] = address(0);
        return true;
    }

    function play(uint sign) public returns (bool) {
        require(opponent() != address(0));
        require(_opponents[opponent()] != address(0));
        require(_balances[msg.sender] >= _price);
        _balances[msg.sender] -= _price;
        require(sign == 1 || sign == 2 || sign == 3);
        _sign[msg.sender] = sign;
        if (_sign[opponent()] != 0) {
            uint res = _compare(_sign[opponent()], _sign[msg.sender]);
            if (res == 0) {
                _balances[msg.sender] += _price;
                _balances[opponent()] += _price;
            } else if (res == 1) {
                _balances[opponent()] += _price * 2;
            } else if (res == 2) {
                _balances[msg.sender] += _price * 2;
            }
            emit Played(opponent(), msg.sender, _sign[opponent()], _sign[msg.sender], res);
            _sign[opponent()] = 0;
            _sign[msg.sender] = 0;
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
