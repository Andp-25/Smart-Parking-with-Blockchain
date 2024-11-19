const ParkingLot = artifacts.require("ParkingLot");

contract("ParkingLot", accounts => {
    it("should book a slot", async () => {
        const instance = await ParkingLot.deployed();
        await instance.bookSlot(0, "2024-11-01", "9-10", { from: accounts[0] });

        const booking = await instance.getBooking(0);
        assert.equal(booking[0].toString(), "0", "Slot number should be 0");
        assert.equal(booking[1], "2024-11-01", "Date should be 2024-11-01");
        assert.equal(booking[2], "9-10", "Time slot should be 9-10");
        assert.equal(booking[3], accounts[0], "Booked by should be the first account");
    });
});
