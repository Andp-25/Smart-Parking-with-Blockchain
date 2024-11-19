import '../stylesheets/app.css';
import Web3 from 'web3';
import { default as contract } from 'truffle-contract';

import parkingLot_artifacts from '../../build/contracts/ParkingLot.json';

const ParkingLot = contract(parkingLot_artifacts);

let accounts;
let account;
let parkingLotInstance; // Should be accessible globally
let selectedSlotNumber ; // Changed variable name for consistency
let selectedTimeSlot = "";

// Define the App object
window.App = {
    start: async function () {
        const self = this;

        // Connect to the blockchain and get accounts
        window.web3.eth.getAccounts(function (err, accs) {
            if (err != null) {
                alert("There was an error fetching your accounts.");
                return;
            }
            if (accs.length === 0) {
                alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
                return;
            }

            accounts = accs;
            account = accounts[0];
            self.initContract();
        });
    },

    initContract: async function () { // Make this function async
        const self = this;

        // Set up the contract
        ParkingLot.setProvider(window.web3.currentProvider);

        try {
            parkingLotInstance = await ParkingLot.deployed(); // Get the instance of the deployed contract
            // if(parkingLotInstance)
            // console.log("Sucess");
            self.displayVehicles();
            self.displayBookings();
            self.displayTimeSlots(); // Initialize time slots
        } catch (error) {
            console.error("Error initializing parkingLotInstance:", error);
            alert("Could not initialize the parking lot instance. Please refresh and try again.");
        }
    },

    registerVehicle: async function () {
        const ownerName = document.getElementById("ownerName").value;
        const vehicleNumber = document.getElementById("vehicleNumber").value;

        try {
            await parkingLotInstance.registerVehicle(ownerName, vehicleNumber, { from: account });
            alert("Vehicle registered successfully!");
            this.displayVehicles();
        } catch (error) {
            alert("Error registering vehicle: " + error.message);
            console.error(error);
        }
    },

    deleteVehicle: async function (index) {
        try {
            await parkingLotInstance.deleteVehicle(index, { from: account });
            alert("Vehicle entry deleted successfully!");
            this.displayVehicles();
        } catch (error) {
            alert("Error deleting vehicle entry: " + error.message);
            console.error(error);
        }
    },

    displayVehicles: async function () {
        const vehicleList = document.getElementById("vehicleList");
        vehicleList.innerHTML = ""; // Clear the list

        try {
            const vehicleCount = await parkingLotInstance.getVehicleCount.call({ from: account });

            for (let i = 0; i < vehicleCount; i++) {
                const [ownerName, vehicleNumber] = await parkingLotInstance.getVehicleByIndex(i, { from: account });

                // Create table rows for each registered vehicle
                const row = document.createElement("tr");
                row.innerHTML = `
                    <td>${account}</td>
                    <td>${ownerName}</td>
                    <td>${vehicleNumber}</td>
                    <td><button onclick="App.deleteVehicle(${i})">Delete</button></td>
                `;
                vehicleList.appendChild(row);
            }
        } catch (error) {
            console.error("Error displaying vehicles:", error);
        }
    },

    // Slot selection
    selectSlot: function (slotNumber) {
        selectedSlotNumber = slotNumber;
        const selectedSlotDiv = document.getElementById("selectedSlot");
        selectedSlotDiv.innerHTML = "You selected: Slot " + slotNumber;

        // Highlight selected slot
        const blocks = document.querySelectorAll('.block');
        blocks.forEach(block => block.classList.remove('selected'));
        blocks[slotNumber - 1].classList.add('selected');

        // Show the modal
        document.getElementById("dateModal").style.display = "block";

        // Initialize Flatpickr for date selection
        flatpickr("#datepicker", {
            minDate: "today",
            onChange: function(selectedDates) {
                const selectedDate = selectedDates[0].toLocaleDateString('en-GB');
                selectedSlotDiv.innerHTML = "You selected: Slot " + slotNumber + " for " + selectedDate;
                App.displayTimeSlots(selectedDate);
            }
        });
    },

    displayTimeSlots: function (selectedDate) {
        const timeSlotsContainer = document.getElementById("timeSlotsContainer");
        timeSlotsContainer.innerHTML = "";

        const startHour = 9; // 9 AM
        const endHour = 15; // 3 PM

        for (let hour = startHour; hour < endHour; hour++) {
            const timeSlotDiv = document.createElement("div");
            timeSlotDiv.className = "time-slot";
            timeSlotDiv.innerHTML = `${hour} - ${hour + 1}`;
            timeSlotDiv.onclick = function () {
                App.selectTimeSlot(timeSlotDiv);
            };
            timeSlotsContainer.appendChild(timeSlotDiv);
        }
    },

    selectTimeSlot: function (timeSlotDiv) {
        const timeSlots = document.querySelectorAll('.time-slot');
        timeSlots.forEach(slot => slot.classList.remove('selected'));
        timeSlotDiv.classList.add('selected');
        selectedTimeSlot = timeSlotDiv.innerHTML.replace(" - ", "");
        document.getElementById("selectedSlot").innerHTML += `<br>Time Slot: ${selectedTimeSlot}`;
    },

    bookSlot: async function () {
        // Ensure selectedSlot and selectedTimeSlot are defined
        if (selectedSlotNumber === null || !selectedTimeSlot) {
            alert("Please select a slot and time before booking.");
            return;
        }
    
        let dateInput = document.getElementById("datepicker").value;
        let dateParts = dateInput.split("/");
        let formattedDate = `${dateParts[0]}`; // Format as YYYY-MM-DD
    
        console.log("Booking slot:", selectedSlotNumber, "on date:", formattedDate, "for time slot:", selectedTimeSlot);
    
        try {
            const costInEther = '0.01'; // Set the booking cost (in Ether)
            const weiPerEther = 1000000000000000000; // 10^18
            const costInWei = costInEther * weiPerEther; // Manual conversion to Wei
            
            // Call the bookSlot function on the contract instance
            const result = await parkingLotInstance.bookSlot(selectedSlotNumber, dateInput, selectedTimeSlot, {
                from: account,
                // value: costInWei, // Use the manually converted value
                // gas: 300000 // Adjusting gas limit
            });
            
            alert("Slot booked successfully!");
            this.displayBookings();
        } catch (error) {
            console.error("Error booking slot:", error);
            alert("Error booking slots: " + error.message+selectedSlotNumber+formattedDate+selectedTimeSlot);
        }
    },
    
    
    displayBookings: async function () {
        const bookingList = document.getElementById("bookingList");
        bookingList.innerHTML = ""; // Clear the list

        try {
            const bookingCount = await parkingLotInstance.getBookingCount.call({ from: account });

            for (let i = 0; i < bookingCount; i++) {
                const [slotNumber, date, timeSlot] = await parkingLotInstance.getBookingByIndex(i, { from: account });

                // Create table rows for each booking
                const row = document.createElement("tr");
                row.innerHTML = `
                    <td>${slotNumber}</td>
                    <td>${date}</td>
                    <td>${timeSlot}</td>
                `;
                bookingList.appendChild(row);
            }
        } catch (error) {
            console.error("Error displaying bookings:", error);
        }
    }
};

// Event listener to load the app
window.addEventListener("load", function () {
    if (typeof web3 !== "undefined") {
        window.web3 = new Web3(web3.currentProvider);
    } else {
        window.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"));
    }
    App.start();
});

// Modal close functionality
var modal = document.getElementById("dateModal");
var span = document.getElementById("closeModal");
span.onclick = function() {
    modal.style.display = "none";
}
window.onclick = function(event) {
    if (event.target == modal) {
        modal.style.display = "none";
    }
}
