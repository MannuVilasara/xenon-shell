import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import "../../core"
import "../../core/common"
import "../../modules/notifications"

PanelWindow {
    id: root

    required property var globalState
    required property var notifManager

    readonly property var removeNotification: function(id) {
        notifManager.removeById(id)
    }

    // Expandable state
    property bool isExpanded: false

    QtObject {
        id: theme

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

        property int panelWidth:          420
        property int borderRadius:        24
        property int contentMargins:      28
        property int spacing:             24
        property int toggleHeight:        88
        property int sliderHeight:        64
        property int notificationHeight:  80
        property int headerAvatarSize:    48
        property int toggleIconSize:      24
        property int sliderIconSize:      20
        property int sectionSpacing:      32
    }


    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    visible: root.globalState.sidePanelOpen || openAnim.running || closeAnim.running || slideTranslate.x < content.width

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "matte-dashboard"
    WlrLayershell.exclusiveZone: -1

    Keys.onEscapePressed: {
        globalState.sidePanelOpen = false
    }

    Connections {
        target: root.globalState
        function onSidePanelOpenChanged() {
            if (root.globalState.sidePanelOpen) {
                requestFocusTimer.start()
            }
        }
    }

    Timer {
        id: requestFocusTimer
        interval: 10
        repeat: false
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: root.globalState.sidePanelOpen ? 0.5 : 0
        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

        layer.enabled: true
        layer.effect: FastBlur {
            radius: root.globalState.sidePanelOpen ? 20 : 0
            Behavior on radius { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
        }
    }

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

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 8
            radius: 32
            samples: 33
            color: Qt.rgba(0, 0, 0, 0.4)
        }

        transform: Translate {
            id: slideTranslate
            x: root.globalState.sidePanelOpen ? 0 : (content.width + 50)

            Behavior on x {
                animation: root.globalState.sidePanelOpen ? openAnim : closeAnim
            }
        }

        SpringAnimation {
            id: openAnim
            spring: 7.0
            damping: 0.15
            epsilon: 0.1
            mass: 0.2
            velocity: 2000
        }

        NumberAnimation {
            id: closeAnim
            duration: 1000
            easing.type: Easing.InQuart
        }

        Flickable {
            anchors.fill: parent
            anchors.margins: theme.contentMargins
            contentHeight: contentLayout.implicitHeight
            clip: true
            interactive: true
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick

            ColumnLayout {
                id: contentLayout
                width: parent.width
                spacing: theme.spacing

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

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
                            onTapped: powerMenu.isOpen = true
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    Text {
                        text: "Quick Settings"
                        color: theme.text
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        opacity: 0.8
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 12
                        columnSpacing: 12

                        Item {
                            Layout.fillWidth: true
                            implicitHeight: theme.toggleHeight
                            
                            ToggleButton {
                                id: wifiButton
                                anchors.fill: parent
                                label: "WiFi"
                                sublabel: "Connected"
                                icon: "󰖩"
                                active: true
                                showChevron: true
                                theme: theme
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    wifiModal.isOpen = !wifiModal.isOpen
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            implicitHeight: theme.toggleHeight
                            
                            ToggleButton {
                                anchors.fill: parent
                                label: "Bluetooth"
                                sublabel: "Off"
                                icon: "󰂯"
                                active: false
                                showChevron: true
                                theme: theme
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    btModal.isOpen = !btModal.isOpen
                                }
                            }
                        }

                        ToggleButton {
                            label: "Airplane Mode"
                            sublabel: "Off"
                            icon: "󰀝"
                            active: false
                            showChevron: false
                            theme: theme
                            Layout.fillWidth: true
                        }

                        ToggleButton {
                            label: "Night Mode"
                            sublabel: "Off"
                            icon: "󰖔"
                            active: false
                            showChevron: false
                            theme: theme
                            Layout.fillWidth: true
                        }

                        // Bottom 2 buttons - slide down from under expand button when expanded
                        ToggleButton {
                            opacity: root.isExpanded ? 1 : 0
                            Layout.preferredHeight: root.isExpanded ? implicitHeight : 0
                            clip: true
                            label: "Do Not Disturb"
                            sublabel: "Off"
                            icon: "󰂛"
                            active: false
                            showChevron: false
                            theme: theme
                            Layout.fillWidth: true

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 300
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Behavior on Layout.preferredHeight {
                                NumberAnimation {
                                    duration: 300
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        ToggleButton {
                            opacity: root.isExpanded ? 1 : 0
                            Layout.preferredHeight: root.isExpanded ? implicitHeight : 0
                            clip: true
                            label: "Microphone"
                            sublabel: "Active"
                            icon: "󰍬"
                            active: true
                            showChevron: false
                            theme: theme
                            Layout.fillWidth: true

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 300
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Behavior on Layout.preferredHeight {
                                NumberAnimation {
                                    duration: 300
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }

                    // Expand/Collapse button moved to under sliders
                }

                // Media controls - always visible
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    Text {
                        text: "Audio & Display"
                        color: theme.text
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        opacity: 0.8
                    }

                    SliderControl {
                        label: "Volume"
                        icon: "󰕾"
                        value: 0.65
                        theme: theme
                    }

                    SliderControl {
                        label: "Brightness"
                        icon: "󰃠"
                        value: 0.80
                        theme: theme
                    }

                    // Expand/Collapse button - under sliders
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: expandBtn2.pressed ? theme.tile : "transparent"
                        radius: 8

                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: root.isExpanded ? "󰅃" : "󰅀"  // Up arrow when expanded, down arrow when collapsed
                            font.pixelSize: 16
                            font.family: "Symbols Nerd Font"
                            color: theme.accent
                        }

                        MouseArea {
                            id: expandBtn2
                            anchors.fill: parent
                            onClicked: root.isExpanded = !root.isExpanded
                        }
                    }
                }

                // Separator - always visible since notifications are always visible
                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: theme.sectionSpacing
                    Layout.preferredHeight: 1
                    color: theme.border
                }

                // Notifications - shifts down with animation when expanded
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12
                    Layout.topMargin: isExpanded ? 120 : 0

                    Behavior on Layout.topMargin {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }

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
                        visible: root.notifManager.notifications.count > 0

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.notifManager.clearHistory()
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 12

                        Repeater {
                            model: root.notifManager.notifications

                            NotificationItem {
                                required property var model
                                required property int index
                                Layout.fillWidth: true
                                notifId: model.id
                                summary: model.summary || ""
                                body: model.body || ""
                                image: model.image || ""
                                appIcon: model.appIcon || ""
                                theme: theme

                                onRemoveRequested: {
                                    console.log("SidePanel received removeRequested for ID:", notifId)
                                    root.notifManager.removeById(notifId)
                                }

                                Component.onCompleted: {
                                    console.log("NotificationItem created via Repeater:", summary, "ID:", notifId)
                                }
                            }
                        }

                        // Empty state when no notifications
                        Rectangle {
                            visible: root.notifManager.notifications.count === 0
                            Layout.fillWidth: true
                            Layout.fillHeight: true
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
                    }
                }
            }
        }
    }

    PowerMenu {
        id: powerMenu
    }

    WifiModal {
        id: wifiModal
        anchors.fill: content
        theme: theme
        globalState: root.globalState
        z: 100
        onClose: wifiModal.isOpen = false
    }

    BtModal {
        id: btModal
        anchors.fill: content
        theme: theme
        globalState: root.globalState
        z: 100
        onClose: btModal.isOpen = false
    }
}