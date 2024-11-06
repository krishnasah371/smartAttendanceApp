import React from 'react';
import { Platform, View, Text } from 'react-native';
import BeaconDetection from './src/components/BeaconDetection';
import WebBluetooth from './src/components/WebBluetooth';

const App = () => {
    if (Platform.OS === 'web') {
        // Render Web Bluetooth detection if running in a web environment
        return (
            <View>
                <Text>Web Bluetooth Beacon Detection</Text>
                <WebBluetooth />
            </View>
        );
    } else {
        // Render Mobile Beacon detection for iOS/Android
        return (
            <BeaconDetection />
        );
    }
};

export default App;
