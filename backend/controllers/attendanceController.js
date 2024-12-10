const Attendance = require('../models/Attendance');

// Function to create a new attendance record
exports.recordAttendance = async (req, res) => {
    try {
        const { beaconId, rssi } = req.body;
        const newRecord = new Attendance({ beaconId, rssi });
        await newRecord.save();
        res.status(201).json({ message: 'Attendance recorded successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to record attendance' });
    }
};

// Function to fetch all attendance records
exports.getAttendanceRecords = async (req, res) => {
    try {
        const records = await Attendance.find().sort({ timestamp: -1 });
        res.json(records);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch attendance records' });
    }
};
