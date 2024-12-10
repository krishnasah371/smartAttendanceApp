const mongoose = require('mongoose');

const attendanceSchema = new mongoose.Schema({
    beaconId: {
        type: String,
        required: true,
    },
    rssi: {
        type: Number,
        required: true,
    },
    timestamp: {
        type: Date,
        default: Date.now,
    },
    userId:{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    }
});

module.exports = mongoose.model('Attendance', attendanceSchema);
