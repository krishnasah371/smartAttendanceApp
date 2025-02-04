import React, { useEffect, useState } from 'react';
import { NativeModules, NativeEventEmitter, Platform, PermissionsAndroid, Text, View, Button, Alert } from 'react-native';
import BleManager from 'react-native-ble-manager';
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Initialize the BLE manager and set up an event emitter for listening to BLE events
const BleManagerModule = NativeModules.BleManager;
const bleManagerEmitter = new NativeEventEmitter(BleManagerModule);

// Specify the UUID of the target beacon we want to detect
const targetUUID = '4ecad3f3-060a-7295-d6e7-a98142228f72';

const BeaconDetection = ({ navigation }) => {
    // State to hold the list of detected beacons
    const [beacons, setBeacons] = useState([]);
    // State to check if attendance has already been marked for today
    const [attendanceMarked, setAttendanceMarked] = useState(false);
    // Set to store detected beacon IDs temporarily to prevent duplicate processing in a single scan session
    const detectedBeaconIds = new Set();

    useEffect(() => {
        // Start the BLE Manager when the component mounts
        BleManager.start({ showAlert: false }).then(() => {
            console.log("Bluetooth scanning started.");
            startScanning();  // Start scanning immediately after BLE Manager starts
        });

        // Request location permission on Android devices, which is required for BLE scanning
        if (Platform.OS === 'android') {
            PermissionsAndroid.request(
                PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION
            ).then((granted) => {
                if (granted === PermissionsAndroid.RESULTS.GRANTED) {
                    console.log('Location permission granted');
                } else {
                    console.warn('Location permission denied');
                }
            });
        }

        // Function to handle each detected peripheral (beacon)
        const handleDiscoverPeripheral = async (peripheral) => {
            if (peripheral.id === targetUUID && !detectedBeaconIds.has(peripheral.id)) {
                try {
                    // Get token and check if it exists
                    const token = await AsyncStorage.getItem('token');
                    console.log('Token found:', token); // Debug log
        
                    if (!token) {
                        console.error('No token found');
                        Alert.alert(
                            "Authentication Error", 
                            "Please login again",
                            [{ text: "OK", onPress: () => navigation.navigate('Login') }]
                        );
                        return;
                    }
        
                    const response = await axios.post(
                        'http://192.168.1.243:5001/api/attendance',
                        {
                            beaconId: peripheral.id,
                            rssi: peripheral.rssi
                        },
                        {
                            headers: {
                                Authorization: token, // Token already includes 'Bearer '
                                'Content-Type': 'application/json'
                            }
                        }
                    );
                    
                    // Add debug logs
                    console.log('Attendance recorded successfully:', response.data);
                    
                    detectedBeaconIds.add(peripheral.id);
                    Alert.alert(
                        "Success", 
                        response.data.message,
                        [{ text: "OK", onPress: () => navigation.navigate('AttendanceList') }]
                    );
                    setAttendanceMarked(true);
                } catch (error) {
                    console.error('Error details:', error.response?.data || error.message);
                    
                    if (error.response?.status === 401) {
                        const token = await AsyncStorage.getItem('token');
                        console.log('Token that caused 401:', token); // Debug log
                        
                        Alert.alert(
                            "Authentication Error", 
                            "Please login again",
                            [{ text: "OK", onPress: () => {
                                AsyncStorage.removeItem('token'); // Clear invalid token
                                navigation.navigate('Login');
                            }}]
                        );
                    } else if (error.response?.status === 400) {
                        Alert.alert("Already Recorded", error.response.data.message);
                    } else {
                        Alert.alert("Error", "Failed to record attendance");
                    }
                }
            }
        };

        // Function to handle the event when scanning stops
        const handleStopScan = () => {
            console.log("Scanning stopped");
            detectedBeaconIds.clear();  // Clear detected beacon IDs for the next scan session
        };

        // Add event listeners for BLE manager
        const discoverPeripheralListener = bleManagerEmitter.addListener('BleManagerDiscoverPeripheral', handleDiscoverPeripheral);
        const stopScanListener = bleManagerEmitter.addListener('BleManagerStopScan', handleStopScan);

        // Clean up function to remove listeners when component unmounts
        return () => {
            bleManagerEmitter.removeAllListeners('BleManagerDiscoverPeripheral');
            bleManagerEmitter.removeAllListeners('BleManagerStopScan');
        };
    }, [attendanceMarked]);


    // Function to start scanning for beacons
    const startScanning = () => {
        BleManager.scan([], 10, true).then(() => {  // Scan for beacons for 10 seconds
            console.log('Scanning for beacons...');
        }).catch((error) => {
            console.error('Error starting scan:', error);
        });
    };

    // Function to handle the rescan action, allowing the user to re-scan if necessary
    const handleRescan = () => {
        setAttendanceMarked(false);  // Reset attendance marking to allow a new attempt
        startScanning();  // Start a new scan
    };

    return (
        <View>
            <Text>Detected Beacons:</Text>
            {/* Render a list of detected beacons with their name and signal strength (RSSI) */}
            {beacons.map((beacon, index) => (
                <Text key={index}>{beacon.name || 'Unnamed Beacon'} - RSSI: {beacon.rssi}</Text>
            ))}
            {/* Button to allow rescan for attendance */}
            <Button title="Rescan for Attendance" onPress={handleRescan} />
        </View>
    );
};

export default BeaconDetection;
