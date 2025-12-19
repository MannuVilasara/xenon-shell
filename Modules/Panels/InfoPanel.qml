import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import qs.Core
import qs.Services
import "../../Services" as Services
import "Views/Info" as InfoViews

PanelWindow {
    id: root
    
    // Position: Left Side, Full Height (for peek), but content anchored Bottom Left
    anchors {
        top: true
        bottom: true
        left: true
    }
    
    implicitWidth: Screen.width
    implicitHeight: Screen.height
    
    color: "transparent"
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    
    // --- State ---
    property int currentTab: 0 // 0: Home, 1: Music, 2: Weather, 3: System
    property bool forcedOpen: false
    property bool hovered: infoHandler.hovered || peekHandler.hovered
    property bool isOpen: false
    
    // --- Configuration ---
    readonly property int peekWidth: 10
    
    // Theme (Global)
    Colors { id: appColors }
    
    // System Info Service
    Services.SystemInfoService { id: systemInfo }

    required property var globalState

    // --- Masks ---
    Region {
        id: fullMask
        regions: [ Region { x: 0; y: 0; width: root.width; height: root.height } ]
    }
    
    Region {
        id: splitMask
        regions: [
            // Active Box
            Region {
                x: mainBox.x
                y: mainBox.y
                width: mainBox.width
                height: mainBox.height
            },
            // Peek Strip
            Region {
                x: 0
                y: mainBox.y
                width: root.peekWidth
                height: mainBox.height
            },
            // Bridge
            Region {
                x: 0
                y: mainBox.y + mainBox.height
                width: mainBox.width
                height: 12
            }
        ]
    }
    
    mask: (isOpen || forcedOpen) ? fullMask : splitMask

    // --- Logic ---
    // Auto-Close Timer (Disabled as per user request to keep open until click)
    Timer {
        id: closeTimer
        interval: 100
        repeat: false
        running: false // !root.hovered && !root.forcedOpen && !Config.disableHover
        onTriggered: root.isOpen = false
    }
    
    /* 
    onHoveredChanged: {
        if (hovered && !Config.disableHover) {
            closeTimer.stop()
            isOpen = true
        }
    }
    */
    
    // X Position Logic (Left Side)
    // Open: 20px margin
    // Closed: Hidden off-screen, leaving peekWidth visible
    function getX(open) {
        return open ? 20 : (-mainBox.width + root.peekWidth)
    }

    MouseArea {
        anchors.fill: parent
        z: -100
        enabled: root.isOpen || root.forcedOpen
        onClicked: {
            root.isOpen = false
            root.forcedOpen = false
        }
    }

    // --- Main Container ---
    Rectangle {
        id: mainBox
        
        // Fixed Width (No jitter), Dynamic Height
        width: 550
        height: contentRow.implicitHeight + 32
        
        // Prevent clicks from falling through to the background close handler
        MouseArea { anchors.fill: parent }

        // Anchors - Middle Left
        anchors.verticalCenter: parent.verticalCenter
        
        x: root.getX(root.isOpen || root.forcedOpen)
        
        radius: 16
        color: Qt.rgba(appColors.bg.r, appColors.bg.g, appColors.bg.b, 0.95)
        border.width: 1
        border.color: appColors.border
        
        clip: true
        
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 16
            samples: 17
            color: "#40000000"
        }
        
        // Smooth Animations
        Behavior on x {
            NumberAnimation {
                duration: 500
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.38, 1.21, 0.22, 1, 1, 1]
            }
        }
        
        // Behavior on width removed (Fixed width)
        Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        
        // Internal Content
        RowLayout {
            id: contentRow
            anchors.fill: parent
            anchors.margins: 16
            spacing: 0
            
            // Sidebar Navigation
            Rectangle {
                Layout.preferredWidth: 48
                Layout.fillHeight: true
                Layout.rightMargin: 12
                color: "transparent"
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 16
                // ... (rest of sidebar)
                    
                    Repeater {
                        model: [
                            { icon: "󰣇", index: 0 }, // Home
                            { icon: "󰝚", index: 1 }, // Music
                            { icon: "󰖐", index: 2 }, // Weather
                            { icon: "󰍛", index: 3 }  // System
                        ]
                        
                        Rectangle {
                            required property var modelData
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            radius: 18
                            color: root.currentTab === modelData.index ? appColors.purple : "transparent"
                            
                            Behavior on color { ColorAnimation { duration: 200 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 20
                                color: root.currentTab === modelData.index ? appColors.bg : appColors.subtext
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: root.currentTab = modelData.index
                            }
                        }
                    }
                }
                
                // Vertical Separator
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 1
                    color: appColors.border
                }
            }
            
            // Content Area
            Item {
                Layout.fillWidth: true
                // Layout.fillHeight: true
                implicitHeight: loader.height
                
                Loader {
                    id: loader
                    anchors.centerIn: parent
                    width: Math.min(parent.width, 460) // Constrain max width for aesthetics
                    height: item ? item.implicitHeight : 0
                    
                    sourceComponent: {
                        switch(root.currentTab) {
                            case 0: return homeComp
                            case 1: return musicComp
                            case 2: return weatherComp
                            case 3: return systemComp
                        }
                    }
                    
                    // Crossfade
                    onSourceComponentChanged: fadeAnim.restart()
                    
                    NumberAnimation {
                         id: fadeAnim
                         target: loader.item
                         property: "opacity"
                         from: 0; to: 1
                         duration: 200
                    }
                }
            }
        }
        
        HoverHandler { id: infoHandler }
    }
    
    // Components
    Component { id: homeComp; InfoViews.HomeView { theme: appColors; sysInfo: systemInfo } }
    Component { id: musicComp; InfoViews.MusicView { theme: appColors } }
    Component { id: weatherComp; InfoViews.WeatherView { theme: appColors } }
    Component { id: systemComp; InfoViews.SystemView { theme: appColors } }
    
    // Peek Strip
    Rectangle {
        color: "transparent"
        x: 0
        y: mainBox.y
        width: root.peekWidth
        height: mainBox.height
        HoverHandler { id: peekHandler }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.isOpen = true
        }
    }
}