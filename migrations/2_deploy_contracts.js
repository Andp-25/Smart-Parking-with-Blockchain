const ParkingLot = artifacts.require("ParkingLot");

module.exports = function (deployer) {
    const totalSlots = 6; // Change this to the desired number of slots
    deployer.deploy(ParkingLot, totalSlots);
};
