import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../services"

Item {
    id: root
    anchors.fill: parent

    // Active wallpaper source
    property string source: ""
    property Image currentImage: img1
    property int transitionType: 0
    
    // Get the screen name for this wallpaper instance
    property string screenName: screen ? screen.name : ""
    
    // Update wallpaper when service emits changes
    Connections {
        target: WallpaperService
        
        function onWallpaperChanged(changedScreenName, path) {
            if (changedScreenName === screenName) {
                console.log("[Wallpaper] Wallpaper changed for", screenName, "to", path);
                root.source = "file://" + path;
                // Random transition with more variety
                transitionType = Math.floor(Math.random() * 15);
                console.log("[Wallpaper] Selected transition type:", transitionType);
            }
        }
    }
    
    // Load initial wallpaper once service is initialized
    Connections {
        target: WallpaperService
        
        function onIsInitializedChanged() {
            if (WallpaperService.isInitialized && !root.source) {
                var wallpaper = WallpaperService.getWallpaper(screenName);
                if (wallpaper && wallpaper !== "") {
                    console.log("[Wallpaper] Loading initial wallpaper for", screenName, ":", wallpaper);
                    root.source = "file://" + wallpaper;
                }
            }
        }
    }
    
    Component.onCompleted: {
        // Try to load wallpaper if service is already initialized
        if (WallpaperService.isInitialized) {
            var wallpaper = WallpaperService.getWallpaper(screenName);
            if (wallpaper && wallpaper !== "") {
                console.log("[Wallpaper] Loading wallpaper for", screenName, ":", wallpaper);
                root.source = "file://" + wallpaper;
            }
        }
    }
    
    // Visual Double-Buffering with transition control
    onSourceChanged: {
        console.log("[Wallpaper] Source changed to:", source);
        if (source === "") {
            currentImage = null;
        } else {
            var nextImage = (currentImage === img1) ? img2 : img1;
            console.log("[Wallpaper] Loading into", (nextImage === img1 ? "img1" : "img2"));
            
            // Reset all properties to default before loading
            nextImage.opacity = 0;
            nextImage.scale = 1;
            nextImage.x = 0;
            nextImage.y = 0;
            nextImage.rotation = 0;
            
            // Load the new image
            nextImage.source = root.source;
        }
    }
    
    // --- Visuals (Placeholder & Images) ---
    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        visible: root.source === ""
        z: 10
        
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20
            
            Text {
                text: "󰸉"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 64
                color: "#f38ba8"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: "No wallpaper set"
                color: "#cdd6f4"
                font.bold: true
                font.pixelSize: 24
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: "Open the wallpaper panel to select one"
                color: "#a6adc8"
                font.pixelSize: 16
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // Background image (img1)
    Item {
        id: img1Container
        anchors.fill: parent
        
        Image {
            id: img1
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true
            
            opacity: (root.currentImage === img1) ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: 900
                    easing.type: Easing.InOutCubic
                }
            }
            
            Behavior on scale {
                NumberAnimation {
                    duration: 900
                    easing.type: Easing.InOutCubic
                }
            }
            
            Behavior on x {
                NumberAnimation {
                    duration: 900
                    easing.type: Easing.InOutCubic
                }
            }
            
            Behavior on y {
                NumberAnimation {
                    duration: 900
                    easing.type: Easing.InOutCubic
                }
            }
            
            Behavior on rotation {
                NumberAnimation {
                    duration: 900
                    easing.type: Easing.InOutCubic
                }
            }
            
            onStatusChanged: {
                console.log("[Wallpaper] img1 status:", status === Image.Ready ? "Ready" : status === Image.Loading ? "Loading" : "Error");
                if (status === Image.Ready && root.currentImage !== img1 && source == root.source) {
                    console.log("[Wallpaper] img1 ready, will apply transition type:", root.transitionType);
                    Qt.callLater(function() {
                        applyTransition(img1, img2);
                    });
                }
            }
        }
    }

    // Foreground image (img2)
    Item {
        id: img2Container
        anchors.fill: parent
        
        Image {
            id: img2
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true
            
            opacity: (root.currentImage === img2) ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.InOutCubic
                }
            }
            
            Behavior on scale {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.InOutCubic
                }
            }
            
            Behavior on x {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.InOutCubic
                }
            }
            
            Behavior on y {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.InOutCubic
                }
            }
            
            Behavior on rotation {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.InOutCubic
                }
            }
            
            onStatusChanged: {
                console.log("[Wallpaper] img2 status:", status === Image.Ready ? "Ready" : status === Image.Loading ? "Loading" : "Error");
                if (status === Image.Ready && root.currentImage !== img2 && source == root.source) {
                    console.log("[Wallpaper] img2 ready, will apply transition type:", root.transitionType);
                    Qt.callLater(function() {
                        applyTransition(img2, img1);
                    });
                }
            }
        }
    }
    
    // Apply dramatic Linux-style transition effects
    function applyTransition(newImage, oldImage) {
        console.log("[Wallpaper] 🎬 STARTING TRANSITION TYPE", transitionType);
        var w = root.width;
        var h = root.height;
        
        // Reset old image to full visibility first
        oldImage.opacity = 1;
        oldImage.scale = 1;
        oldImage.rotation = 0;
        
        // Set initial state for new image based on transition type
        switch (transitionType) {
            case 0: // Smooth Fade - Classic crossfade
                console.log("[Wallpaper] ➡️ Applying FADE transition");
                newImage.x = 0;
                newImage.y = 0;
                newImage.scale = 1;
                newImage.rotation = 0;
                newImage.opacity = 0;
                break;
                
            case 1: // Slide Left - Push from right
                console.log("[Wallpaper] ➡️ Applying SLIDE LEFT transition");
                newImage.x = w * 1.2; // Start further off-screen
                newImage.y = 0;
                newImage.scale = 1;
                newImage.rotation = 0;
                newImage.opacity = 1;
                oldImage.x = -w * 1.2; // Slide out further
                break;
                
            case 2: // Slide Up - Push from bottom
                console.log("[Wallpaper] ⬆️ Applying SLIDE UP transition");
                newImage.x = 0;
                newImage.y = h * 1.2; // Start further off-screen
                newImage.scale = 1;
                newImage.rotation = 0;
                newImage.opacity = 1;
                oldImage.y = -h * 1.2; // Slide out further
                break;
                
            case 3: // Zoom In - Scale up fade
                console.log("[Wallpaper] 🔍 Applying ZOOM IN transition");
                newImage.x = 0;
                newImage.y = 0;
                newImage.scale = 1.6;
                newImage.rotation = 0;
                newImage.opacity = 0;
                oldImage.scale = 0.75;
                break;
                
            case 4: // Cube Effect - Compiz style
                console.log("[Wallpaper] 🎲 Applying CUBE transition");
                newImage.x = w * 1.1;
                newImage.y = 0;
                newImage.scale = 0.85;
                newImage.rotation = 0;
                newImage.opacity = 1;
                oldImage.x = -w * 0.4;
                oldImage.scale = 0.85;
                break;
                
            case 5: // Glide - Diagonal movement
                console.log("[Wallpaper] ✈️ Applying GLIDE transition");
                newImage.x = 0;
                newImage.y = -h * 0.3;
                newImage.scale = 1.15;
                newImage.rotation = 0;
                newImage.opacity = 0;
                oldImage.y = h * 0.3;
                oldImage.scale = 0.9;
                break;
                
            case 6: // Rotate & Scale - Dynamic spin
                console.log("[Wallpaper] 🔄 Applying ROTATE transition");
                newImage.x = 0;
                newImage.y = 0;
                newImage.scale = 0.5;
                newImage.rotation = -25;
                newImage.opacity = 0;
                oldImage.rotation = 15;
                oldImage.scale = 1.2;
                break;
                
            case 7: // Flip - Card flip effect (horizontal flip simulation)
                console.log("[Wallpaper] 🃏 Applying FLIP transition");
                newImage.x = 0;
                newImage.y = 0;
                newImage.scale = 0.05; // Very small to simulate flip
                newImage.rotation = 90; // Rotate to enhance flip effect
                newImage.opacity = 0;
                oldImage.scale = 0.05;
                oldImage.rotation = -90;
                break;
                
            case 8: // Slide Right - Reverse push
                console.log("[Wallpaper] ⬅️ Applying SLIDE RIGHT transition");
                newImage.x = -w * 1.2;
                newImage.y = 0;
                newImage.scale = 1;
                newImage.rotation = 0;
                newImage.opacity = 1;
                oldImage.x = w * 1.2;
                break;
                
            case 9: // Zoom & Slide - Combined effect
                console.log("[Wallpaper] 🎯 Applying ZOOM & SLIDE transition");
                newImage.x = w * 0.3;
                newImage.y = 0;
                newImage.scale = 0.7;
                newImage.rotation = 0;
                newImage.opacity = 0;
                oldImage.x = -w * 0.3;
                oldImage.scale = 1.3;
                break;
                
            case 10: // Diagonal Slide - Corner movement
                console.log("[Wallpaper] ↗️ Applying DIAGONAL transition");
                newImage.x = w * 0.5;
                newImage.y = h * 1.1;
                newImage.scale = 0.9;
                newImage.rotation = 0;
                newImage.opacity = 1;
                oldImage.x = -w * 0.5;
                oldImage.y = -h * 1.1;
                oldImage.scale = 0.9;
                break;
                
            case 11: // Expand - Center to full
                console.log("[Wallpaper] 📐 Applying EXPAND transition");
                newImage.x = 0;
                newImage.y = 0;
                newImage.scale = 0.4;
                newImage.rotation = 0;
                newImage.opacity = 0;
                oldImage.scale = 1.2;
                break;
                
            case 12: // Spin Out - Rotating exit
                console.log("[Wallpaper] 🌀 Applying SPIN transition");
                newImage.x = 0;
                newImage.y = 0;
                newImage.scale = 0.3;
                newImage.rotation = -45;
                newImage.opacity = 0;
                oldImage.rotation = 45;
                oldImage.scale = 1.5;
                break;
                
            case 13: // Slide Down - Top to bottom
                console.log("[Wallpaper] ⬇️ Applying SLIDE DOWN transition");
                newImage.x = 0;
                newImage.y = -h * 1.2;
                newImage.scale = 1;
                newImage.rotation = 0;
                newImage.opacity = 1;
                oldImage.y = h * 1.2;
                break;
                
            case 14: // Cinematic Zoom - Movie-style
                console.log("[Wallpaper] 🎬 Applying CINEMATIC transition");
                newImage.x = 0;
                newImage.y = 0;
                newImage.scale = 1.3;
                newImage.rotation = 0;
                newImage.opacity = 0;
                oldImage.scale = 0.8;
                oldImage.opacity = 0.5;
                break;
        }
        
        // Update z-order: new image on top
        img1Container.z = (newImage === img1) ? 2 : 1;
        img2Container.z = (newImage === img2) ? 2 : 1;
        
        // Switch current image reference
        root.currentImage = newImage;
        
        // Animate to final positions (happens automatically via Behaviors)
        console.log("[Wallpaper] 🎭 Animating to final state...");
        newImage.opacity = 1;
        newImage.scale = 1;
        newImage.x = 0;
        newImage.y = 0;
        newImage.rotation = 0;
        
        // Fade out old image
        oldImage.opacity = 0;
        
        // Reset old image after transition completes
        Qt.callLater(function() {
            setTimeout(function() {
                oldImage.scale = 1;
                oldImage.x = 0;
                oldImage.y = 0;
                oldImage.rotation = 0;
                console.log("[Wallpaper] ✅ Transition complete!");
            }, 1000);
        });
    }
    
    function setTimeout(callback, delay) {
        var timer = Qt.createQmlObject("import QtQuick; Timer {}", root);
        timer.interval = delay;
        timer.repeat = false;
        timer.triggered.connect(function() {
            callback();
            timer.destroy();
        });
        timer.start();
    }
}