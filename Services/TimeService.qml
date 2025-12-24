import QtQuick

Item {
    property string currentTime: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: currentTime = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
    }

}
