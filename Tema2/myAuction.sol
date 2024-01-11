// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Auction.sol";
import "./SampleToken.sol";
import "./ProductIdentification.sol";

contract MyAuction is Auction {
    SampleToken public tokenContract;
    ProductIdentification public productIdentification;

    constructor (
        uint _biddingTime,
        address payable _owner,
        string memory _brand,
        string memory _Rnumber,
        address _tokenContractAddress,
        address _productIdentificationAddress
    ) {
        auction_owner = _owner;
        auction_start = block.timestamp;
        auction_end = auction_start + _biddingTime * 1 hours;
        STATE = auction_state.STARTED;
        Mycar.Brand = _brand;
        Mycar.Rnumber = _Rnumber;

        tokenContract = SampleToken(_tokenContractAddress); // Instantierea
        productIdentification = ProductIdentification(_productIdentificationAddress); // Instantierea
    }

    function bid() public payable an_ongoing_auction override returns (bool) {
        // Actualizare pentru a utiliza transferFrom
        require(tokenContract.transferFrom(msg.sender, address(this), msg.value), "Token transfer failed");

        require(bids[msg.sender] + msg.value > highestBid, "You can't bid, Make a higher Bid");
        highestBidder = msg.sender;
        highestBid = bids[msg.sender] + msg.value;
        bidders.push(msg.sender);
        bids[msg.sender] = highestBid;
        emit BidEvent(highestBidder,  highestBid);

        return true;
    }

    function withdraw() public override returns (bool) {
        require(block.timestamp > auction_end || STATE == auction_state.CANCELLED, "You can't withdraw, the auction is still open");
        uint amount;

        amount = bids[msg.sender];
        bids[msg.sender] = 0;

        // Actualizare pentru a utiliza transfer în loc de transferFrom
        payable(msg.sender).transfer(amount);
        emit WithdrawalEvent(msg.sender, amount);
        return true;
    }

    function destruct_auction() external only_owner returns (bool) {
        require(block.timestamp > auction_end || STATE == auction_state.CANCELLED, "You can't destruct the contract,The auction is still open");
        for (uint i = 0; i < bidders.length; i++) {
            assert(bids[bidders[i]] == 0);
        }

        selfdestruct(auction_owner);
        return true;
    }

    modifier only_registered_product() {
        require(productIdentification.productExist(bytes4(keccak256(abi.encodePacked(Mycar.Brand)))), "Brand not registered in ProductIdentification");
        _;
    }

    function finalizeAuction() external only_owner {
        require(block.timestamp > auction_end, "Auction not yet ended");

        // Verificare dacă există licitatori
        require(bidders.length > 0, "No bids received");

        // Distribuirea tokens în funcție de câștigătorul licitației
        uint totalTokens = highestBid * 100; // Un simplu exemplu, poți ajusta conversia
        require(tokenContract.transfer(highestBidder, totalTokens), "Token transfer failed");

        // Distribuirea sumei către proprietar
        payable(auction_owner).transfer(highestBid);

        // Emiterea unui eveniment pentru încheierea licitației
        emit AuctionEndedEvent(highestBidder, highestBid, block.timestamp);

        // Resetarea stării licitației
        STATE = auction_state.CANCELLED;
    }
    
    // Eveniment pentru încheierea licitației
    event AuctionEndedEvent(address indexed winner, uint256 amount, uint256 endTime);
}
