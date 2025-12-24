pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import qs.Services // For logging or Config if needed (optional)

Singleton {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    
    readonly property bool available: (adapter !== null)
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property bool discovering: adapter?.discovering ?? false
    
    readonly property list<BluetoothDevice> devices: {
        if (!adapter || !adapter.devices) return []
        return adapter.devices.values
    }

    readonly property var connectedDevices: {
        var devs = []
        if (adapter && adapter.devices) {
             var values = adapter.devices.values
             for(var i=0; i<values.length; i++) {
                 if (values[i].connected) devs.push(values[i])
             }
        }
        return devs
    }

    function toggleBluetooth() {
        if (adapter) {
            adapter.enabled = !adapter.enabled
        }
    }

    function setBluetoothEnabled(state) {
        if (adapter) {
            adapter.enabled = state
        }
    }

    function startDiscovery() {
        if (adapter && adapter.enabled) {
            adapter.discovering = true
        }
    }

    function stopDiscovery() {
        if (adapter) {
            adapter.discovering = false
        }
    }

    function connectDevice(device) {
        if (device) device.connect()
    }

    function disconnectDevice(device) {
        if (device) device.disconnect()
    }
    
    function toggleDeviceConnection(device) {
        if (device) {
            if (device.connected) device.disconnect()
            else device.connect()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: false
        onTriggered: {
            if (root.enabled) root.startDiscovery()
        }
    }
    
    Connections {
        target: adapter
        function onEnabledChanged() {
            if (adapter.enabled) root.startDiscovery()
        }
    }
}
