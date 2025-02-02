// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner!= address(0), "Invalid address");
        owner = newOwner;
    }
}

contract PropertyManager is Ownable {
    struct Property {
        uint256 id;
        address owner;
        uint256 price;
        string metadataHash;
        bool isListed;
        bool isVerified;
        uint256 stakedAmount;
    }

    uint256 public propertyCounter;
    mapping(uint256 => Property) public properties;

    event PropertyListed(uint256 indexed id, address owner, uint256 price);
    event PropertyVerified(uint256 indexed id, address verifier);

    function listProperty(uint256 _price, string memory _metadataHash) external payable {
        require(_price > 0, "Price must be greater than 0");
        require(msg.value == 1 ether, "Stake 1 ETH for listing");

        propertyCounter++;
        properties[propertyCounter] = Property({
            id: propertyCounter,
            owner: msg.sender,
            price: _price,
            metadataHash: _metadataHash,
            isListed: true,
            isVerified: false,
            stakedAmount: msg.value
        });

        emit PropertyListed(propertyCounter, msg.sender, _price);
    }

    function verifyProperty(uint256 _id) external onlyOwner {
        Property storage property = properties[_id];
        require(!property.isVerified, "Already verified");
        property.isVerified = true;

        payable(property.owner).transfer(property.stakedAmount);
        property.stakedAmount = 0;

        emit PropertyVerified(_id, msg.sender);
    }
}

contract EscrowManager is PropertyManager {
    struct Escrow {
        address buyer;
        uint256 amount;
        uint256 deadline;
        bool isDisputed;
    }

    mapping (uint256 => Escrow) public escrows;

    event offerMade(uint256 indexed id, address buyer, uint256 amount);
    event DisputedRaised(uint256 indexed id, address party);
    event SettlementCompleted(uint256 indexed id, address buyer, address seller);

    function makeOffer(uint256 _id) external payable {
        Property storage property = properties[_id];

        require(property.isListed, "Property not listed");

        require(msg.value >= property.price,"Insufficient offer amount");

        require(escrows[_id].buyer == address(0), "offer already exists");

        escrows[_id] = Escrow({
            buyer: msg.sender,
            amount: msg.value,
            deadline: block.timestamp + 7 days,
            isDisputed: false
        });
        emit offerMade(_id, msg.sender, msg.value);
    }

    function confirmSale(uint256 _id) external {
       Property storage property = properties[_id];
       require(property.owner == msg.sender, "Not property owner");

       Escrow storage escrow = escrows[_id];
       require(escrow.buyer!= address(0), "Not active offer");
       require(!escrow.isDisputed, "Disputed pending");

        address buyer = escrow.buyer;
        uint256 amount = escrow.amount;

        payable(property.owner).transfer(amount);

        property.owner = buyer;
        property.isListed = false;

        payable (property.owner).transfer(property.stakedAmount);
        property.stakedAmount = 0;

        emit SettlementCompleted(_id, buyer, property.owner);
        delete escrows[_id];

    }

    function raiseDispute(uint256 _id) external {
        require(msg.sender == properties[_id].owner || msg.sender == escrows[_id].buyer, "Not party to transaction");
        escrows[_id].isDisputed = true;

        emit DisputedRaised(_id, msg.sender);
    }    

}

contract RealEstatePlatform is EscrowManager {
    struct RentalAgreement {
        address tenant;
        uint256 rentAmount;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
    }

    mapping (uint256 => RentalAgreement) public rentalAgreements;

    event RentalAgreementCreated(uint256 indexed id, address tenant, uint256 rentAmount);
    event RentalAgreementEnded(uint256 indexed id, address tenant);

    function createdRentalAgreement(
        uint256 _id,
        address _tenant,
        uint256 _rentAmount,
        uint256 _duration
    ) external onlyOwner {
        Property storage property = properties[_id];
        require(property.owner != address(0), "Property does not exist");

        require(rentalAgreements[_id].tenant == address(0), "Rental already active");

        rentalAgreements[_id] = RentalAgreement({
            tenant: _tenant,
            rentAmount: _rentAmount,
            startTime: block.timestamp,
            endTime: block.timestamp + _duration,
            isActive: true
        });

        emit RentalAgreementCreated(_id, _tenant, _rentAmount);
    }

    function endRentalAgreement(uint256 _id) external onlyOwner {
     RentalAgreement storage agreement = rentalAgreements[_id];
        require(agreement.isActive, "Rental not active");
        agreement.isActive = false;
        emit RentalAgreementEnded(_id, agreement.tenant);


    }
}