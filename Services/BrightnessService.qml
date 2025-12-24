import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    property real brightness: 0

    function setBrightness(v) {
        var percent = Math.round(v * 100);
        setProc.command = ["brightnessctl", "s", percent + "%"];
        setProc.running = true;
        brightness = v;
    }

    Process {
        id: setProc
    }

    Process {
        id: brightProc

        command: ["brightnessctl", "-m"]

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                var parts = data.split(",");
                for (var i = 0; i < parts.length; i++) {
                    if (parts[i].endsWith("%")) {
                        var val = parseFloat(parts[i]);
                        brightness = val / 100;
                        return ;
                    }
                }
            }
        }

    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: brightProc.running = true
    }

}
