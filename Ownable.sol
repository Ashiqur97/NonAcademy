// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract BaseAuction is Ownable {
    struct Auction {
        address payable seller;
        string itemName;
        uint256 highestBid;
        address highestBidder;
        uint256 endTime;
        bool ended;
    }

    uint256 public auctionCount;
    mapping(uint256 => Auction) public auctions;
    mapping(uint256 => mapping(address => uint256)) public pendingReturns;

    event AuctionCreated(uint256 auctionId, address indexed seller, string itemName, uint256 endTime);
    event NewBid(uint256 auctionId, address indexed bidder, uint256 bidAmount);
    event AuctionEnded(uint256 auctionId, address winner, uint256 finalBid);

    function createAuction(string memory _itemName, uint256 _duration) public {
        require(_duration > 0, "Duration must be greater than 0");

        auctionCount++;
        auctions[auctionCount] = Auction({
            seller: payable(msg.sender),
            itemName: _itemName,
            highestBid: 0,
            highestBidder: address(0),
            endTime: block.timestamp + _duration,
            ended: false
        });

        emit AuctionCreated(auctionCount, msg.sender, _itemName, block.timestamp + _duration);
    }

    function bid(uint256 _auctionId) public payable virtual {
        Auction storage auction = auctions[_auctionId];

        require(block.timestamp < auction.endTime, "Auction has ended");
        require(msg.value > auction.highestBid, "Bid must be higher than the current highest bid");

        // Refund the previous highest bidder
        if (auction.highestBid > 0) {
            pendingReturns[_auctionId][auction.highestBidder] += auction.highestBid;
        }

        // Update highest bid
        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;

        emit NewBid(_auctionId, msg.sender, msg.value);
    }

    function withdraw(uint256 _auctionId) public {
        uint256 amount = pendingReturns[_auctionId][msg.sender];
        require(amount > 0, "No funds to withdraw");

        pendingReturns[_auctionId][msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function endAuction(uint256 _auctionId) public virtual {
        Auction storage auction = auctions[_auctionId];

        require(block.timestamp >= auction.endTime, "Auction has not ended yet");
        require(!auction.ended, "Auction has already ended");
        require(msg.sender == auction.seller, "Only the seller can end the auction");

        auction.ended = true;

        if (auction.highestBid > 0) {
            auction.seller.transfer(auction.highestBid);
        }

        emit AuctionEnded(_auctionId, auction.highestBidder, auction.highestBid);
    }
}
