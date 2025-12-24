import QtQuick
import Quickshell.Io

Item {
    property int usage: 0

    Process {
        id: memProc

        command: ["sh", "-c", "free | grep Mem"]

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                var parts = data.trim().split(/\s+/);
                var total = parseInt(parts[1]) || 1;
                var used = parseInt(parts[2]) || 0;
                usage = Math.round(100 * used / total);
            }
        }

    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: memProc.running = true
    }

}
