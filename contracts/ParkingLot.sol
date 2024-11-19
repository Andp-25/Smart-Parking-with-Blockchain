// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24; // Ensure to use only 0.4.x
pragma experimental ABIEncoderV2;

contract ParkingLot {
    address public organizer;
    uint public totalSlots;

    struct Vehicle {
        string ownerName;
        string vehicleNumber;
    }

    struct Booking {
        uint slotNumber;
        string date;
        uint timeSlot;
        address owner;
    }

    // Mapping to hold vehicles registered by each address
    mapping(address => Vehicle[]) public registeredVehicles;
    mapping(address => uint) public vehicleCount; // Track vehicle count per user

    // Mapping to store bookings by a unique key (slotNumber + date + timeSlot)
    mapping(bytes32 => Booking) public bookings;

    // Events for logging actions
    event VehicleRegistered(address indexed owner, string ownerName, string vehicleNumber);
    event SlotBooked(address indexed owner, uint slotNumber, string date, uint timeSlot);

    // Constructor
    constructor(uint _totalSlots) public {
        organizer = msg.sender;
        totalSlots = _totalSlots;
    }

    // Register a vehicle
    function registerVehicle(string _ownerName, string _vehicleNumber) public {
        require(bytes(_vehicleNumber).length > 0); // Ensure vehicle number is valid
        require(vehicleCount[msg.sender] < 10); // Limit to 10 vehicles per user

        registeredVehicles[msg.sender].push(Vehicle(_ownerName, _vehicleNumber));
        vehicleCount[msg.sender]++; // Increment vehicle count

        emit VehicleRegistered(msg.sender, _ownerName, _vehicleNumber); // Log registration
    }

    // Delete a vehicle entry by index
    function deleteVehicle(uint _index) public {
        require(_index < vehicleCount[msg.sender]); // Ensure index is valid

        Vehicle[] storage vehicles = registeredVehicles[msg.sender];

        for (uint j = _index; j < vehicles.length - 1; j++) {
            vehicles[j] = vehicles[j + 1];
        }
        vehicles.length--; // Remove last element
        vehicleCount[msg.sender]--; // Decrement vehicle count
    }

    // Get the number of vehicles registered by the user
    function getVehicleCount() public view returns (uint) {
        return vehicleCount[msg.sender];
    }

    // Get vehicle information by index
    function getVehicleByIndex(uint _index) public view returns (string, string) {
        require(_index < vehicleCount[msg.sender]);
        Vehicle memory vehicle = registeredVehicles[msg.sender][_index];
        return (vehicle.ownerName, vehicle.vehicleNumber);
    }

    // Book a parking slot with slot number, date, and timeslot
    function bookSlot(uint _slotNumber, string _date, uint _timeSlot) public {
        require(_slotNumber < totalSlots); // Check for valid slot number
        require(_timeSlot >= 910 && _timeSlot <= 2311); // Validate time slot format

        // Create a unique booking key using slot number and the date & time slot
      
      //****************************************************************
      //  bytes32 bookingKeyactual = keccak256(abi.encodePacked(_slotNumber, _date, _timeSlot));
      //uncomment this line later to implement encyption and decryption logic
        //**************************************************************
        bytes32 bookingKey = keccak256(abi.encodePacked(_slotNumber,  _timeSlot));

        require(bookings[bookingKey].owner == address(0), "Slot already booked"); // Check if the slot is already booked

        // Store the new booking
        bookings[bookingKey] = Booking({
            slotNumber: _slotNumber,
            date: _date,
            timeSlot: _timeSlot,
            owner: msg.sender
        });

        emit SlotBooked(msg.sender, _slotNumber, _date, _timeSlot); // Log booking
    }

    // Utility function to convert uint to string
    function uint2str(uint _i) internal pure returns (string) {
        if (_i == 0) return "0";
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            bstr[--k] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    // Get all bookings
    function getAllBookings() public view returns (uint[] memory, string[] memory, uint[] memory) {
        uint totalBookings = 0;

        // Calculate the total number of bookings first
        for (uint a1 = 0; a1 < totalSlots; a1++) {
            for (uint b1 = 910; b1 <= 2311; b1 += 101) {
                bytes32 bookingKeyTemp = keccak256(abi.encodePacked(a1,  b1)); // Changed bookingKey to bookingKeyTemp

                // Check if the booking exists
                if (bookings[bookingKeyTemp].owner != address(0)) { // Assuming a booking exists if owner is not zero address
                    totalBookings++;
                }
            }
        }

        // Initialize arrays with the total number of bookings found
        uint[] memory slotNumbers = new uint[](totalBookings);
        string[] memory dates = new string[](totalBookings);
        uint[] memory timeSlots = new uint[](totalBookings);
        
        uint bookingCount = 0;

        // Now fill in the actual booking details
        for (uint a = 0; a < totalSlots; a++) {
            for (uint b = 910; b <= 2311; b += 101) {
                bytes32 bookingKey = keccak256(abi.encodePacked(a, b)); // Original bookingKey variable used here

                // Check if the booking exists
                if (bookings[bookingKey].owner != address(0)) {
                    slotNumbers[bookingCount] = a;
                    dates[bookingCount] = bookings[bookingKey].date; // Actual date from booking
                    timeSlots[bookingCount] = b;
                    bookingCount++;
                }
            }
        }

        return (slotNumbers, dates, timeSlots);
    }
}
