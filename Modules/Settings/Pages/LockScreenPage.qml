import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Widgets
import qs.Services

ColumnLayout {
    spacing: 16
    property var context // Injected context
    property var colors: context.colors

    Text {
        text: "Lock Screen"
        font.family: Config.fontFamily
        font.pixelSize: 20
        font.bold: true
        color: colors.fg
    }

    ToggleButton {
        Layout.fillWidth: true
        label: "Lock Screen Blur"
        sublabel: "Enable blur effect on lock screen"
        icon: "󰂚"
        active: !Config.disableLockBlur
        theme: colors
        onActiveChanged: {
            if (active !== !Config.disableLockBlur) {
                Config.disableLockBlur = !active
            }
        }
    }

    ToggleButton {
        Layout.fillWidth: true
        label: "Lock Screen Animation"
        sublabel: "Enable startup animation on lock screen"
        icon: "󰑮"
        active: !Config.disableLockAnimation
        theme: colors
        onActiveChanged: {
            if (active !== !Config.disableLockAnimation) {
                Config.disableLockAnimation = !active
            }
        }
    }

    ToggleButton {
        Layout.fillWidth: true
        label: "Wallpaper Only Lockscreen"
        sublabel: "Show only wallpaper (hide windows/bar)"
        icon: "󰸉"
        active: Config.lockScreenCustomBackground
        theme: colors
        onActiveChanged: {
            if (active !== Config.lockScreenCustomBackground) {
                Config.lockScreenCustomBackground = active
            }
        }
    }
}
