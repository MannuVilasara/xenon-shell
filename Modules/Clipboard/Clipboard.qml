import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Core

PanelWindow {
    id: root

    required property Colors colors
    required property GlobalState globalState

    function refresh() {
        loader.running = true;
    }

    function selectItem(index) {
        if (index >= 0 && index < listView.model.length) {
            var item = listView.model[index];
            copier.targetId = item.id;
            copier.running = true;
            root.visible = false;
        }
    }

    visible: globalState.clipboardOpen
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    color: "transparent"
    onVisibleChanged: {
        if (visible) {
            refresh();
            searchBar.text = "";
            searchBar.forceActiveFocus();
            listView.currentIndex = 0;
        }
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Shortcut {
        sequence: "Escape"
        onActivated: globalState.closeAll()
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: globalState.closeAll()
    }

    Process {
        id: loader

        command: ["cliphist", "list"]

        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.split("\n");
                var data = [];
                lines.forEach((line) => {
                    if (line.trim() === "")
                        return ;

                    var parts = line.split("\t");
                    var id = parts[0];
                    var content = parts.slice(1).join("\t");
                    var display = content.length > 60 ? content.substring(0, 57) + "..." : content;
                    data.push({
                        "id": id,
                        "fullText": content,
                        "display": display
                    });
                });
                listView.model = data;
            }
        }

    }

    Process {
        id: copier

        property string targetId: ""

        command: ["sh", "-c", `cliphist decode ${targetId} | wl-copy`]
    }

    Process {
        id: wiper

        command: ["cliphist", "wipe"]
        onExited: listView.model = []
    }

    Rectangle {
        id: mainContainer

        width: 480
        anchors.centerIn: parent
        height: 60 + (listView.count > 0 ? Math.min(listView.count * 44, 400) : 100)
        color: colors.bg
        border.color: colors.muted
        border.width: 1
        radius: 12
        clip: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 60

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Text {
                        text: "📋"
                        font.pixelSize: 18
                    }

                    TextField {
                        id: searchBar

                        Layout.fillWidth: true
                        background: null
                        color: colors.fg
                        font.pixelSize: 18
                        font.bold: true
                        placeholderText: "Search Clipboard..."
                        placeholderTextColor: colors.muted
                        verticalAlignment: TextInput.AlignVCenter
                        Keys.onDownPressed: listView.incrementCurrentIndex()
                        Keys.onUpPressed: listView.decrementCurrentIndex()
                        Keys.onReturnPressed: root.selectItem(listView.currentIndex)
                    }

                    Text {
                        text: "🗑️"
                        font.pixelSize: 16
                        opacity: 0.7

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: wiper.running = true
                        }

                    }

                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: colors.muted
                    opacity: 0.5
                }

            }

            ListView {
                id: listView

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                delegate: Rectangle {
                    width: listView.width
                    height: 44
                    color: "transparent"

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: listView.currentIndex = index
                        onClicked: {
                            root.selectItem(index);
                            root.visible = false;
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: 6
                        color: ListView.isCurrentItem ? Qt.rgba(colors.muted.r, colors.muted.g, colors.muted.b, 0.3) : "transparent"

                        Rectangle {
                            width: 3
                            height: 20
                            radius: 2
                            color: colors.cyan
                            anchors.left: parent.left
                            anchors.leftMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            visible: parent.parent.ListView.isCurrentItem
                        }

                    }

                    Text {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: 10
                        width: parent.width - 40
                        text: modelData.display
                        color: ListView.isCurrentItem ? colors.purple : colors.fg
                        font.pixelSize: 14
                        elide: Text.ElideRight
                    }

                }

            }

        }

        Behavior on height {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutQuart
            }

        }

    }

}
