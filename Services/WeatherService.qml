import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    property string temperature: "24°C"
    property string condition: "Partly Cloudy"
    property string location: "New York, USA"
    property string humidity: "45%"
    property string wind: "12 km/h"
    property string icon: "󰖐" // Nerd Font Icon

    Timer {
        interval: 300000 // 5 mins
        running: true
        repeat: true
        onTriggered: {
            if (root.temperature === "24°C") {
                root.temperature = "23°C";
                root.condition = "Cloudy";
                root.icon = "󰖑";
            } else {
                root.temperature = "24°C";
                root.condition = "Partly Cloudy";
                root.icon = "󰖐";
            }
        }
    }

}
