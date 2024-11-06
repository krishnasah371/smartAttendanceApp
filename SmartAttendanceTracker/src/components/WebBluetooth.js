import React from 'react';

const WebBluetooth = () => {
    const scanForBeacon = async () => {
        try {
            const device = await navigator.bluetooth.requestDevice({
                filters: [{ services: ['battery_service'] }],
            });
            console.log(`Device found: ${device.name}`);
        } catch (error) {
            console.log(`Error: ${error}`);
        }
    };

    return (
        <div>
            <button onClick={scanForBeacon}>Scan for Beacon</button>
        </div>
    );
};

export default WebBluetooth;
