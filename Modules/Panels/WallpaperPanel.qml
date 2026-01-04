import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Core
import qs.Services
import qs.Modules.Corners

PanelWindow {
    id: root

    required property var globalState
    property bool internalOpen: false
    
    property int currentScreenIndex: 0
    property string wallpaperPath: WallpaperService.defaultDirectory
    property var wallpapersList: []
    property string currentWallpaper: ""

    function updateWallpaperData() {
        if (Quickshell.screens[currentScreenIndex]) {
            var screenName = Quickshell.screens[currentScreenIndex].name;
            wallpapersList = WallpaperService.getWallpapersList(screenName);
            currentWallpaper = WallpaperService.getWallpaper(screenName);
        }
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"
    visible: false
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "wallpaper-panel"
    WlrLayershell.exclusiveZone: -1
    


    Connections {
        target: globalState
        function onWallpaperPanelOpenChanged() {
            if (globalState.wallpaperPanelOpen) {
                closeTimer.stop(); // Stop any pending close action
                root.visible = true;
                openTimer.restart();
                updateWallpaperData();
                
                var idx = wallpapersList.indexOf(currentWallpaper);
                if (idx !== -1) {
                    wallpaperListView.currentIndex = idx;
                    wallpaperListView.positionViewAtIndex(idx, ListView.Center);
                }
            } else {
                openTimer.stop(); // Stop any pending open action
                internalOpen = false;
                closeTimer.restart();
            }
        }
    }

    Connections {
        target: WallpaperService
        function onWallpaperChanged(screenName, path) {
            if (Quickshell.screens[currentScreenIndex] && screenName === Quickshell.screens[currentScreenIndex].name)
                updateWallpaperData();
        }
        function onWallpaperListChanged(screenName, count) {
            if (Quickshell.screens[currentScreenIndex] && screenName === Quickshell.screens[currentScreenIndex].name)
                updateWallpaperData();
        }
    }

    Timer { id: openTimer; interval: 10; onTriggered: root.internalOpen = true }
    Timer { id: closeTimer; interval: 250; onTriggered: root.visible = false }

    Colors { id: theme }

    MouseArea {
        anchors.fill: parent
        onClicked: globalState.wallpaperPanelOpen = false
        z: -1
    }

    Item {
        id: slideContainer
        
        height: 260
        width: parent.width * 0.4
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        
        transform: Translate {
            y: root.internalOpen ? 0 : slideContainer.height
            Behavior on y {
                NumberAnimation { 
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }
        }
        
        
        RoundCorner {
            anchors.bottom: parent.bottom
            anchors.right: parent.left
            corner: RoundCorner.CornerEnum.BottomRight
            size: 30
            color: panelBackground.color
        }
        
        RoundCorner {
            anchors.bottom: parent.bottom
            anchors.left: parent.right
            corner: RoundCorner.CornerEnum.BottomLeft
            size: 30
            color: panelBackground.color
        }


        Rectangle {
            id: mainPanel
            anchors.fill: parent
            color: "transparent"
            clip: true
            
            Rectangle {
                id: panelBackground
                anchors.fill: parent
                color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.98)
                radius: 20
                
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 21
                    color: parent.color
                }
            }
            


            ListView {
                id: wallpaperListView
                anchors.fill: parent
                anchors.margins: 24
                anchors.topMargin: 20
                anchors.bottomMargin: 20
                
                orientation: ListView.Horizontal
                spacing: 2
                clip: true
                topMargin: 4
                bottomMargin: 4
                leftMargin: 4
                rightMargin: 4
                
                model: wallpapersList
                
                property real itemWidth: (width - (spacing * 2)) / 3
                
                keyNavigationEnabled: true
                focus: true
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 200
                preferredHighlightBegin: itemWidth + spacing
                preferredHighlightEnd: itemWidth * 2 + spacing
                highlightRangeMode: ListView.StrictlyEnforceRange
                
                flickableDirection: Flickable.HorizontalFlick
                boundsBehavior: Flickable.StopAtBounds
                
                Keys.onReturnPressed: {
                    if (currentItem && wallpapersList[currentIndex]) {
                        WallpaperService.changeWallpaper(wallpapersList[currentIndex], undefined);
                    }
                }
                Keys.onEnterPressed: {
                    if (currentItem && wallpapersList[currentIndex]) {
                        WallpaperService.changeWallpaper(wallpapersList[currentIndex], undefined);
                    }
                }
                Keys.onEscapePressed: globalState.wallpaperPanelOpen = false
                Keys.onUpPressed: currentIndex = (currentIndex + 1) % count
                Keys.onDownPressed: currentIndex = (currentIndex - 1 + count) % count
                
                highlight: Item {
                    z: 10
                    Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }

                delegate: Item {
                    id: delegateRoot
                    required property string modelData
                    required property int index
                    
                    property bool isSelected: (modelData === currentWallpaper)
                    property bool isHovered: itemMouse.containsMouse
                    property bool isCurrent: ListView.isCurrentItem
                    
                    width: wallpaperListView.itemWidth
                    height: wallpaperListView.height - 8  // Full height minus padding
                    
                    Rectangle {
                        id: card
                        anchors.centerIn: parent
                        
                        width: isCurrent ? parent.width : parent.width * 0.70
                        height: parent.height
                        
                        radius: 16
                        color: theme.bg
                        
                        border.width: isHovered ? 2 : 0
                        border.color: Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.4)
                        
                        Behavior on border.width { NumberAnimation { duration: 200 } }
                        Behavior on border.color { ColorAnimation { duration: 200 } }
                        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                        Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                        
                        scale: (delegateRoot.isHovered || delegateRoot.isCurrent) ? 1.05 : 1.0
                        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        
                        opacity: isCurrent ? 1.0 : 0.5
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                        
                        Image {
                            id: img
                            anchors.fill: parent
                            anchors.margins: card.border.width
                            
                            readonly property string fileName: modelData.split('/').pop()
                            readonly property string thumbSource: "file://" + WallpaperService.previewDirectory + "/" + fileName
                            readonly property string originalSource: "file://" + modelData
                            
                            source: thumbSource
                            sourceSize.width: 400
                            sourceSize.height: 280
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            smooth: true
                            
                            opacity: status === Image.Ready ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 250 } }
                            
                            onStatusChanged: {
                                if (status === Image.Error && source !== originalSource)
                                    source = originalSource;
                            }
                            
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: img.width
                                    height: img.height
                                    radius: 14
                                }
                            }
                        }
                        
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottomMargin: -6
                            
                            width: 32
                            height: 32
                            radius: 16
                            color: theme.accent
                            
                            visible: delegateRoot.isSelected
                            
                           transform: Translate {
                                y: delegateRoot.isSelected ? 0 : 10
                                Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: ""
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 16
                                color: theme.bg
                                font.bold: true
                            }
                            
                            layer.enabled: true
                            layer.effect: DropShadow {
                                transparentBorder: true
                                horizontalOffset: 0
                                verticalOffset: 2
                                radius: 8
                                samples: 16
                                color: Qt.rgba(0,0,0,0.2)
                            }
                        }
                        
                        Rectangle {
                            id: loadingOverlay
                            anchors.fill: parent
                            radius: parent.radius
                            color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.3)
                            visible: img.status === Image.Loading
                            
                            Text {
                                id: loaderIcon
                                anchors.centerIn: parent
                                text: ""
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 32
                                color: theme.subtext
                                opacity: 0.5
                                
                                SequentialAnimation on rotation {
                                    loops: Animation.Infinite
                                    running: loadingOverlay.visible
                                    NumberAnimation { from: 0; to: 360; duration: 1000 }
                                }
                            }
                        }

                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                wallpaperListView.currentIndex = index;
                                WallpaperService.changeWallpaper(modelData, undefined);
                            }
                        }
                    }
                }

                ScrollBar.horizontal: ScrollBar {
                    policy: ScrollBar.AlwaysOff
                }
            }
        }
    }
}