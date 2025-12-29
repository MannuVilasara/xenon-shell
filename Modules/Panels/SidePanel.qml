import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "Views" as Views
import qs.Core
import qs.Modules.Notifications
import qs.Services
import qs.Widgets

PanelWindow {
    id: root

    required property var globalState
    required property var notifManager
    required property var volumeService
    required property var bluetoothService
    required property Colors colors
    property alias theme: theme
    readonly property int peekWidth: 10
    readonly property int boxWidth: 320
    property bool forcedOpen: false
    property bool controlHovered: controlHandler.hovered || controlPeekHandler.hovered
    property bool notifHovered: notifHandler.hovered || notifPeekHandler.hovered
    property bool controlOpen: false
    property bool notifOpen: false
    property bool toastHovered: false
    property bool hoverLocked: Config.disableHover
    property string currentMenu: ""

    function show() {
        forcedOpen = true;
        controlOpen = true;
        notifOpen = true;
    }

    function hide() {
        forcedOpen = false;
        controlOpen = false;
        notifOpen = false;
        menuLoader.active = false;
    }

    function getX(isOpen) {
        return isOpen ? (root.width - root.boxWidth - 20) : (root.width - root.peekWidth);
    }

    function toggleMenu(menu) {
        if (menu === "" || root.currentMenu === menu) {
            menuLoader.active = false;
            root.currentMenu = "";
        } else {
            root.currentMenu = menu;
            menuLoader.active = true;
        }
    }

    implicitWidth: Screen.width
    implicitHeight: Screen.height
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    mask: (menuLoader.active || forcedOpen) ? fullMask : splitMask
    onControlHoveredChanged: {
        if (controlHovered && !hoverLocked) {
            controlTimer.stop();
            controlOpen = true;
        }
    }
    onNotifHoveredChanged: {
        if (notifHovered && !hoverLocked) {
            notifTimer.stop();
            notifOpen = true;
        }
    }

    anchors {
        top: true
        bottom: true
        right: true
    }

    Region {
        id: fullMask

        regions: [
            Region {
                x: 0
                y: 0
                width: root.width
                height: root.height
            }
        ]
    }

    Region {
        id: splitMask

        regions: [
            Region {
                x: controlBox.x
                y: controlBox.y
                width: controlBox.width
                height: controlBox.height
            },
            Region {
                x: notifBox.x
                y: notifBox.y
                width: notifBox.width
                height: notifBox.height
            },
            Region {
                x: root.width - root.peekWidth
                y: controlBox.y
                width: root.peekWidth
                height: controlBox.height
            },
            Region {
                x: root.width - root.peekWidth
                y: notifBox.y
                width: root.peekWidth
                height: notifBox.height
            },
            Region {
                x: controlBox.x
                y: controlBox.y + controlBox.height
                width: controlBox.width
                height: 12 // Spacing
            },
            Region {
                x: root.width - root.peekWidth
                y: controlBox.y + controlBox.height
                width: root.peekWidth
                height: 12
            }
        ]
    }

    QtObject {
        id: theme

        property color bg: root.colors.bg
        property color surface: root.colors.surface
        property color border: root.colors.border
        property color text: root.colors.text
        property color subtext: root.colors.subtext
        property color secondary: root.colors.secondary
        property color muted: root.colors.muted
        property color urgent: root.colors.urgent
        property color accent: root.colors.accent
        property color accentActive: root.colors.accentActive
        property color tileActive: root.colors.tileActive
        property color iconMuted: root.colors.iconMuted
        property int borderRadius: 16
        property int contentMargins: 16
        property int spacing: 12
    }

    Connections {
        target: globalState
        function onRequestSidePanelMenu(menu) {
            if (root.currentMenu === menu && root.controlOpen) {
                // If the same menu is requested and panel is open, close it (toggle behavior)
                toggleMenu(menu); // This will close the menu
                root.controlOpen = false;
            } else {
                // Otherwise open/switch to it
                if (root.currentMenu !== menu) {
                    toggleMenu(menu);
                }
                root.controlOpen = true;
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -100
        enabled: menuLoader.active || forcedOpen
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            root.hide();
            root.toggleMenu("");
        }
    }

    Timer {
        id: controlTimer

        interval: 100
        repeat: false
        running: !root.controlHovered && !menuLoader.active && !root.forcedOpen && !root.notifHovered && !root.toastHovered && !root.hoverLocked
        onTriggered: root.controlOpen = false
    }

    Timer {
        id: notifTimer

        interval: 100
        repeat: false
        running: !root.notifHovered && !root.forcedOpen && !root.controlHovered && !root.toastHovered && !root.hoverLocked
        onTriggered: root.notifOpen = false
    }

    Rectangle {
        id: controlBox

        width: root.boxWidth
        height: contentCol.height + 32 // 16px top + 16px bottom padding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        x: root.getX(root.controlOpen || menuLoader.active || root.forcedOpen)
        radius: 16
        color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.95)
        border.width: 1
        border.color: theme.border
        clip: true // Ensure content doesn't bleed during animation
        layer.enabled: true

        Column {
            id: contentCol

            width: parent.width - 32
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            Views.ControlBoxContent {
                id: controlContent

                width: parent.width
                globalState: root.globalState
                theme: root.theme
                notifManager: root.notifManager
                onRequestWifiMenu: toggleMenu("wifi")
                onRequestBluetoothMenu: toggleMenu("bluetooth")
                onRequestPowerMenu: root.globalState.powerMenuOpen = true
                volumeService: root.volumeService
                bluetoothService: root.bluetoothService
            }



            Loader {
                id: menuLoader

                width: parent.width
                active: false
                visible: active
                sourceComponent: {
                    if (root.currentMenu === "wifi")
                        return wifiComp;

                    if (root.currentMenu === "bluetooth")
                        return btComp;

                    return null;
                }
                onLoaded: {
                    item.opacity = 0;
                    fadeIn.start();
                }

                NumberAnimation {
                    id: fadeIn

                    target: menuLoader.item
                    property: "opacity"
                    to: 1
                    duration: 200
                }

            }

        }

        HoverHandler {
            id: controlHandler
        }

        layer.effect: DropShadow {
            transparentBorder: true
            radius: 16
            samples: 17
            color: "#40000000"
        }

        Behavior on x {
            NumberAnimation {
                duration: 300
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.38, 1.21, 0.22, 1, 1, 1]
            }

        }

        Behavior on height {
            NumberAnimation {
                duration: 500
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.38, 1.21, 0.22, 1, 1, 1]
            }

        }

    }

    Component {
        id: wifiComp

        Views.WifiView {
            theme: root.theme
            globalState: root.globalState
            onBackRequested: toggleMenu("") // Close
        }

    }

    Component {
        id: btComp

        Views.BluetoothView {
            theme: root.theme
            globalState: root.globalState
            bluetoothService: root.bluetoothService
            onBackRequested: toggleMenu("") // Close
        }

    }

    Rectangle {
        id: notifBox

        property int maxAvailableHeight: root.height - controlBox.height - 40 - 20 // 40 top, 20 spacing

        width: root.boxWidth
        anchors.bottom: controlBox.top
        anchors.bottomMargin: 12
        height: Math.min(Math.max(100, maxAvailableHeight), notifContent.implicitHeight + 32)
        x: root.getX(root.notifOpen || root.forcedOpen)
        radius: 16
        color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.95)
        border.width: 1
        border.color: theme.border
        layer.enabled: true

        Views.NotificationBoxContent {
            id: notifContent

            anchors.fill: parent
            anchors.margins: 16
            theme: theme
            notifManager: root.notifManager
        }

        HoverHandler {
            id: notifHandler
        }

        layer.effect: DropShadow {
            transparentBorder: true
            radius: 16
            samples: 17
            color: "#40000000"
        }

        Behavior on x {
            NumberAnimation {
                duration: 300
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.38, 1.21, 0.22, 1, 1, 1]
            }

        }

        Behavior on height {
            NumberAnimation {
                duration: 300
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.38, 1.21, 0.22, 1, 1, 1]
            }
        }

    }

    Rectangle {
        color: "transparent"
        x: parent.width - root.peekWidth
        y: controlBox.y
        width: root.peekWidth
        height: controlBox.height

        HoverHandler {
            id: controlPeekHandler
        }

    }

    Rectangle {
        color: "transparent"
        x: parent.width - root.peekWidth
        y: notifBox.y
        width: root.peekWidth
        height: notifBox.height

        HoverHandler {
            id: notifPeekHandler
        }

    }

}
