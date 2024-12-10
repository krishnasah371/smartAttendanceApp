const express = require('express');
const router = express.Router();
const Attendance = require('../models/Attendance');
const authMiddleware = require('../middleware/authMiddleware'); 

router.post('/attendance', authMiddleware, async (req, res) => {
    const { beaconId, rssi } = req.body;
    const userId = req.user.id; // Getting userId from authMiddleware 

    try {
        // Check if user has already marked attendance today
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        
        const tomorrow = new Date(today);
        tomorrow.setDate(tomorrow.getDate() + 1);

        const existingAttendance = await Attendance.findOne({
            userId,
            timestamp: {
                $gte: today,
                $lt: tomorrow
            }
        });

        if (existingAttendance) {
            return res.status(400).json({ 
                message: "You have already recorded your attendance for today" 
            });
        }

        // Save new attendance record
        const newRecord = new Attendance({
            userId,
            beaconId,
            rssi
        });
        await newRecord.save();
        
        res.status(201).json({ 
            message: "Attendance recorded successfully",
            timestamp: newRecord.timestamp
        });
    } catch (error) {
        console.error('Error saving attendance record:', error);
        res.status(500).json({ error: 'Failed to record attendance' });
    }
});

// Get attendance records for logged-in user
router.get('/attendance', authMiddleware, async (req, res) => {
    try {
        const records = await Attendance.find({ 
            userId: req.user.id 
        }).sort({ timestamp: -1 });
        
        res.status(200).json(records);
    } catch (error) {
        console.error('Error fetching attendance records:', error);
        res.status(500).json({ error: 'Failed to fetch attendance records' });
    }
});

module.exports = router;
