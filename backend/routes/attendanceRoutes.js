// routes/attendanceRoutes.js
const express = require('express');
const router = express.Router();

router.post('/attendance', (req, res) => {
    const { beaconId, rssi } = req.body;
    console.log(`Received attendance data: Beacon ID - ${beaconId}, RSSI - ${rssi}`);
    res.status(200).json({ message: "Attendance recorded successfully" });
});

module.exports = router;
