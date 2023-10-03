// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

struct RentalInfo {
    address tenant;
    string city;
    string district;
    string neighborhood;
    string street;
    uint256 buildingNo;
    uint256 apartmentNo;
    address owner;
}

struct Contract
{
    RentalInfo rental;
    string startDate;
    string endDate;
}

contract RentalContract
{
    address public contractOwner;
    uint256 public rentalCount;

    RentalInfo[] public rentalPlaces;
    Contract[] public contracts;

    event RentalInfoEvent(address indexed tenant, address indexed owner, string city, string district, string neighborhood, string street, uint256 buildingNo, uint256 apartmentNo, string startDate, string endDate);
    event Termination(address indexed tenant, address indexed owner, string city, string district, string neighborhood, string street, uint256 buildingNo, uint256 apartmentNo);

    modifier onlyContractOwner() {
        require(msg.sender == contractOwner, "Only contract owner");
        _;
    }

    constructor() {
        contractOwner = msg.sender;
        rentalCount = 0;
    }

    function rent(
        address _tenant,
        string memory _city,
        string memory _district,
        string memory _neighborhood, 
        string memory _street,
        uint256 _buildingNo,
        uint256 _apartmentNo,
        address _owner,
        string memory _startDate,
        string memory _endDate
    ) public onlyContractOwner {
        require(_tenant != address(0), "Invalid tenant address");
        require(_owner != address(0), "Invalid owner address");

        RentalInfo memory rental = RentalInfo(_tenant, _city, _district, _neighborhood, _street, _buildingNo, _apartmentNo, _owner);
        rentalPlaces.push(rental);

        Contract memory rentalContract = Contract(rental, _startDate, _endDate);
        contracts.push(rentalContract);

        rentalCount++;

        emit RentalInfoEvent(_tenant, _owner, _city, _district, _neighborhood, _street, _buildingNo, _apartmentNo, _startDate, _endDate);
    }

    function terminate(address _tenant, string memory _city, string memory _district, string memory _neighborhood, string memory _street, uint256 _buildingNo, uint256 _apartmentNo, address _owner) public onlyContractOwner {
        require(_tenant != address(0), "Invalid tenant address");
        require(_owner != address(0), "Invalid owner address");

        bool found = false;
        uint256 index = 0;

        for (uint256 i = 0; i < rentalCount; i++) {
            RentalInfo memory rental = rentalPlaces[i];
            if (
                rental.tenant == _tenant &&
                keccak256(abi.encodePacked(rental.city)) == keccak256(abi.encodePacked(_city)) &&
                keccak256(abi.encodePacked(rental.district)) == keccak256(abi.encodePacked(_district)) &&
                keccak256(abi.encodePacked(rental.neighborhood)) == keccak256(abi.encodePacked(_neighborhood)) &&
                keccak256(abi.encodePacked(rental.street)) == keccak256(abi.encodePacked(_street)) &&
                rental.buildingNo == _buildingNo &&
                rental.apartmentNo == _apartmentNo &&
                rental.owner == _owner
            ) {
                found = true;
                index = i;
                break;
            }
        }

        require(found, "Rental not found");

        delete rentalPlaces[index];
        delete contracts[index];

        rentalCount--;

        emit Termination(_tenant, _owner, _city, _district, _neighborhood, _street, _buildingNo, _apartmentNo);
    }

    function reportIssue(address _tenant, string memory _city, string memory _district, string memory _neighborhood, string memory _street, uint256 _buildingNo, uint256 _apartmentNo, address _owner) public view {
        require(msg.sender == _tenant, "Only tenant can report");
        require(_tenant != address(0), "Invalid tenant address");
        require(_owner != address(0), "Invalid owner address");

        bool found = false;

        for (uint256 i = 0; i < rentalCount; i++) {
            RentalInfo memory rental = rentalPlaces[i];
            if (
                rental.tenant == _tenant &&
                keccak256(abi.encodePacked(rental.city)) == keccak256(abi.encodePacked(_city)) &&
                keccak256(abi.encodePacked(rental.district)) == keccak256(abi.encodePacked(_district)) &&
            
                keccak256(abi.encodePacked(rental.neighborhood)) == keccak256(abi.encodePacked(_neighborhood)) &&
                keccak256(abi.encodePacked(rental.street)) == keccak256(abi.encodePacked(_street)) &&
                rental.buildingNo == _buildingNo &&
                rental.apartmentNo == _apartmentNo &&
                rental.owner == _owner
            ) {
                found = true;
                break;
            }
        }

        require(found, "Rental not found");
    }
}