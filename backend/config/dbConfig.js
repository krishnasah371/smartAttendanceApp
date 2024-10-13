const mongoose = require('mongoose');
const MONGO_URI = "mongodb+srv://shahkrishna918:smart%40ttendance1234@smartattendancecluster.sox16.mongodb.net/?retryWrites=true&w=majority&appName=smartAttendanceCluster"
const connectDB = async () => {
    try {
        await mongoose.connect(MONGO_URI);
        console.log('MongoDB connected successfully');
    } catch (error) {
        console.error('Database connection error:', error);
        process.exit(1);
    }
};
module.exports = connectDB;
