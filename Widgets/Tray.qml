import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

RowLayout {
    id: trayRoot
    
    spacing: 6
    
    // Configuration properties
    property color borderColor: "#ffffff"
    property color itemHoverColor: "#89b4fa"
    property int iconSize: 16
    property var pinnedApps: []  // Array of app names to always show
    property var blacklist: []   // Array of app names to hide
    property bool hidePassive: false  // Hide passive status items
    
    // Filter tray items
    property var visibleItems: {
        var items = SystemTray.items.values || []
        return items.filter(item => {
            // Hide blacklisted apps
            if (blacklist.some(name => item.id.toLowerCase().includes(name.toLowerCase()))) {
                return false
            }
            
            // Hide passive items if enabled
            if (hidePassive && item.status === SystemTrayStatus.Passive) {
                return false
            }
            
            return true
        })
    }
    
    // Monitor changes to SystemTray items
    Connections {
        target: SystemTray.items
        function onValuesChanged() {
            trayRoot.visibleItems = Qt.binding(() => {
                var items = SystemTray.items.values || []
                return items.filter(item => {
                    if (blacklist.some(name => item.id.toLowerCase().includes(name.toLowerCase()))) {
                        return false
                    }
                    if (hidePassive && item.status === SystemTrayStatus.Passive) {
                        return false
                    }
                    return true
                })
            })
        }
    }
    
    // Display tray icons
    Repeater {
        model: trayRoot.visibleItems
        
        Rectangle {
            Layout.preferredWidth: trayRoot.iconSize + 8
            Layout.preferredHeight: trayRoot.iconSize + 8
            radius: 4
            color: itemMouseArea.containsMouse ? Qt.rgba(itemHoverColor.r, itemHoverColor.g, itemHoverColor.b, 0.2) : "transparent"
            
            Image {
                id: trayIcon
                anchors.centerIn: parent
                width: trayRoot.iconSize
                height: trayRoot.iconSize
                source: modelData.icon || ""
                fillMode: Image.PreserveAspectFit
                smooth: true
                
                // Fallback if icon doesn't load
                visible: status === Image.Ready || status === Image.Loading
            }
            
            // Fallback text if icon fails
            Text {
                anchors.centerIn: parent
                text: trayIcon.status === Image.Error ? "?" : ""
                color: borderColor
                font.pixelSize: 10
                visible: trayIcon.status === Image.Error
            }
            
            MouseArea {
                id: itemMouseArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        modelData.activate()
                    } else if (mouse.button === Qt.MiddleButton) {
                        modelData.secondaryActivate()
                    } else if (mouse.button === Qt.RightButton) {
                        if (modelData.hasMenu && modelData.menu) {
                            modelData.menu.open()
                        }
                    }
                }
            }
        }
    }
}
