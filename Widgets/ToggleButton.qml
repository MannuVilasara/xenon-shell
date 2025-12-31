import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

SettingItem {
    id: root
    
    // Properties for backward compatibility
    property bool active: false
    property var theme: null // Maps to 'colors' in SettingItem
    
    // Map existing props to SettingItem props
    colors: theme
    
    // Switch component in the content area
    ToggleSwitch {
        checked: root.active
        theme: root.theme
        onCheckedChanged: {
            if (root.active !== checked) {
                root.active = checked
            }
        }
    }
}
