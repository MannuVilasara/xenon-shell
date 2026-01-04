import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    // --- Exposed Properties ---
    property string distroName: "Arch Linux"
    property string distroUrl: "https://archlinux.org/"
    // Using Nerd Font icon as placeholder for the SVG/Image
    property string distroIcon: "" 
    
    property string dotfilesName: "illogical-impulse"
    property string dotfilesUrl: "https://github.com/end-4/dots-hyprland"
    property string dotfilesIcon: "" // Asterisk-like icon

    // --- Theme Specification ---
    property color backgroundColor: "#1e1e2e" // Dark Base
    property color cardColor: "#313244"       // Surface 1
    property color textPrimary: "#ffffff"     // White
    property color textSecondary: "#a6adc8"   // Muted Gray
    property color accentColor: "#89b4fa"     // Blue Accent
    property int cornerRadius: 16

    implicitWidth: 600
    implicitHeight: 800

    // --- Main Layout ---
    Rectangle {
        anchors.fill: parent
        color: root.backgroundColor

        ScrollView {
            anchors.fill: parent
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 24
                
                // Outer Padding
                anchors.margins: 24
                anchors.topMargin: 24
                anchors.bottomMargin: 24
                
                // 1. Distro Section
                AboutCard {
                    iconSource: root.distroIcon
                    titleText: root.distroName
                    linkUrl: root.distroUrl
                    
                    actions: [
                        { icon: "", label: "Documentation", url: "https://wiki.archlinux.org/" },
                        { icon: "", label: "Help & Support", url: "https://bbs.archlinux.org/" },
                        { icon: "", label: "Report a Bug", url: "https://bugs.archlinux.org/" },
                        { icon: "", label: "Privacy Policy", url: "https://terms.archlinux.org/docs/privacy-policy/" }
                    ]
                }

                // 2. Dotfiles Section
                AboutCard {
                    iconSource: root.dotfilesIcon
                    titleText: root.dotfilesName
                    linkUrl: root.dotfilesUrl
                    
                    actions: [
                        { icon: "", label: "Documentation", url: root.dotfilesUrl + "#readme" },
                        { icon: "", label: "Issues", url: root.dotfilesUrl + "/issues" },
                        { icon: "", label: "Discussions", url: root.dotfilesUrl + "/discussions" },
                        { icon: "", label: "Donate", url: "https://ko-fi.com/" }
                    ]
                }

                // 3. Contributors Section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Layout.topMargin: 8

                    Text {
                        text: "Contributors"
                        font.pixelSize: 18
                        font.bold: true
                        color: root.textPrimary
                        Layout.leftMargin: 4
                    }

                    GridLayout {
                        columns: 2 // Two-column grid
                        columnSpacing: 16
                        rowSpacing: 16
                        Layout.fillWidth: true

                        // Example Data
                        Repeater {
                            model: [
                                { name: "John Doe", role: "Lead Developer", url: "https://github.com/johndoe" },
                                { name: "Jane Smith", role: "UI/UX Designer", url: "https://github.com/janesmith" }
                            ]

                            delegate: ContributorCard {
                                name: modelData.name
                                role: modelData.role
                                url: modelData.url
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
                
                // Spacer at bottom
                Item { height: 24; Layout.fillWidth: true }
            }
        }
    }

    // --- Reusable Components ---

    component AboutCard : Rectangle {
        id: cardRoot
        property string iconSource
        property string titleText
        property string linkUrl
        property var actions: []

        Layout.fillWidth: true
        implicitHeight: cardCol.implicitHeight + 48 // Internal padding
        color: root.cardColor
        radius: root.cornerRadius
        
        // Subtle Shadow/Elevation
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.05)

        ColumnLayout {
            id: cardCol
            anchors.fill: parent
            anchors.margins: 24
            spacing: 24

            // Header: Icon + Title + Link
            RowLayout {
                spacing: 20
                Layout.fillWidth: true

                // Icon Placeholder
                Rectangle {
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64
                    radius: 16
                    color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.1)
                    
                    Text {
                        anchors.centerIn: parent
                        text: cardRoot.iconSource
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 32
                        color: root.accentColor
                    }
                }

                // Text Content
                ColumnLayout {
                    spacing: 4
                    Layout.fillWidth: true
                    
                    Text {
                        text: cardRoot.titleText
                        font.pixelSize: 24
                        font.bold: true
                        color: root.textPrimary
                    }
                    
                    Text {
                        text: cardRoot.linkUrl
                        font.pixelSize: 14
                        color: root.accentColor
                        font.underline: urlHover.containsMouse
                        
                        MouseArea {
                            id: urlHover
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: Qt.openUrlExternally(cardRoot.linkUrl)
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1, 1, 1, 0.1)
            }

            // Action Buttons Row (Flow)
            Flow {
                Layout.fillWidth: true
                spacing: 12
                
                Repeater {
                    model: cardRoot.actions
                    delegate: Rectangle {
                        width: actionRow.implicitWidth + 32
                        height: 36
                        radius: 18 // Pill shape
                        color: actionHover.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.1)
                        
                        // Interaction
                        MouseArea {
                            id: actionHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Qt.openUrlExternally(modelData.url)
                        }

                        RowLayout {
                            id: actionRow
                            anchors.centerIn: parent
                            spacing: 8
                            Text { 
                                text: modelData.icon
                                font.family: "Symbols Nerd Font"
                                color: root.textSecondary 
                            }
                            Text { 
                                text: modelData.label
                                color: root.textPrimary 
                                font.weight: Font.Medium
                                font.pixelSize: 13
                            }
                        }
                    }
                }
            }
        }
    }

    component ContributorCard : Rectangle {
        property string name
        property string role
        property string url
        
        implicitHeight: 80
        color: root.cardColor
        radius: 12
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.05)
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Qt.openUrlExternally(url)
            onEntered: parent.color = Qt.lighter(root.cardColor, 1.1)
            onExited: parent.color = root.cardColor
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16
            
            // Avatar Placeholder (Circle)
            Rectangle {
                width: 48; height: 48
                radius: 24
                color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.2)
                
                Text {
                    anchors.centerIn: parent
                    text: name.charAt(0)
                    font.bold: true
                    font.pixelSize: 20
                    color: root.accentColor
                }
            }
            
            ColumnLayout {
                spacing: 2
                Text { 
                    text: name
                    font.bold: true
                    font.pixelSize: 16
                    color: root.textPrimary 
                }
                Text { 
                    text: role
                    font.pixelSize: 13
                    color: root.textSecondary 
                }
            }
        }
    }
}