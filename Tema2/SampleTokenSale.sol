// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SampleToken.sol";

contract SampleTokenSale {
    SampleToken public tokenContract;
    address public owner;
    uint256 public tokenPrice;
    uint256 public tokensSold;

    event Sell(address indexed _buyer, uint256 indexed _amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized");
        _;
    }

    constructor(SampleToken _tokenContract, uint256 _tokenPrice) {
        owner = msg.sender;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
    }

    function setTokenPrice(uint256 _newPrice) public onlyOwner {
        tokenPrice = _newPrice;
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        uint256 totalPrice = _numberOfTokens * tokenPrice;
        require(msg.value >= totalPrice, "Insufficient payment");

        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens, "Insufficient tokens available");

        // Use transferFrom instead of transfer
        require(tokenContract.transferFrom(owner, msg.sender, _numberOfTokens), "Token transfer failed");

        // Refund excess amount
        if (msg.value > totalPrice) {
            payable(msg.sender).transfer(msg.value - totalPrice);
        }

        emit Sell(msg.sender, _numberOfTokens);
        tokensSold += _numberOfTokens;
    }

    function endSale() public onlyOwner {
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))), "Transfer failed");
        payable(owner).transfer(address(this).balance);
    }
}
