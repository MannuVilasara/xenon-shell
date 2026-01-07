import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import "Views"
import qs.Core
import qs.Services

WlSessionLockSurface {
    id: root

    required property var lock
    required property var pam
    required property var colors
    readonly property bool musicModeActive: Config.lockScreenMusicMode && (MprisService.artUrl !== "" || MprisService.title !== "")

    color: "transparent"
    onMusicModeActiveChanged: focusTimer.restart()
    Component.onCompleted: {
        console.log("LockScreen: Controller Loaded. MusicMode=" + musicModeActive);
        focusTimer.restart();
    }

    ListModel {
        id: notifications
    }

    NotificationServer {
        id: server

        bodySupported: true
        imageSupported: true
        onNotification: (n) => {
            n.tracked = true;
            notifications.insert(0, {
                "summary": n.summary || "Notification",
                "body": n.body || "",
                "appName": n.appName || "",
                "appIcon": n.appIcon || "",
                "time": Qt.formatTime(new Date(), Config.use24HourFormat ? "HH:mm" : "hh:mm AP")
            });
        }
    }

    LockScreenDefault {
        id: defaultView

        anchors.fill: parent
        visible: !musicModeActive
        enabled: visible
        colors: root.colors
        pam: root.pam
        notifications: notifications
    }

    LockScreenMusic {
        id: musicView

        anchors.fill: parent
        visible: musicModeActive
        enabled: visible
        colors: root.colors
        pam: root.pam
    }

    Timer {
        id: focusTimer

        interval: 100
        repeat: false
        onTriggered: {
            if (musicModeActive)
                musicView.inputField.forceActiveFocus();
            else
                defaultView.inputField.forceActiveFocus();
        }
    }

}
