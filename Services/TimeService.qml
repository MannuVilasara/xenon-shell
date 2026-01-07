import QtQuick
import qs.Core

Item {
    property string currentTime: Qt.formatDateTime(new Date(), Config.use24HourFormat ? "ddd, MMM dd - HH:mm" : "ddd, MMM dd - hh:mm AP")

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: currentTime = Qt.formatDateTime(new Date(), Config.use24HourFormat ? "ddd, MMM dd - HH:mm" : "ddd, MMM dd - hh:mm AP")
    }

}
