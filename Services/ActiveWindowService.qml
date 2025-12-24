import QtQuick
import Quickshell.Hyprland
import Quickshell.Io

Item {
    property string title: "Window"

    Process {
        id: windowProc

        command: ["sh", "-c", "hyprctl activewindow -j | jq -r '.title // empty'"]

        stdout: SplitParser {
            onRead: (data) => {
                if (data && data.trim())
                    title = data.trim();

            }
        }

    }

    Connections {
        function onRawEvent(event) {
            windowProc.running = true;
        }

        target: Hyprland
    }

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: windowProc.running = true
    }

}
