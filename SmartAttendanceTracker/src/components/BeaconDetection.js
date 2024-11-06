import React, { useEffect, useState } from 'react';
import { NativeModules, NativeEventEmitter, Platform, PermissionsAndroid, Text, View } from 'react-native';
import BleManager from 'react-native-ble-manager';
import axios from 'axios';  // Axios to send the data to the backend

// Initialize BLE Manager and Event Emitter for handling BLE events
const BleManagerModule = NativeModules.BleManager;
const bleManagerEmitter = new NativeEventEmitter(BleManagerModule);

// UUID of the target beacon to track
const targetUUID = '4ecad3f3-060a-7295-d6e7-a98142228f72';

const BeaconDetection = () => {
    // State to hold detected beacons
    const [beacons, setBeacons] = useState([]);
    
    // Set to temporarily store detected beacon IDs to prevent duplicate handling within a single scan
    const detectedBeaconIds = new Set();

    useEffect(() => {
        // Start BLE Manager and begin scanning for beacons
        BleManager.start({ showAlert: false }).then(() => {
            console.log("Bluetooth scanning started.");
            startScanning();  // Initial scan on component mount
        });

        // Request location permission for Android, necessary for BLE scanning
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

        // Function to handle each discovered peripheral (or beacon)
        const handleDiscoverPeripheral = (peripheral) => {
            // Check if the peripheral matches the target UUID and hasn't been handled already in this scan session
            if (peripheral.id === targetUUID && !detectedBeaconIds.has(peripheral.id)) {
                console.log('Detected target beacon:', peripheral);
                
                // Add the beacon to detectedBeaconIds to prevent multiple detections of the same beacon
                detectedBeaconIds.add(peripheral.id);

                // Update state with the new beacon, avoiding duplicates
                setBeacons((prevBeacons) => {
                    const exists = prevBeacons.some((b) => b.id === peripheral.id);
                    return exists ? prevBeacons : [...prevBeacons, peripheral];
                });

                // Send beacon data to the backend API for attendance recording
                axios.post('http://192.168.1.243:5001/api/attendance', {
                    beaconId: peripheral.id,
                    rssi: peripheral.rssi,
                })
                .then((response) => {
                    console.log('Attendance recorded:', response.data);
                })
                .catch((error) => {
                    console.error('Error sending beacon data:', error.message);
                });
            }
        };

        // Function to handle stopping of the scan event
        const handleStopScan = () => {
            console.log("Scanning stopped");
            // Clear detectedBeaconIds set to allow detection of the same beacon in the next scan session
            detectedBeaconIds.clear();
        };

        // Listen for 'BleManagerDiscoverPeripheral' event for each detected beacon
        bleManagerEmitter.addListener('BleManagerDiscoverPeripheral', handleDiscoverPeripheral);

        // Listen for 'BleManagerStopScan' event to perform actions after scanning stops
        bleManagerEmitter.addListener('BleManagerStopScan', handleStopScan);

        // Cleanup listeners when component unmounts
        return () => {
            bleManagerEmitter.removeListener('BleManagerDiscoverPeripheral', handleDiscoverPeripheral);
            bleManagerEmitter.removeListener('BleManagerStopScan', handleStopScan);
        };
    }, []);

    // Function to start scanning for beacons
    const startScanning = () => {
        BleManager.scan([], 10, true).then(() => {  // Scans for 10 seconds
            console.log('Scanning for beacons...');
        }).catch((error) => {
            console.error('Error starting scan:', error);
        });
    };

    return (
        <View>
            <Text>Detected Beacons:</Text>
            {/* Render each detected beacon with its name and RSSI (signal strength) */}
            {beacons.map((beacon, index) => (
                <Text key={index}>{beacon.name || 'Unnamed Beacon'} - RSSI: {beacon.rssi}</Text>
            ))}
        </View>
    );
};

export default BeaconDetection;
