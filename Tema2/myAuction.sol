// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Auction.sol";
import "./sampleToken.sol";
import "./ProductIdentification.sol";

contract MyAuction is Auction {
    SampleToken public tokenContract;
    ProductIdentification public productIdentification;

    constructor (
        uint256 _biddingTime,
        address payable _owner,
        string memory _brand,
        string memory _Rnumber,
        address _tokenContractAddress,
        address _productIdentificationAddress
    ) {
        auction_owner = _owner;
        auction_start = block.timestamp;
        auction_end = auction_start + _biddingTime;
        STATE = auction_state.STARTED;
        Mycar.Brand = _brand;
        Mycar.Rnumber = _Rnumber;

        tokenContract = SampleToken(_tokenContractAddress);
        productIdentification = ProductIdentification(_productIdentificationAddress);
    }

    function bid() public override payable an_ongoing_auction returns (bool) {
        require(productIdentification.productExist(bytes4(keccak256(abi.encodePacked(Mycar.Brand)))), "Brand not registered in ProductIdentification");

        require(tokenContract.transferFrom(msg.sender, address(this), msg.value), "Token transfer failed");

        require(bids[msg.sender] + msg.value > highestBid, "You can't bid, Make a higher Bid");
        highestBidder = msg.sender;
        highestBid = bids[msg.sender] + msg.value;
        bidders.push(msg.sender);
        bids[msg.sender] = highestBid;
        emit BidEvent(highestBidder, highestBid);

        return true;
    }

    function withdraw() public override returns (bool) {
        require(block.timestamp > auction_end || STATE == auction_state.CANCELLED, "You can't withdraw, the auction is still open");
        uint256 amount = bids[msg.sender];
        bids[msg.sender] = 0;

        // Actualizare pentru a utiliza transfer în loc de transferFrom
        payable(msg.sender).transfer(amount);
        emit WithdrawalEvent(msg.sender, amount);

        return true;
    }

    function cancel_auction() external override only_owner returns (bool) {
        require(STATE == auction_state.STARTED, "Auction not started yet");
        STATE = auction_state.CANCELLED;

        // Returnare sume licitate către participanți
        for (uint256 i = 0; i < bidders.length; i++) {
            uint256 amount = bids[bidders[i]];
            bids[bidders[i]] = 0;
            payable(bidders[i]).transfer(amount);
        }

        emit CanceledEvent("Auction cancelled", block.timestamp);
        return true;
    }
}
