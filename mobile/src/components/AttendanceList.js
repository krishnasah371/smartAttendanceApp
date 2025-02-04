import React, { useEffect, useState } from 'react';
import { View, Text, ScrollView, StyleSheet } from 'react-native';
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

const AttendanceRecordsScreen = () => {
  // State to store fetched attendance records for the logged-in user
  const [attendanceRecords, setAttendanceRecords] = useState([]);

  // Fetch attendance records when the component mounts
  useEffect(() => {
    const fetchAttendance = async () => {
      // Retrieve the authentication token from AsyncStorage, which is unique to each user
      const token = await AsyncStorage.getItem('token');
      try {
        // Send an API request to fetch the user's attendance records, using the token for authentication
        const response = await axios.get('http://192.168.1.243:5001/api/attendance', {
          headers: { Authorization: `Bearer ${token}` },
        });
        // Filter the records to show only those that match the logged-in user (by userId)
        setAttendanceRecords(response.data.filter(record => record.userId === token));
      } catch (error) {
        // Log any errors that occur during the fetch process
        console.error('Error fetching attendance records:', error.message);
        Alert.alert("Error", "Failed to fetch attendance records");
      }
    };

    // Call the fetch function to load attendance records when the component mounts
    fetchAttendance();
  }, []);

  return (
    <ScrollView style={styles.container}>
      {/* Display a message if no attendance records are found */}
      {attendanceRecords.length === 0 ? (
        <Text style={styles.noDataText}>No attendance records found</Text>
      ) : (
        // Map through the attendance records and display each record's details
        attendanceRecords.map((record, index) => (
          <View key={index} style={styles.recordContainer}>
            {/* Show the unique ID of the beacon used for attendance */}
            <Text style={styles.recordText}>Beacon ID: {record.beaconId}</Text>
            {/* Show the signal strength (RSSI) of the beacon at the time of detection */}
            <Text style={styles.recordText}>RSSI: {record.rssi}</Text>
            {/* Display the timestamp of attendance in a readable format */}
            <Text style={styles.recordText}>Timestamp: {new Date(record.timestamp).toLocaleString()}</Text>
          </View>
        ))
      )}
    </ScrollView>
  );
};

// Define styles for the attendance screen components
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#333', // Dark background for better contrast with text
    padding: 10,
  },
  recordContainer: {
    marginBottom: 10,
    padding: 10,
    backgroundColor: '#444', // Slightly lighter background for each record item
    borderRadius: 8,
  },
  recordText: {
    color: '#FFF', // White text for readability against dark background
  },
  noDataText: {
    color: '#FFF', // White text for "no data" message
    fontSize: 16,
    textAlign: 'center',
    marginTop: 20,
  },
});

export default AttendanceRecordsScreen;
