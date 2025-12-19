pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property string temperature: "24°C"
    property string condition: "Partly Cloudy"
    property string location: "New York, USA"
    property string humidity: "45%"
    property string wind: "12 km/h"
    property string icon: "󰖐" // Nerd Font Icon
    
    // Mock Update Timer
    Timer {
        interval: 300000 // 5 mins
        running: true
        repeat: true
        onTriggered: {
            // In a real app, fetch API here.
            // For now, toggle between 2 states to show life
            if (root.temperature === "24°C") {
                root.temperature = "23°C"
                root.condition = "Cloudy"
                root.icon = "󰖑"
            } else {
                root.temperature = "24°C"
                root.condition = "Partly Cloudy"
                root.icon = "󰖐"
            }
        }
    }
}
