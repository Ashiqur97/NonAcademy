// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";

// Include your Ownable and BaseAuction contract definitions above here
contract AdvancedAuction is BaseAuction {
    uint256 public platformFee;
    mapping(address => bool) public blacklist;

    event AddressBlacklisted(address indexed addr, bool blacklisted);

    constructor(uint256 _platformFee) {
        require(_platformFee <= 100, "Fee cannot exceed 100%");
        platformFee = _platformFee;
    }

    function setPlatformFee(uint256 _platformFee) public onlyOwner {
        require(_platformFee <= 100, "Fee cannot exceed 100%");
        platformFee = _platformFee;
    }

    function blacklistAddress(address _address, bool _status) public onlyOwner {
        blacklist[_address] = _status;
        emit AddressBlacklisted(_address, _status);
    }

    function _beforeBid(uint256 _auctionId, address _bidder) internal view {
        require(auctions[_auctionId].endTime > block.timestamp, "Auction has ended");
        require(!blacklist[_bidder], "Address is blacklisted");
    }

    function _handlePlatformFee(uint256 highestBid, address payable seller) internal {
        uint256 fee = (highestBid * platformFee) / 100;
        uint256 sellerAmount = highestBid - fee;

        payable(owner).transfer(fee);
        seller.transfer(sellerAmount);
    }

    function bid(uint256 _auctionId) public payable override {
        _beforeBid(_auctionId, msg.sender);
        super.bid(_auctionId);
    }

    function endAuction(uint256 _auctionId) public override {
        Auction storage auction = auctions[_auctionId];

        require(block.timestamp >= auction.endTime, "Auction has not ended yet");
        require(!auction.ended, "Auction has already ended");
        require(msg.sender == auction.seller, "Only the seller can end the auction");

        auction.ended = true;

        if (auction.highestBid > 0) {
            _handlePlatformFee(auction.highestBid, auction.seller);
            emit AuctionEnded(_auctionId, auction.highestBidder, auction.highestBid);
        }
    }
}
