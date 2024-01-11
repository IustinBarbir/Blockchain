// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SampleToken.sol";

contract SampleTokenSale {
    SampleToken public tokenContract;
    uint256 public tokenPrice;
    address public owner;

    uint256 public tokensSold;

    event Sell(address indexed _buyer, uint256 indexed _amount);

    constructor(SampleToken _tokenContract, uint256 _tokenPrice) {
        owner = msg.sender;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        require(msg.value == _numberOfTokens * tokenPrice, "Incorrect payment");
        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens, "Insufficient tokens available");

        // Use transferFrom instead of transfer
        require(tokenContract.transferFrom(owner, msg.sender, _numberOfTokens), "Token transfer failed");

        emit Sell(msg.sender, _numberOfTokens);
        tokensSold += _numberOfTokens;
    }

    function endSale() public {
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))), "Transfer failed");
        require(msg.sender == owner, "Unauthorized");

        payable(msg.sender).transfer(address(this).balance);
    }
}
