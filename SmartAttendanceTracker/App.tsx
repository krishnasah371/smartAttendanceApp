import React from 'react';
import { Platform, View, Text, StyleSheet } from 'react-native';
import WebBluetooth from './src/components/WebBluetooth';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import LoginScreen from './src/components/LoginScreen';
import Home from './src/components/Home';
import AttendanceList from './src/components/AttendanceList';
import BeaconDetection from './src/components/BeaconDetection';
import RegisterScreen from './src/components/RegisterScreen';


// Create a stack navigator
const Stack = createNativeStackNavigator();

const App = () => {
    if (Platform.OS === 'web') {
        return (
            <View>
                <Text>Web Bluetooth Beacon Detection</Text>
                <WebBluetooth />
            </View>
        );
    } else {
        return (
            <NavigationContainer>
                <Stack.Navigator initialRouteName="Login">
                    <Stack.Screen name="Login" component={LoginScreen} options={{ title: 'Student Login' }} />
                    <Stack.Screen name="Register" component={RegisterScreen} options={{ title: 'Register' }} />
                    <Stack.Screen name="Home" component={Home} options={{ title: 'Home' }} />
                    <Stack.Screen name="BeaconDetection" component={BeaconDetection} options={{ title: 'Scan for Attendance' }} />
                    <Stack.Screen name="AttendanceList" component={AttendanceList} options={{ title: 'Attendance Records' }} />
                </Stack.Navigator>
            </NavigationContainer>
        );
    }
};
const styles = StyleSheet.create({
    backgroundContainer: {
        flex: 1,
        backgroundColor: '#f0f0f0', // Light gray background for better contrast
    },
});

export default App;
