const ParkingLot = artifacts.require("ParkingLot");

module.exports = function (deployer) {
    // Set the number of parking slots, for example, 10
    const totalSlots = 6; 
    deployer.deploy(ParkingLot, totalSlots);
};
