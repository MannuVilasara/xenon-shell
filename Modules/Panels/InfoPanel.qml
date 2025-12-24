import "../../Services" as Services
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "Views/Info" as InfoViews
import qs.Core
import qs.Services

PanelWindow {
    /*
    onHoveredChanged: {
        if (hovered && !Config.disableHover) {
            closeTimer.stop()
            isOpen = true
        }
    }
    */

    id: root

    property int currentTab: 0 // 0: Home, 1: Music, 2: Weather, 3: System
    property bool forcedOpen: false
    property bool hovered: infoHandler.hovered || peekHandler.hovered
    property bool isOpen: false
    readonly property int peekWidth: 10
    required property var globalState

    function getX(open) {
        return open ? 20 : (-mainBox.width + root.peekWidth);
    }

    implicitWidth: Screen.width
    implicitHeight: Screen.height
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    mask: (isOpen || forcedOpen) ? fullMask : splitMask

    anchors {
        top: true
        bottom: true
        left: true
    }

    Colors {
        id: appColors
    }

    Services.SystemInfoService {
        id: systemInfo
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
                x: mainBox.x
                y: mainBox.y
                width: mainBox.width
                height: mainBox.height
            },
            Region {
                x: 0
                y: mainBox.y
                width: root.peekWidth
                height: mainBox.height
            },
            Region {
                x: 0
                y: mainBox.y + mainBox.height
                width: mainBox.width
                height: 12
            }
        ]
    }

    Timer {
        id: closeTimer

        interval: 100
        repeat: false
        running: false // !root.hovered && !root.forcedOpen && !Config.disableHover
        onTriggered: root.isOpen = false
    }

    MouseArea {
        anchors.fill: parent
        z: -100
        enabled: root.isOpen || root.forcedOpen
        onClicked: {
            root.isOpen = false;
            root.forcedOpen = false;
        }
    }

    Rectangle {
        id: mainBox

        width: 550
        height: contentRow.implicitHeight + 32
        anchors.verticalCenter: parent.verticalCenter
        x: root.getX(root.isOpen || root.forcedOpen)
        radius: 16
        color: Qt.rgba(appColors.bg.r, appColors.bg.g, appColors.bg.b, 0.95)
        border.width: 1
        border.color: appColors.border
        clip: true
        layer.enabled: true

        MouseArea {
            anchors.fill: parent
        }

        RowLayout {
            id: contentRow

            anchors.fill: parent
            anchors.margins: 16
            spacing: 0

            Rectangle {
                Layout.preferredWidth: 48
                Layout.fillHeight: true
                Layout.rightMargin: 12
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 16

                    Repeater {
                        // Home
                        // Music
                        // Weather
                        // System

                        model: [{
                            "icon": "󰣇",
                            "index": 0
                        }, {
                            "icon": "󰝚",
                            "index": 1
                        }, {
                            "icon": "󰖐",
                            "index": 2
                        }, {
                            "icon": "󰍛",
                            "index": 3
                        }]

                        Rectangle {
                            required property var modelData

                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            radius: 18
                            color: root.currentTab === modelData.index ? appColors.accent : "transparent"

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

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }

                            }

                        }

                    }

                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 1
                    color: appColors.border
                }

            }

            Item {
                Layout.fillWidth: true
                implicitHeight: loader.height

                Loader {
                    id: loader

                    anchors.centerIn: parent
                    width: Math.min(parent.width, 460) // Constrain max width for aesthetics
                    height: item ? item.implicitHeight : 0
                    sourceComponent: {
                        switch (root.currentTab) {
                        case 0:
                            return homeComp;
                        case 1:
                            return musicComp;
                        case 2:
                            return weatherComp;
                        case 3:
                            return systemComp;
                        }
                    }
                    onSourceComponentChanged: fadeAnim.restart()

                    NumberAnimation {
                        id: fadeAnim

                        target: loader.item
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 200
                    }

                }

            }

        }

        HoverHandler {
            id: infoHandler
        }

        layer.effect: DropShadow {
            transparentBorder: true
            radius: 16
            samples: 17
            color: "#40000000"
        }

        Behavior on x {
            NumberAnimation {
                duration: 500
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.38, 1.21, 0.22, 1, 1, 1]
            }

        }

        Behavior on height {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }

        }

    }

    Component {
        id: homeComp

        InfoViews.HomeView {
            theme: appColors
            sysInfo: systemInfo
        }

    }

    Component {
        id: musicComp

        InfoViews.MusicView {
            theme: appColors
        }

    }

    Component {
        id: weatherComp

        InfoViews.WeatherView {
            theme: appColors
        }

    }

    Component {
        id: systemComp

        InfoViews.SystemView {
            theme: appColors
        }

    }

    Rectangle {
        color: "transparent"
        x: 0
        y: mainBox.y
        width: root.peekWidth
        height: mainBox.height

        HoverHandler {
            id: peekHandler
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.isOpen = true
        }

    }

}
