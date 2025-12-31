import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    default property alias content: container.data
    property string label: ""
    property string sublabel: ""
    property string icon: ""
    
    // Theme options
    property var colors: null
    
    implicitHeight: Math.max(64, container.implicitHeight + 24)
    Layout.fillWidth: true
    
    radius: 12
    color: colors ? colors.surface : "#1e1e2e"
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16
        
        // Icon
        Rectangle {
            visible: root.icon !== ""
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 10
            color: Qt.rgba(root.colors ? root.colors.accent.r : 0.5, root.colors ? root.colors.accent.g : 0.5, root.colors ? root.colors.accent.b : 0.5, 0.1)
            
            Text {
                anchors.centerIn: parent
                text: root.icon
                font.family: "Symbols Nerd Font"
                font.pixelSize: 20
                color: root.colors ? root.colors.accent : "#cba6f7"
            }
        }
        
        // Text
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            
            Text {
                text: root.label
                font.pixelSize: 14
                font.weight: Font.Medium
                color: root.colors ? root.colors.fg : "#cdd6f4"
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
            
            Text {
                text: root.sublabel
                font.pixelSize: 12
                color: root.colors ? root.colors.muted : "#a6adc8"
                visible: root.sublabel !== ""
                Layout.fillWidth: true
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
            }
        }
        
        // Right side content (Switch, TextField, etc)
        RowLayout {
            id: container
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            spacing: 10
        }
    }
}
