// SPDX-License-Identifier: MIT
pragma solidity ^0.4.4;

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
        string timeSlot;
        address owner;
    }

    // Mapping to hold vehicles registered by each address
    mapping(address => Vehicle[]) public registeredVehicles;
    mapping(address => uint) public vehicleCount; // Track vehicle count per user

    // Mapping to store bookings by a unique key (slotNumber + date + timeSlot)
    mapping(bytes32 => Booking) public bookings;

    // Events for logging actions
    event VehicleRegistered(address indexed owner, string ownerName, string vehicleNumber);
    event SlotBooked(address indexed owner, uint slotNumber, string date, string timeSlot);

    // Constructor
    function ParkingLot(uint _totalSlots) public {
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
    function bookSlot(uint _slotNumber, string _date, string _timeSlot) public {
        require(_slotNumber < totalSlots); // Check for valid slot number

        // Create a unique booking key using slot number, date, and time slot
        bytes32 bookingKey = keccak256(abi.encodePacked(_slotNumber, _date, _timeSlot));
        require(bookings[bookingKey].owner == address(0)); // Check if the slot is already booked

        // Store the new booking
        bookings[bookingKey] = Booking({
            slotNumber: _slotNumber,
            date: _date,
            timeSlot: _timeSlot,
            owner: msg.sender
        });

        emit SlotBooked(msg.sender, _slotNumber, _date, _timeSlot); // Log booking
    }

    // Check if a slot is already booked
    function isSlotBooked(uint _slotNumber, string _date, string _timeSlot) public view returns (bool) {
        bytes32 bookingKey = keccak256(abi.encodePacked(_slotNumber, _date, _timeSlot));
        return bookings[bookingKey].owner != address(0);
    }

    // Get booking details by slot number, date, and timeslot
    function getBooking(uint _slotNumber, string _date, string _timeSlot) public view returns (address, string, string) {
        bytes32 bookingKey = keccak256(abi.encodePacked(_slotNumber, _date, _timeSlot));
        Booking memory booking = bookings[bookingKey];
        require(booking.owner != address(0)); // Ensure booking exists
        return (booking.owner, booking.date, booking.timeSlot);
    }
}
