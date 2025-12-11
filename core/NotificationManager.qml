import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    // --- Data Store ---
    property ListModel notifications: ListModel {}
    property var currentPopup: null
    property bool popupVisible: false
    property int notificationCounter: 0

    // --- The Server ---
    NotificationServer {
        id: server
        // running: true  <-- REMOVED THIS LINE (It doesn't exist)
        
        // Capabilities
        bodySupported: true
        imageSupported: true
        actionsSupported: true

        onNotification: (notification) => {
            // 1. Keep it alive
            notification.tracked = true

            // 2. Generate unique ID
            var uniqueId = root.notificationCounter++

            // 3. Add to History
            root.notifications.insert(0, {
                "id": uniqueId,
                "ref": notification,
                "appName": notification.appName,
                "summary": notification.summary,
                "body": notification.body,
                "appIcon": notification.appIcon,
                "image": notification.image,
                "urgency": notification.urgency,
                "time": Qt.formatTime(new Date(), "hh:mm")
            })

            console.log("Notification added:", notification.summary, "ID:", uniqueId, "Total count:", root.notifications.count)

            // 3. Show Popup
            root.currentPopup = notification
            root.popupVisible = true
            popupTimer.restart()

            // 4. Listen for External Close
            notification.closed.connect(() => {
                root.removeById(notification)
                if (root.currentPopup === notification) {
                    root.popupVisible = false
                }
            })
        }
    }

    // --- Popup Timer ---
    Timer {
        id: popupTimer
        interval: 5000
        onTriggered: root.popupVisible = false
    }

    function closePopup() {
        popupVisible = false
    }

    // --- History Management ---
    function clearHistory() {
        for (var i = 0; i < notifications.count; i++) {
            var item = notifications.get(i)
            if (item.ref) item.ref.dismiss()
        }
        notifications.clear()
        popupVisible = false
    }

    function removeAtIndex(index) {
        var item = notifications.get(index)
        if (item && item.ref) {
            item.ref.dismiss()
        }
        notifications.remove(index)
    }

    function removeById(notifId) {
        console.log("Removing notification with ID:", notifId)
        for (var i = 0; i < notifications.count; i++) {
            var item = notifications.get(i)
            console.log("  Checking index", i, "ID:", item.id)
            if (item.id === notifId) {
                console.log("  Found! Removing...")
                if (item.ref) item.ref.dismiss()
                notifications.remove(i)
                return
            }
        }
        console.log("  Not found!")
    }

    function removeByRef(notificationRef) {
        for (var i = 0; i < notifications.count; i++) {
            if (notifications.get(i).ref === notificationRef) {
                notifications.remove(i)
                break
            }
        }
    }
}