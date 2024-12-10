import React from 'react';
import { View, Button, StyleSheet } from 'react-native';

const Home = ({ navigation }) => {
    return (
        <View style={styles.container}>
            <Button title="Scan for Attendance" onPress={() => navigation.navigate('BeaconDetection')} />
            <Button title="View Attendance Records" onPress={() => navigation.navigate('AttendanceList')} />
        </View>
    );
};

const styles = StyleSheet.create({
    container: { flex: 1, justifyContent: 'center', backgroundColor: '#f0f0f0', alignItems: 'center' },
});

export default Home;
