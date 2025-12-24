import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    property string label: ""
    property string icon: ""
    property real value: 0.5
    property var theme

    Layout.fillWidth: true
    implicitHeight: theme ? theme.sliderHeight : 64
    color: theme ? theme.tile : "#2F333D"
    radius: 12

    MouseArea {
        anchors.fill: parent
        z: 1 // Above content but below any interactive elements
        onWheel: function(wheel) {
            var step = 0.05;
            if (wheel.angleDelta.y > 0)
                value = Math.min(1, value + step);
            else
                value = Math.max(0, value - step);
        }
        onClicked: function(mouse) {
            value = Math.max(0, Math.min(1, mouse.x / width));
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            MouseArea {
                Layout.fillWidth: true
                Layout.fillHeight: true
                cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                onPositionChanged: function(mouse) {
                    if (pressed)
                        value = Math.max(0, Math.min(1, mouse.x / width));

                }
                onPressed: function(mouse) {
                    value = Math.max(0, Math.min(1, mouse.x / width));
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 10

                    Text {
                        text: icon
                        font.pixelSize: theme ? theme.sliderIconSize : 20
                        font.family: "Symbols Nerd Font"
                        color: theme ? theme.text : "#E8EAF0"
                    }

                    Text {
                        text: label
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: theme ? theme.text : "#E8EAF0"
                        Layout.fillWidth: true
                    }

                    Text {
                        text: Math.round(value * 100) + "%"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: theme ? theme.secondary : "#9BA3B8"
                    }

                }

            }

        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            radius: 3
            color: theme ? theme.sliderTrack : "#3A3F4B"

            Rectangle {
                height: parent.height
                width: parent.width * value
                radius: 3
                color: theme ? theme.sliderFill : "#CBA6F7"

                Rectangle {
                    width: 20
                    height: 20
                    radius: 10
                    color: theme ? theme.sliderThumb : "#FFFFFF"
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

                Behavior on width {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutQuad
                    }

                }

            }

            MouseArea {
                anchors.fill: parent
                onPositionChanged: function(mouse) {
                    if (pressed)
                        value = Math.max(0, Math.min(1, mouse.x / width));

                }
                onPressed: function(mouse) {
                    value = Math.max(0, Math.min(1, mouse.x / width));
                }
            }

        }

    }

}
