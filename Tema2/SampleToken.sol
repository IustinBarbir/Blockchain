// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SampleToken {
    string public tokenName = "Sample Token";
    string public tokenSymbol = "TOK";
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

    function decimals() public view returns (uint8) {
        return 18;
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

contract SampleTokenSale {
    address public tokenOwner;
    uint256 public salePrice;

    event SalePriceUpdated(uint256 newPrice);

    modifier onlyTokenOwner() {
        require(msg.sender == tokenOwner, "Only token owner can call this function");
        _;
    }

    constructor(address _token, uint256 _initialSalePrice) {
        tokenOwner = msg.sender;
        salePrice = _initialSalePrice;
    }

    function setSalePrice(uint256 _newPrice) public onlyTokenOwner {
        salePrice = _newPrice;
        emit SalePriceUpdated(_newPrice);
    }

    function purchaseTokens(uint256 _amount) public payable {
        require(msg.value >= salePrice * _amount, "Insufficient payment");

        SampleToken tokenContract = SampleToken(msg.sender);
        require(tokenContract.transferFrom(tokenOwner, msg.sender, _amount), "Token transfer failed");

        // Return any excess payment to the buyer
        if (msg.value > salePrice * _amount) {
            payable(msg.sender).transfer(msg.value - salePrice * _amount);
        }
    }
}
