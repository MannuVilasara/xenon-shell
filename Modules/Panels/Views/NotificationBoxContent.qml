import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Modules.Notifications
import qs.Widgets

ColumnLayout {
    id: root

    required property var notifManager
    required property var theme

    width: 320
    spacing: 0
    Layout.preferredHeight: 280
    Layout.minimumHeight: 100
    Layout.maximumHeight: 280
    clip: true

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 44
        color: "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 8

            Rectangle {
                width: 24
                height: 24
                radius: 8
                color: theme.accentActive

                Text {
                    anchors.centerIn: parent
                    text: "󰂚"
                    font.family: "Symbols Nerd Font"
                    color: theme.bg
                    font.pixelSize: 14
                }

            }

            Text {
                text: "Notifications"
                color: theme.text
                font.pixelSize: 14
                font.bold: true
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: "Clear All"
                color: root.notifManager.notifications.count > 0 ? theme.urgent : theme.muted
                font.pixelSize: 11
                font.bold: true
                visible: root.notifManager.notifications.count > 0

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.notifManager.clearHistory()
                }

            }

        }

    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: theme.border
        opacity: 0.5
        Layout.bottomMargin: 8
    }

    ListView {
        id: notifList

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: 280
        clip: true
        spacing: 10
        model: root.notifManager.notifications

        Text {
            anchors.centerIn: parent
            visible: parent.count === 0
            text: "No new notifications"
            color: theme.muted
            font.pixelSize: 12
            font.italic: true
        }

        delegate: NotificationItem {
            width: ListView.view.width - 4
            notifId: model.id
            summary: model.summary || ""
            body: model.body || ""
            image: model.image || ""
            appIcon: model.appIcon || ""
            theme: root.theme
            onRemoveRequested: root.notifManager.removeById(notifId)
        }

    }

}
