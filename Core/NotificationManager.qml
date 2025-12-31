import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    property ListModel notifications
    property var currentPopup: null
    property bool popupVisible: false
    property int notificationCounter: 0

    function closePopup() {
        popupVisible = false;
    }

    function clearHistory() {
        for (var i = 0; i < notifications.count; i++) {
            var item = notifications.get(i);
            if (item.ref)
                item.ref.dismiss();

        }
        notifications.clear();
        popupVisible = false;
    }

    function removeAtIndex(index) {
        var item = notifications.get(index);
        if (item && item.ref)
            item.ref.dismiss();

        notifications.remove(index);
    }

    function removeById(notifId) {
        Logger.d("NotifMan", "Removing notification with ID:", notifId);
        for (var i = 0; i < notifications.count; i++) {
            var item = notifications.get(i);
            if (item.id === notifId) {
                Logger.d("NotifMan", "  Found! Dismissing and removing...");
                if (item.ref) {
                    try {
                        item.ref.dismiss();
                    } catch (e) {
                         Logger.w("NotifMan", "Failed to dismiss notification (already destroyed?): " + e);
                    }
                }
                notifications.remove(i);
                return ;
            }
        }
        Logger.d("NotifMan", "  Not found!");
    }

    function removeSilent(notifId) {
        for (var i = 0; i < notifications.count; i++) {
            if (notifications.get(i).id === notifId) {
                notifications.remove(i);
                return;
            }
        }
    }

    function removeByRef(notificationRef) {
        for (var i = 0; i < notifications.count; i++) {
            if (notifications.get(i).ref === notificationRef) {
                notifications.remove(i);
                break;
            }
        }
    }

    NotificationServer {
        id: server

        bodySupported: true
        imageSupported: true
        actionsSupported: true
        onNotification: (notification) => {
            notification.tracked = true;
            var uniqueId = root.notificationCounter++;
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
            });
            Logger.d("NotifMan", "Notification added:", notification.summary, "ID:", uniqueId, "Total count:", root.notifications.count);
            
            // Force update popup even if visible
            root.currentPopup = notification;
            root.popupVisible = true;
            root.popupVisibleChanged(); // Manually signal change if it was already true? No, bind to currentPopup in Toast.
            
            // Auto close timer
            popupTimer.restart();
            
            notification.closed.connect(() => {
                Logger.d("NotifMan", "Notification closed signal received for ID:", uniqueId);
                root.removeSilent(uniqueId);
                if (root.currentPopup === notification)
                    root.popupVisible = false;

            });
        }
    }

    Timer {
        id: popupTimer

        interval: 5000
        onTriggered: root.popupVisible = false
    }

    notifications: ListModel {
    }

}
