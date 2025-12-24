import QtQuick
import Quickshell.Hyprland
import Quickshell.Io

Item {
    property string layout: "Tile"

    Process {
        id: layoutProc

        command: ["sh", "-c", "hyprctl activewindow -j | jq -r 'if .floating then \"Floating\" elif .fullscreen == 1 then \"Fullscreen\" else \"Tiled\" end'"]

        stdout: SplitParser {
            onRead: (data) => {
                if (data && data.trim())
                    layout = data.trim();

            }
        }

    }

    Connections {
        function onRawEvent(event) {
            layoutProc.running = true;
        }

        target: Hyprland
    }

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: layoutProc.running = true
    }

}
