// DESIGN CONCEPT: "Split Precision v2 - Tight Center"
// LAYOUT: 50/50 Split with content gravitation towards center.
// - Left: Album Art anchored Right (towards center).
// - Right: Dashboard anchored Left (towards center).
// - Bottom: Anchored Password Card (Lifted).

import "../Cards"
import "../Components"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Services

Item {
    id: root

    required property var colors
    required property var pam
    property alias inputField: musicPwd.inputField

    // --- State Helpers ---
    property bool hasMedia: MprisService.title !== ""
    property bool isPlaying: MprisService.isPlaying

    // --- Entrance Animations ---
    SequentialAnimation {
        id: entryAnim
        running: true
        
        // 1. Background fade
        NumberAnimation { target: backgroundLayer; property: "opacity"; from: 0; to: 1; duration: 800; easing.type: Easing.OutQuad }
        
        // 2. Elements slide in
        ParallelAnimation {
            // Art pops
            NumberAnimation { target: artWrapper; property: "scale"; from: 0.8; to: 1; duration: 600; easing.type: Easing.OutBack }
            NumberAnimation { target: artWrapper; property: "opacity"; from: 0; to: 1; duration: 400; easing.type: Easing.OutQuad }
            
            // Dashboard slides up
            SequentialAnimation {
                PauseAnimation { duration: 150 }
                ParallelAnimation {
                    NumberAnimation { target: rightDashboard; property: "y"; from: rightDashboard.y + 40; to: rightDashboard.y; duration: 600; easing.type: Easing.OutCubic }
                    NumberAnimation { target: rightDashboard; property: "opacity"; from: 0; to: 1; duration: 500; easing.type: Easing.OutQuad }
                }
            }
            
            // Footer slides up (Modified to lift higher)
            SequentialAnimation {
                PauseAnimation { duration: 300 }
                NumberAnimation { target: footer; property: "anchors.bottomMargin"; from: -50; to: 60; duration: 600; easing.type: Easing.OutCubic }
                NumberAnimation { target: footer; property: "opacity"; from: 0; to: 1; duration: 400; easing.type: Easing.OutQuad }
            }
        }
    }

    // --- Background Layer ---
    Item {
        id: backgroundLayer
        anchors.fill: parent
        opacity: 0 

        property string currentArt: MprisService.artUrl

        onCurrentArtChanged: {
            if (currentArt === "") return;
            if (bgImg1.opacity > 0) {
                bgImg2.source = currentArt;
                crossfadeTo2.start();
            } else {
                bgImg1.source = currentArt;
                crossfadeTo1.start();
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "#050505"
        }

        // Fallback Wallpaper
        Image {
            anchors.fill: parent
            source: Config.lockScreenCustomBackground ? ("file://" + WallpaperService.getWallpaper(Quickshell.screens[0].name)) : ""
            fillMode: Image.PreserveAspectCrop
            visible: MprisService.artUrl === ""
            opacity: 0.5
        }

        // Crossfading Art
        Image { id: bgImg1; anchors.fill: parent; fillMode: Image.PreserveAspectCrop; visible: opacity > 0; asynchronous: true }
        Image { id: bgImg2; anchors.fill: parent; fillMode: Image.PreserveAspectCrop; visible: opacity > 0; opacity: 0; asynchronous: true }

        ParallelAnimation {
            id: crossfadeTo2
            NumberAnimation { target: bgImg2; property: "opacity"; to: 1; duration: 1200 }
            NumberAnimation { target: bgImg1; property: "opacity"; to: 0; duration: 1200 }
        }

        ParallelAnimation {
            id: crossfadeTo1
            NumberAnimation { target: bgImg1; property: "opacity"; to: 1; duration: 1200 }
            NumberAnimation { target: bgImg2; property: "opacity"; to: 0; duration: 1200 }
        }

        layer.enabled: true
        layer.effect: FastBlur {
            radius: 90
            transparentBorder: false
        }

        // Dark Vignette
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#30000000" }
                GradientStop { position: 1.0; color: "#D0000000" }
            }
        }
    }

    // --- Main Layout Container ---
    Item {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footer.top
        
        RowLayout {
            anchors.fill: parent
            spacing: 0

            // --- LEFT PANEL: Album Art ---
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1 
                
                Item {
                    id: artWrapper
                    width: Math.min(parent.width * 0.75, 480)
                    height: width
                    
                    // ALIGNMENT CHANGE: Anchor to right of this container (towards center)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 30 // Gap from center line
                    
                    opacity: 0
                    visible: root.hasMedia

                    scale: root.isPlaying ? 1.0 : 0.95
                    Behavior on scale { NumberAnimation { duration: 1500; easing.type: Easing.InOutSine } }

                    Rectangle {
                        anchors.fill: parent
                        radius: 32
                        color: "#151515"
                        
                        layer.enabled: true
                        layer.effect: DropShadow {
                            transparentBorder: true
                            radius: 50
                            samples: 32
                            color: "#80000000"
                            verticalOffset: 20
                        }

                        Image {
                            anchors.fill: parent
                            source: MprisService.artUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle { width: artWrapper.width; height: artWrapper.height; radius: 32 }
                            }
                        }

                        // Gloss Overlay
                        Rectangle {
                            anchors.fill: parent
                            radius: 32
                            gradient: Gradient {
                                orientation: Gradient.Vertical
                                GradientStop { position: 0.0; color: "#15FFFFFF" }
                                GradientStop { position: 1.0; color: "#00000000" }
                            }
                            border.color: "#20FFFFFF"
                            border.width: 1
                            color: "transparent"
                        }
                    }
                }
            }

            // --- RIGHT PANEL: Dashboard ---
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1 

                ColumnLayout {
                    id: rightDashboard
                    // ALIGNMENT CHANGE: Anchor to left of this container (towards center)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 30 // Gap from center line
                    
                    width: Math.min(parent.width - 60, 420)
                    spacing: 40
                    opacity: 0 // Managed by animation

                    // 1. Time & Date Section
                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 16

                        // Horizontal Clock
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 8

                            Text {
                                text: {
                                    let h = new Date().getHours() % 12 || 12;
                                    return h.toString().padStart(2, '0');
                                }
                                font.family: "StretchPro"
                                font.pixelSize: 100
                                font.weight: Font.Black
                                color: "#FFFFFF"
                                layer.enabled: true
                                layer.effect: Glow { radius: 16; color: "#20FFFFFF" }
                            }

                            Text {
                                text: ":"
                                font.family: "StretchPro"
                                font.pixelSize: 100
                                font.weight: Font.Black
                                color: root.colors.accent
                                Layout.bottomMargin: 12
                                opacity: 0.8
                            }

                            Text {
                                text: Qt.formatTime(new Date(), "mm")
                                font.family: "StretchPro"
                                font.pixelSize: 100
                                font.weight: Font.Black
                                color: "#FFFFFF"
                                layer.enabled: true
                                layer.effect: Glow { radius: 16; color: "#20FFFFFF" }
                            }
                        }

                        // Date Capsule
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: dateRow.implicitWidth + 40
                            height: 40
                            radius: 20
                            color: Qt.rgba(1, 1, 1, 0.08)
                            border.color: Qt.rgba(1, 1, 1, 0.1)
                            border.width: 1

                            Row {
                                id: dateRow
                                anchors.centerIn: parent
                                spacing: 10
                                
                                Text {
                                    text: Qt.formatDate(new Date(), "dddd").toUpperCase()
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 13
                                    font.weight: Font.Bold
                                    color: root.colors.accent
                                }
                                Rectangle {
                                    width: 1; height: 12
                                    color: "#60FFFFFF"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: Qt.formatDate(new Date(), "MMMM d")
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    color: "#DDDDDD"
                                }
                            }
                        }
                    }

                    // 2. Media Player Card
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 180
                        radius: 28
                        color: Qt.rgba(0, 0, 0, 0.4)
                        border.color: Qt.rgba(1, 1, 1, 0.08)
                        border.width: 1
                        visible: root.hasMedia
                        
                        layer.enabled: true
                        layer.effect: DropShadow {
                            transparentBorder: true
                            radius: 24
                            color: "#40000000"
                            verticalOffset: 8
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 24
                            spacing: 0

                            // Track Info
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                
                                Text {
                                    text: MprisService.title || "No Media"
                                    font.family: Config.fontFamily
                                    font.pixelSize: 26
                                    font.weight: Font.Bold
                                    color: "#FFFFFF"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                Text {
                                    text: MprisService.artist || "Unknown Artist"
                                    font.family: Config.fontFamily
                                    font.pixelSize: 16
                                    font.weight: Font.Medium
                                    color: "#AAAAAA"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            // Spacer
                            Item { Layout.fillHeight: true }

                            // Progress Bar
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 4
                                Layout.bottomMargin: 16
                                visible: MprisService.length > 0
                                
                                Rectangle {
                                    anchors.fill: parent
                                    color: "#30FFFFFF"
                                    radius: 2
                                }
                                Rectangle {
                                    height: parent.height
                                    width: (MprisService.position / Math.max(1, MprisService.length)) * parent.width
                                    color: root.colors.accent
                                    radius: 2
                                    
                                    layer.enabled: true
                                    layer.effect: Glow { radius: 6; color: root.colors.accent }
                                }
                            }

                            // Controls Row
                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 32

                                // Prev
                                MouseArea {
                                    Layout.preferredWidth: 40; Layout.preferredHeight: 40
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: MprisService.previous()
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰒮"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 24
                                        color: "#DDDDDD"
                                        opacity: parent.pressed ? 0.7 : 1
                                    }
                                }

                                // Play/Pause FAB
                                MouseArea {
                                    Layout.preferredWidth: 56; Layout.preferredHeight: 56
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: MprisService.playPause()
                                    
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 28
                                        color: root.colors.accent
                                        scale: parent.pressed ? 0.95 : 1
                                        Behavior on scale { NumberAnimation { duration: 100 } }
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: root.isPlaying ? "󰏤" : "󰐊"
                                            font.family: "Symbols Nerd Font"
                                            font.pixelSize: 28
                                            color: root.colors.bg
                                            anchors.horizontalCenterOffset: root.isPlaying ? 0 : 2
                                        }
                                    }
                                }

                                // Next
                                MouseArea {
                                    Layout.preferredWidth: 40; Layout.preferredHeight: 40
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: MprisService.next()
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰒭"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 24
                                        color: "#DDDDDD"
                                        opacity: parent.pressed ? 0.7 : 1
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // --- Footer: Password ---
    Item {
        id: footer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottomMargin: 60 // Lifted up to be less sticky
        height: 120
        z: 20
        opacity: 0 // Managed by animation

        PasswordCard {
            id: musicPwd
            anchors.centerIn: parent
            width: 380
            height: 110
            colors: root.colors
            pam: root.pam
            visible: true
            opacity: 1
            
            cardColor: Qt.rgba(0, 0, 0, 0.75) 
            borderColor: Qt.rgba(1, 1, 1, 0.1)
        }
    }
}