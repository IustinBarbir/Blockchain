// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SampleToken {
    string public name = "Sample Token";
    string public symbol = "TOK";
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor (uint256 _initialSupply) {
        balanceOf[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function name() public view returns (string memory) {
        return name;
    }

    function symbol() public view returns (string memory) {
        return symbol;
    }

    function decimals() public view returns (uint8) {
        return 18; // Set the number of decimals as needed
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Insufficient allowance");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }
}
