import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    property bool isOpen: false
    required property var globalState

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    visible: isOpen

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "matte-power-menu"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrLayershell.KeyboardFocus.OnDemand

    Keys.onEscapePressed: globalState.powerMenuOpen = false

    // Dimmer with blur
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: isOpen ? 0.9 : 0
        
        Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
        
        MouseArea {
            anchors.fill: parent
            onClicked: globalState.powerMenuOpen = false
        }
        
        layer.enabled: true
        layer.effect: FastBlur {
            radius: 32
        }
    }

    // Content Container with fade-in
    Item {
        anchors.centerIn: parent
        width: buttonsGrid.width
        height: contentLayout.height
        opacity: isOpen ? 1 : 0
        scale: isOpen ? 1 : 0.95
        
        Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
        Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
        
        ColumnLayout {
            id: contentLayout
            spacing: 32
            
            // Header
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8
                
                Text {
                    text: "Power Options"
                    font.pixelSize: 28
                    font.weight: Font.Bold
                    color: "#E8EAF0"
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: "Choose an action"
                    font.pixelSize: 14
                    color: "#9BA3B8"
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            
            // Buttons Grid
            GridLayout {
                id: buttonsGrid
                columns: 3
                rowSpacing: 20
                columnSpacing: 20
                Layout.alignment: Qt.AlignHCenter
            
            PowerButton {
                label: "Lock"
                icon: "󰌾"
                accentColor: "#60A5FA"
                onClicked: globalState.powerMenuOpen = false
            }
            
            PowerButton {
                label: "Reboot"
                icon: "󰜉"
                accentColor: "#F59E0B"
                onClicked: globalState.powerMenuOpen = false
            }
            
            PowerButton {
                label: "Shutdown"
                icon: "󰐥"
                accentColor: "#EF4444"
                onClicked: globalState.powerMenuOpen = false
            }
            
            PowerButton {
                label: "Logout"
                icon: "󰍃"
                accentColor: "#8B9DC3"
                onClicked: globalState.powerMenuOpen = false
            }
            
            PowerButton {
                label: "Suspend"
                icon: "󰒲"
                accentColor: "#A78BFA"
                onClicked: globalState.powerMenuOpen = false
            }
            
            PowerButton {
                label: "Hibernate"
                icon: "󰋊"
                accentColor: "#6366F1"
                onClicked: globalState.powerMenuOpen = false
            }
        }
    }
}
    
    component PowerButton: Rectangle {
        property string label: ""
        property string icon: ""
        property color accentColor: "#A78BFA"
        signal clicked()
        
        width: 160
        height: 180
        radius: 20
        
        color: btnArea.containsMouse ? "#3A3F4B" : "#2F333D"
        border.width: 1
        border.color: btnArea.containsMouse ? accentColor : "#2F333D"
        
        scale: btnArea.pressed ? 0.96 : (btnArea.containsMouse ? 1.03 : 1.0)
        
        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
        
        // Glow effect on hover
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 2
            border.color: accentColor
            opacity: btnArea.containsMouse ? 0.4 : 0
            
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
        
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: btnArea.containsMouse ? 12 : 8
            radius: btnArea.containsMouse ? 32 : 24
            samples: 33
            color: btnArea.containsMouse ? "#00000080" : "#00000050"
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12
            
            Item { Layout.fillHeight: true }
            
            Text {
                text: icon
                font.pixelSize: 40
                font.family: "Symbols Nerd Font"
                color: accentColor
                Layout.alignment: Qt.AlignHCenter
                
                Behavior on color { ColorAnimation { duration: 200 } }
            }
            
            Text {
                text: label
                font.pixelSize: 14
                font.weight: Font.Medium
                color: btnArea.containsMouse ? "#FFFFFF" : "#E8EAF0"
                Layout.alignment: Qt.AlignHCenter
                
                Behavior on color { ColorAnimation { duration: 200 } }
            }
            
            Item { Layout.fillHeight: true }
        }
        
        MouseArea {
            id: btnArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}
