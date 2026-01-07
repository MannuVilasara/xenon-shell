import "../Components"
import QtQuick
import QtQuick.Layouts
import qs.Core

BentoCard {
    id: root

    required property var colors
    property int hours: new Date().getHours()
    property int minutes: new Date().getMinutes()
    property int seconds: new Date().getSeconds()
    property bool isPM: hours >= 12
    property int displayHours: Config.use24HourFormat ? hours : ((hours % 12) || 12)

    cardColor: colors.surface
    borderColor: colors.border

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date();
            root.hours = now.getHours();
            root.minutes = now.getMinutes();
            root.seconds = now.getSeconds();
            root.isPM = root.hours >= 12;
            root.displayHours = Config.use24HourFormat ? root.hours : ((root.hours % 12) || 12);
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12

        Text {
            text: root.displayHours.toString().padStart(2, '0') + ":" + root.minutes.toString().padStart(2, '0') + (Config.use24HourFormat ? "" : (root.isPM ? " PM" : " AM"))
            font.pixelSize: 48
            font.weight: Font.Bold
            font.family: "JetBrainsMono Nerd Font"
            color: root.colors.fg
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: Qt.formatDate(new Date(), "dd/MM/yy")
            font.pixelSize: 16
            color: root.colors.muted
            Layout.alignment: Qt.AlignHCenter
        }

    }

}
