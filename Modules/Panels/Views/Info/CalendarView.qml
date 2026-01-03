import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    
    // Properties to match the theme (mocked or passed)
    property color bg: "#0F0F14" // Dark, similar to Weather card
    property color accent: "#FFB74D" // Orange/Gold for current day
    property color fg: "white"
    
    implicitWidth: 440
    implicitHeight: 140

    // Date Logic
    property var currentDate: new Date()
    property int currentDaySpace: currentDate.getDay() // 0=Sun, 1=Mon...
    property int currentDayMonth: currentDate.getDate()
    
    // Get week start (Monday based for consistency with ref, or locale)
    // Ref image shows Mo Tu We Th Fr Sa Su.
    function getWeekDays() {
        var days = [];
        var d = new Date(currentDate);
        var day = d.getDay();
        // Adjust to make Monday index 0 (if day is 0 (Sun), default logic makes it prev week end)
        var diff = d.getDate() - day + (day === 0 ? -6 : 1); 
        
        var monday = new Date(d.setDate(diff));
        
        for (var i = 0; i < 7; i++) {
            var temp = new Date(monday);
            temp.setDate(monday.getDate() + i);
            days.push({
                "label": temp.toLocaleDateString(Qt.locale(), "ddd").slice(0, 2), // Mo, Tu
                "date": temp.getDate(),
                "isCurrent": temp.getDate() === root.currentDayMonth && temp.getMonth() === root.currentDate.getMonth()
            });
        }
        return days;
    }

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: root.bg
        border.width: 1
        border.color: Qt.rgba(1,1,1,0.05)
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            // Month Label
            Text {
                text: Qt.formatDate(root.currentDate, "MMMM")
                font.pixelSize: 18
                font.bold: true
                color: Qt.rgba(1,1,1,0.6)
            }

            // Days Row
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0
                
                Repeater {
                    model: root.getWeekDays()
                    
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            
                            // Day Name (Mo, Tu)
                            Text {
                                text: modelData.label
                                color: Qt.rgba(1,1,1,0.9)
                                font.pixelSize: 14
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            // Date Circle
                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
                                radius: 18
                                color: modelData.isCurrent ? root.accent : "transparent"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.date
                                    color: modelData.isCurrent ? "black" : Qt.rgba(1,1,1, 0.8)
                                    font.bold: true
                                    font.pixelSize: 14
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
