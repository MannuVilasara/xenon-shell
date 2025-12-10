import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import "../core"
import "../notifications"

PanelWindow {
    id: root

    // --- DEPENDENCIES ---
    required property var globalState
    required property var notifManager

    readonly property int topBarHeight: 50

    // --- THEME ---
    QtObject {
        id: theme

        // Colors
        property color bg:                "#1A1D26"
        property color surface:           "#252932"
        property color tile:              "#2F333D"
        property color tileActive:        "#CBA6F7"
        property color tileActiveAlt:     "#C4B5FD"
        property color border:            "#2F333D"
        property color text:              "#E8EAF0"
        property color secondary:         "#9BA3B8"
        property color muted:             "#6B7280"
        property color iconMuted:         "#70727C"
        property color iconActive:        "#FFFFFF"
        property color accent:            "#A78BFA"
        property color accentHover:       "#C4B5FD"
        property color accentActive:      "#CBA6F7"
        property color urgent:            "#EF4444"
        property color sliderTrack:       "#3A3F4B"
        property color sliderThumb:       "#FFFFFF"
        property color sliderFill:        "#CBA6F7"

        // Dimensions
        property int panelWidth:          400
        property int borderRadius:        20
        property int contentMargins:      24
        property int spacing:             20
        property int toggleHeight:        88
        property int sliderHeight:        64
        property int notificationHeight:  80
        property int headerAvatarSize:    48
        property int toggleIconSize:      24
        property int sliderIconSize:      20
    }


    // --- WINDOW SETUP ---
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    // Only visible when open or animating
    visible: globalState.sidePanelOpen || slideAnim.running || slideTranslate.x < content.width

    // LAYER SHELL CONFIG
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "matte-dashboard"
    WlrLayershell.exclusiveZone: -1 
    
    // FIX 1: KEYBOARD FOCUS
    // "OnDemand" allows us to request focus. "None" blocked all keys.
    WlrLayershell.keyboardFocus: WlrLayershell.KeyboardFocus.OnDemand

    // FIX 2: ESCAPE KEY HANDLER
    // We must ensure 'root' has focus to catch this key.
    Keys.onEscapePressed: {
        globalState.sidePanelOpen = false
    }

    // FIX 3: FORCE FOCUS LOGIC
    // When panel opens, we grab focus so Escape works immediately.
    Connections {
        target: globalState
        function onSidePanelOpenChanged() {
            if (globalState.sidePanelOpen) {
                // Wait one frame for visibility to apply, then force focus
                requestFocusTimer.start()
            }
        }
    }

    Timer {
        id: requestFocusTimer
        interval: 10
        repeat: false
        onTriggered: {
            root.forceActiveFocus()
        }
    }

    // --- DIMMER (BACKGROUND) ---
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: globalState.sidePanelOpen ? 0.4 : 0
        Behavior on opacity { NumberAnimation { duration: 350 } }
        
        MouseArea {
            anchors.fill: parent
            onClicked: globalState.sidePanelOpen = false
        }
    }

    // --- MAIN CONTENT PANEL ---
    Rectangle {
        id: content
        width: theme.panelWidth
        
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.topMargin: 65
        anchors.bottomMargin: 15
        anchors.rightMargin: 15

        color: theme.bg
        radius: theme.borderRadius
        border.width: 1
        border.color: theme.border
        clip: true

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

        transform: Translate {
            id: slideTranslate
            x: globalState.sidePanelOpen ? 0 : (content.width + 50)
            Behavior on x {
                SpringAnimation {
                    id: slideAnim
                    spring: 2
                    damping: 0.25
                    epsilon: 0.5
                    mass: 1
                }
            }
        }

        // --- CONTENT LAYOUT ---
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: theme.contentMargins
            spacing: theme.spacing

            // === HEADER ===
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                // Avatar Square with Arch Logo
                Rectangle {
                    Layout.preferredWidth: theme.headerAvatarSize
                    Layout.preferredHeight: theme.headerAvatarSize
                    radius: 12
                    
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: theme.tileActive }
                        GradientStop { position: 1.0; color: theme.accentActive }
                    }
                    
                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        horizontalOffset: 0
                        verticalOffset: 2
                        radius: 8
                        samples: 17
                        color: Qt.rgba(0, 0, 0, 0.3)
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰣇"
                        font.pixelSize: 28
                        font.family: "Symbols Nerd Font"
                        color: "#FFFFFF"
                    }
                }

                // User Info
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Text {
                        text: Quickshell.env("USER")
                        color: theme.text
                        font.bold: true
                        font.pixelSize: 18
                        font.capitalization: Font.Capitalize
                    }
                    
                    Text {
                        text: "Matte Shell • " + Qt.formatTime(new Date(), "hh:mm")
                        color: theme.secondary
                        font.pixelSize: 13
                    }
                }

                Item { Layout.fillWidth: true }

                // Power Button
                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: 8
                    color: powerBtn.pressed ? theme.tile : "transparent"
                    border.width: 1
                    border.color: theme.border
                    
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰐥"
                        font.pixelSize: 18
                        font.family: "Symbols Nerd Font"
                        color: theme.urgent
                    }
                    
                    TapHandler {
                        id: powerBtn
                        onTapped: console.log("Power Clicked")
                    }
                }
            }

            // === TOGGLES ===
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 12
                columnSpacing: 12
                
                ToggleButton {
                    label: "WiFi"
                    sublabel: "Connected"
                    icon: "󰖩"
                    active: true
                    showChevron: true
                    Layout.fillWidth: true
                }
                
                ToggleButton {
                    label: "Bluetooth"
                    sublabel: "Off"
                    icon: "󰂯"
                    active: false
                    showChevron: true
                    Layout.fillWidth: true
                }
                
                ToggleButton {
                    label: "Do Not Disturb"
                    sublabel: "Off"
                    icon: "󰂛"
                    active: false
                    showChevron: false
                    Layout.fillWidth: true
                }
                
                ToggleButton {
                    label: "Microphone"
                    sublabel: "Active"
                    icon: "󰍬"
                    active: true
                    showChevron: false
                    Layout.fillWidth: true
                }
            }

            // === SLIDERS ===
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16
                
                SliderControl {
                    label: "Volume"
                    icon: "󰕾"
                    value: 0.65
                }
                
                SliderControl {
                    label: "Brightness"
                    icon: "󰃠"
                    value: 0.80
                }
            }

            // === NOTIFICATIONS ===
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: theme.border
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12
                
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: "Notifications"
                        color: theme.text
                        font.pixelSize: 16
                        font.weight: Font.Medium
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: "Clear all"
                        color: theme.accent
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        visible: notifManager.notifications.count > 0
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: notifManager.clearHistory()
                        }
                    }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 12
                    model: notifManager.notifications

                    Rectangle {
                        visible: parent.count === 0
                        anchors.centerIn: parent
                        width: parent.width
                        height: 100
                        color: "transparent"
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            
                            Text {
                                text: "󰂚"
                                font.pixelSize: 32
                                font.family: "Symbols Nerd Font"
                                color: theme.muted
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "No notifications"
                                color: theme.muted
                                font.pixelSize: 14
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: theme.notificationHeight
                        color: theme.surface
                        radius: 12
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            // Icon
                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                color: theme.tile
                                radius: 8
                                
                                Image {
                                    anchors.centerIn: parent
                                    width: 24
                                    height: 24
                                    fillMode: Image.PreserveAspectFit
                                    source: {
                                        var src = image || appIcon || ""
                                        if (src.indexOf("/") >= 0) return "file://" + src
                                        if (src !== "") return "image://icon/" + src
                                        return ""
                                    }
                                }
                            }

                            // Content
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                
                                Text {
                                    text: summary
                                    color: theme.text
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: body
                                    color: theme.secondary
                                    font.pixelSize: 13
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                    Layout.fillWidth: true
                                }
                            }

                            // Close Button
                            Rectangle {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                color: closeArea.containsMouse ? theme.tile : "transparent"
                                radius: 12
                                
                                Behavior on color { ColorAnimation { duration: 150 } }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰅖"
                                    font.pixelSize: 14
                                    font.family: "Symbols Nerd Font"
                                    color: theme.secondary
                                }
                                
                                MouseArea {
                                    id: closeArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    
                                    onClicked: {
                                        if (typeof notifManager.removeById === "function") {
                                            notifManager.removeById(model.id)
                                        } else {
                                            notifManager.removeAtIndex(index)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // --- REUSABLE COMPONENTS ---

    component ToggleButton: Rectangle {
        property string label: ""
        property string sublabel: ""
        property string icon: ""
        property bool active: false
        property bool showChevron: false
        
        implicitHeight: theme.toggleHeight
        radius: 16
        color: active ? theme.tileActive : theme.tile
        border.width: 1
        border.color: active ? theme.tileActive : theme.border
        
        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutQuad } }
        Behavior on border.color { ColorAnimation { duration: 200 } }
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14
            
            // Icon
            Text {
                text: icon
                font.pixelSize: theme.toggleIconSize
                font.family: "Symbols Nerd Font"
                color: active ? theme.bg : theme.secondary
                Behavior on color { ColorAnimation { duration: 200 } }
            }
            
            // Labels
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Text {
                    text: label
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: active ? theme.bg : theme.text
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
                
                Text {
                    text: sublabel
                    font.pixelSize: 12
                    color: active ? Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.7) : theme.secondary
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    visible: sublabel !== ""
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
            }
            
            // Chevron
            Text {
                text: "󰅂"
                font.pixelSize: 16
                font.family: "Symbols Nerd Font"
                color: active ? theme.bg : theme.iconMuted
                visible: showChevron
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }
        
        TapHandler {
            onTapped: active = !active
        }
    }

    component SliderControl: Rectangle {
        property string label: ""
        property string icon: ""
        property real value: 0.5
        
        Layout.fillWidth: true
        implicitHeight: theme.sliderHeight
        color: theme.tile
        radius: 12
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10
            
            // Header
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: icon
                    font.pixelSize: theme.sliderIconSize
                    font.family: "Symbols Nerd Font"
                    color: theme.text
                }
                
                Text {
                    text: label
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: theme.text
                    Layout.fillWidth: true
                }
                
                Text {
                    text: Math.round(value * 100) + "%"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: theme.secondary
                }
            }
            
            // Slider Track
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 6
                radius: 3
                color: theme.sliderTrack
                
                Rectangle {
                    height: parent.height
                    width: parent.width * value
                    radius: 3
                    color: theme.sliderFill
                    
                    Behavior on width {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutQuad
                        }
                    }
                    
                    // Thumb
                    Rectangle {
                        width: 20
                        height: 20
                        radius: 10
                        color: theme.sliderThumb
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        
                        layer.enabled: true
                        layer.effect: DropShadow {
                            transparentBorder: true
                            horizontalOffset: 0
                            verticalOffset: 2
                            radius: 8
                            samples: 17
                            color: Qt.rgba(0, 0, 0, 0.2)
                        }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    
                    onPositionChanged: function(mouse) {
                        value = Math.max(0, Math.min(1, mouse.x / width))
                    }
                    
                    onPressed: function(mouse) {
                        value = Math.max(0, Math.min(1, mouse.x / width))
                    }
                }
            }
        }
    }
}