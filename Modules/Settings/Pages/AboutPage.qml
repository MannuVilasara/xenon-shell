import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../../Services" as LocalServices

ColumnLayout {
    id: root
    
    // --- Context & Theme ---
    property var context
    property var colors: context.colors
    
    width: parent.width
    spacing: 40 // Generous spacing for modern look

    // --- Services ---
    LocalServices.DistroInfoService {
        id: distroInfo
    }

    // --- Properties ---
    property string distroName: distroInfo.name
    property string distroUrl: distroInfo.url
    property string distroIcon: distroInfo.icon
    property string distroBugUrl: distroInfo.bugUrl !== "" ? distroInfo.bugUrl : distroInfo.url
    property string distroSupportUrl: distroInfo.supportUrl !== "" ? distroInfo.supportUrl : distroInfo.url

    // =========================================================================
    // SECTION 1: DISTRO HERO
    // =========================================================================
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 280
        color: colors.surface
        radius: 24
        
        // Gradient overlay for depth
        Rectangle {
            anchors.fill: parent
            radius: 24
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(colors.accent.r, colors.accent.g, colors.accent.b, 0.05) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        border.width: 1
        border.color: Qt.rgba(colors.border.r, colors.border.g, colors.border.b, 0.3)

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20
            
            // Glowing Icon
            Item {
                Layout.alignment: Qt.AlignHCenter
                width: 100; height: 100
                
                // Glow
                Rectangle {
                    anchors.centerIn: parent
                    width: 80; height: 80
                    radius: 40
                    color: colors.accent
                    opacity: 0.15
                    scale: 1.2
                }
                
                Text {
                    anchors.centerIn: parent
                    text: root.distroIcon
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 80
                    color: colors.accent
                }
            }
            
            // Text Info
            ColumnLayout {
                spacing: 4
                
                Text {
                    text: root.distroName
                    font.pixelSize: 28
                    font.weight: Font.Bold
                    color: colors.fg
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: "Operating System"
                    font.pixelSize: 14
                    color: colors.muted
                    font.weight: Font.Medium
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            
            // Action Pills
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12
                
                ActionPill { icon: ""; label: "Website"; url: root.distroUrl }
                ActionPill { icon: ""; label: "Support"; url: root.distroSupportUrl }
                ActionPill { icon: ""; label: "Issues"; url: root.distroBugUrl }
            }
        }
    }

    // =========================================================================
    // SECTION 2: CORE DEVELOPERS
    // =========================================================================
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 16
        
        // Section Header
        RowLayout {
            spacing: 12
            Rectangle {
                width: 4; height: 24
                radius: 2
                color: colors.accent
            }
            Text {
                text: "Core Developers"
                font.pixelSize: 18
                font.weight: Font.Bold
                color: colors.fg
            }
        }

        // Responsive Grid
        GridLayout {
            Layout.fillWidth: true
            columns: root.width > 500 ? 2 : 1
            columnSpacing: 16
            rowSpacing: 16

            Repeater {
                model: [
                    { 
                        name: "Manpreet Vilasara", 
                        role: "Lead Developer", 
                        url: "https://github.com/mannuvilasara", 
                        image: "/etc/xdg/quickshell/mannu/Assets/mannu.png" 
                    },
                    { 
                        name: "Keshav Gilhotra", 
                        role: "Core Developer", 
                        url: "https://github.com/ikeshav26", 
                        image: "/etc/xdg/quickshell/mannu/Assets/keshav.png" 
                    }
                ]

                delegate: Rectangle {
                    id: devCard
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    
                    radius: 20
                    color: colors.surface
                    
                    border.width: 1
                    border.color: hoverHandler.hovered ? colors.accent : Qt.rgba(colors.border.r, colors.border.g, colors.border.b, 0.4)
                    
                    // Hover Animations
                    scale: hoverHandler.hovered ? 1.02 : 1.0
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    HoverHandler {
                        id: hoverHandler
                        cursorShape: Qt.PointingHandCursor
                    }
                    
                    TapHandler {
                        onTapped: Qt.openUrlExternally(modelData.url)
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16
                        
                        // Avatar Circle
                        Item {
                            Layout.preferredWidth: 68
                            Layout.preferredHeight: 68
                            
                            // Image Container
                            Image {
                                id: avatar
                                anchors.fill: parent
                                source: "file://" + modelData.image
                                sourceSize: Qt.size(68, 68)
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                                visible: false // Hidden, used for mask
                                
                                onStatusChanged: {
                                    if (status === Image.Error) fallback.visible = true;
                                }
                            }
                            
                            // Circle Mask
                            OpacityMask {
                                anchors.fill: parent
                                source: avatar
                                maskSource: Rectangle {
                                    width: 68; height: 68
                                    radius: 34
                                    visible: true
                                }
                                visible: avatar.status === Image.Ready
                            }
                            
                            // Fallback Initials
                            Rectangle {
                                id: fallback
                                anchors.fill: parent
                                radius: 34
                                color: Qt.rgba(colors.accent.r, colors.accent.g, colors.accent.b, 0.2)
                                visible: avatar.status !== Image.Ready
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.name.charAt(0)
                                    font.bold: true
                                    font.pixelSize: 24
                                    color: colors.accent
                                }
                            }
                        }
                        
                        // Info
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: modelData.name
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: colors.fg
                            }
                            
                            Text {
                                text: modelData.role
                                font.pixelSize: 13
                                color: colors.muted
                                font.weight: Font.Medium
                            }
                        }
                        
                        // Arrow Icon
                        Rectangle {
                            width: 32; height: 32
                            radius: 16
                            color: hoverHandler.hovered ? colors.accent : "transparent"
                            border.width: 1
                            border.color: hoverHandler.hovered ? colors.accent : colors.muted
                            Behavior on color { ColorAnimation { duration: 200 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "" // Github icon
                                font.family: "Symbols Nerd Font"
                                color: hoverHandler.hovered ? colors.bg : colors.muted
                            }
                        }
                    }
                }
            }
        }
    }
    
    Item { Layout.fillHeight: true } // Bottom spacer

    // --- Components ---

    component ActionPill : Rectangle {
        id: pill
        property string icon
        property string label
        property string url
        
        implicitWidth: pillRow.implicitWidth + 24
        implicitHeight: 32
        radius: 16
        
        color: pillHover.containsMouse ? colors.accent : "transparent"
        border.width: 1
        border.color: pillHover.containsMouse ? colors.accent : Qt.rgba(colors.border.r, colors.border.g, colors.border.b, 0.5)
        
        Behavior on color { ColorAnimation { duration: 150 } }
        
        MouseArea {
            id: pillHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Qt.openUrlExternally(pill.url)
        }

        RowLayout {
            id: pillRow
            anchors.centerIn: parent
            spacing: 8
            
            Text {
                text: pill.icon
                font.family: "Symbols Nerd Font"
                color: pillHover.containsMouse ? colors.bg : colors.muted
                font.pixelSize: 14
            }
            
            Text {
                text: pill.label
                font.weight: Font.Medium
                color: pillHover.containsMouse ? colors.bg : colors.fg
                font.pixelSize: 12
            }
        }
    }
}