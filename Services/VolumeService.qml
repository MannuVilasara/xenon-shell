import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    property real volume: 0

    function setVolume(v) {
        var percent = Math.round(v * 100);
        setProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", percent + "%"];
        setProc.running = true;
        volume = v;
    }

    Process {
        id: setProc
    }

    Process {
        id: volProc

        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}'"]

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                var val = parseFloat(data.trim());
                if (!isNaN(val))
                    volume = val;

            }
        }

    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: volProc.running = true
    }

}
