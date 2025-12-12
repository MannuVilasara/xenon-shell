import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    property bool isOpen: false
    property var theme
    property bool bluetoothEnabled: false
    property string connectedDevice: ""
    property var globalState
    
    signal close()
    
    // Close bluetooth modal when side panel closes
    Connections {
        target: globalState
        function onSidePanelOpenChanged() {
            if (!globalState.sidePanelOpen) {
                root.isOpen = false
            }
        }
    }
    
    // List available devices
    ListModel {
        id: devicesModel
    }
    
    function updateBluetoothStatus() {
        const result = Process.exec("bluetoothctl", ["show"])
        if (result.exitCode === 0) {
            root.bluetoothEnabled = result.stdout.includes("Powered: yes")
        }
    }
    
    function updateConnectedDevice() {
        const result = Process.exec("bluetoothctl", ["info"])
        if (result.exitCode === 0) {
            const lines = result.stdout.split('\n')
            root.connectedDevice = ""
            for (const line of lines) {
                if (line.includes("Connected: yes")) {
                    // Try to find device name
                    for (const nameLine of lines) {
                        if (nameLine.trim().startsWith("Name:")) {
                            root.connectedDevice = nameLine.split("Name:")[1].trim()
                            break
                        }
                    }
                    break
                }
            }
        }
    }
    
    function scanDevices() {
        // Start scanning
        Process.exec("bluetoothctl", ["scan", "on"])
        
        // Get paired and available devices
        const result = Process.exec("bluetoothctl", ["devices"])
        if (result.exitCode === 0) {
            devicesModel.clear()
            const lines = result.stdout.split('\n').filter(line => line.trim() !== '')
            
            for (const line of lines) {
                if (line.startsWith("Device ")) {
                    const parts = line.split(" ")
                    if (parts.length >= 3) {
                        const address = parts[1]
                        const name = parts.slice(2).join(" ")
                        
                        // Check if connected
                        const infoResult = Process.exec("bluetoothctl", ["info", address])
                        const connected = infoResult.stdout.includes("Connected: yes")
                        const paired = infoResult.stdout.includes("Paired: yes")
                        
                        // Determine device type from name
                        let deviceType = "other"
                        const lowerName = name.toLowerCase()
                        if (lowerName.includes("headphone") || lowerName.includes("earbuds") || lowerName.includes("airpods")) {
                            deviceType = "audio"
                        } else if (lowerName.includes("mouse") || lowerName.includes("keyboard")) {
                            deviceType = "input"
                        } else if (lowerName.includes("phone")) {
                            deviceType = "phone"
                        }
                        
                        devicesModel.append({
                            name: name,
                            address: address,
                            connected: connected,
                            paired: paired,
                            deviceType: deviceType
                        })
                    }
                }
            }
        }
    }
    
    onIsOpenChanged: {
        if (isOpen) {
            updateBluetoothStatus()
            updateConnectedDevice()
            scanDevices()
        } else {
            // Stop scanning when modal closes
            Process.exec("bluetoothctl", ["scan", "off"])
        }
    }
    
    Timer {
        interval: 5000
        running: root.isOpen
        repeat: true
        onTriggered: {
            updateBluetoothStatus()
            updateConnectedDevice()
            scanDevices()
        }
    }
    
    visible: isOpen
    anchors.fill: parent
    enabled: isOpen
    
    Rectangle {
        anchors.fill: parent
        color: theme.bg
        radius: 16
        opacity: root.isOpen ? 1 : 0
        
        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
        
        transform: Translate {
            x: root.isOpen ? 0 : parent.width
            Behavior on x {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }
        }
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {} // Consume clicks to prevent pass-through
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16
            
            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Rectangle {
                    width: 40
                    height: 40
                    color: theme.tile
                    radius: 8
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰂯"
                        font.pixelSize: 20
                        font.family: "Symbols Nerd Font"
                        color: root.bluetoothEnabled ? theme.accent : theme.iconMuted
                    }
                }
                
                Text {
                    text: "Bluetooth"
                    font.pixelSize: 20
                    font.weight: Font.Medium
                    color: theme.text
                    Layout.fillWidth: true
                }
                
                // Toggle Bluetooth
                Rectangle {
                    width: 52
                    height: 30
                    radius: 15
                    color: root.bluetoothEnabled ? theme.accent : theme.tile
                    
                    Rectangle {
                        width: 26
                        height: 26
                        radius: 13
                        color: "white"
                        x: root.bluetoothEnabled ? parent.width - width - 2 : 2
                        y: 2
                        
                        Behavior on x {
                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.bluetoothEnabled) {
                                Process.exec("bluetoothctl", ["power", "off"])
                                root.bluetoothEnabled = false
                            } else {
                                Process.exec("bluetoothctl", ["power", "on"])
                                root.bluetoothEnabled = true
                            }
                        }
                    }
                }
                
                // Close button
                Rectangle {
                    width: 32
                    height: 32
                    color: "transparent"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        font.pixelSize: 18
                        font.family: "Symbols Nerd Font"
                        color: theme.secondary
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.close()
                    }
                }
            }
            
            // Connected device section
            Rectangle {
                Layout.fillWidth: true
                height: 80
                color: theme.tile
                radius: 12
                visible: root.connectedDevice !== ""
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    Rectangle {
                        width: 48
                        height: 48
                        color: theme.surface
                        radius: 8
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰂯"
                            font.pixelSize: 24
                            font.family: "Symbols Nerd Font"
                            color: theme.accent
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Text {
                            text: root.connectedDevice
                            font.pixelSize: 16
                            font.weight: Font.Medium
                            color: theme.text
                        }
                        
                        Text {
                            text: "Connected"
                            font.pixelSize: 13
                            color: theme.secondary
                        }
                    }
                    
                    Text {
                        text: "󰅂"
                        font.pixelSize: 16
                        font.family: "Symbols Nerd Font"
                        color: theme.secondary
                    }
                }
            }
            
            // Available devices header
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                
                Text {
                    text: "Available devices"
                    font.pixelSize: 14
                    color: theme.secondary
                    Layout.fillWidth: true
                }
                
                // Scan button
                Rectangle {
                    width: 70
                    height: 28
                    color: "transparent"
                    
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        
                        Text {
                            text: "󰑓"
                            font.pixelSize: 14
                            font.family: "Symbols Nerd Font"
                            color: theme.accent
                        }
                        
                        Text {
                            text: "Scan"
                            font.pixelSize: 13
                            color: theme.accent
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: scanDevices()
                    }
                }
            }
            
            // Devices list
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                ListView {
                    model: devicesModel
                    spacing: 8
                    
                    delegate: Rectangle {
                        required property string name
                        required property string address
                        required property bool connected
                        required property bool paired
                        required property string deviceType
                        
                        width: ListView.view.width
                        height: 64
                        color: theme.tile
                        radius: 12
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12
                            
                            Text {
                                text: {
                                    if (deviceType === "audio") return "󰋋"
                                    if (deviceType === "input") return "󰌌"
                                    if (deviceType === "phone") return "󰄜"
                                    return "󰂯"
                                }
                                font.pixelSize: 20
                                font.family: "Symbols Nerd Font"
                                color: connected ? theme.accent : theme.text
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                
                                Text {
                                    text: name
                                    font.pixelSize: 14
                                    font.weight: connected ? Font.Medium : Font.Normal
                                    color: theme.text
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: connected ? "Connected" : (paired ? "Paired" : "Not paired")
                                    font.pixelSize: 12
                                    color: theme.secondary
                                }
                            }
                            
                            Text {
                                text: paired ? "󰄲" : ""
                                font.pixelSize: 14
                                font.family: "Symbols Nerd Font"
                                color: theme.secondary
                                visible: paired && !connected
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (connected) {
                                    Process.exec("bluetoothctl", ["disconnect", address])
                                } else if (paired) {
                                    Process.exec("bluetoothctl", ["connect", address])
                                } else {
                                    Process.exec("bluetoothctl", ["pair", address])
                                }
                            }
                        }
                    }
                }
            }
            
            // More settings button
            Rectangle {
                Layout.fillWidth: true
                height: 44
                color: "transparent"
                border.color: theme.accent
                border.width: 1
                radius: 8
                
                Text {
                    anchors.centerIn: parent
                    text: "More settings"
                    font.pixelSize: 14
                    color: theme.accent
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Process.exec("blueman-manager", [])
                    }
                }
            }
        }
    }
}
