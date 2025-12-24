import QtQuick
import Quickshell.Io

Item {
    property string version: "Linux"

    Process {
        id: kernelProc

        command: ["uname", "-r"]
        Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (data)
                    version = data.trim();

            }
        }

    }

}
