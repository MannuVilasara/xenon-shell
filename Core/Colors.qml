import QtQuick
import Quickshell
import Quickshell.Io

Item {
    property color bg: loadedColors ? (loadedColors.surface.dark || "#1a1b26") : "#1a1b26"
    property color fg: loadedColors ? (loadedColors.on_surface.dark || "#a9b1d6") : "#a9b1d6"
    property color muted: loadedColors ? (loadedColors.surface_variant.dark || "#444b6a") : "#444b6a"
    property color cyan: "#0db9d7"
    property color purple: "#ad8ee6"
    property color red: loadedColors ? (loadedColors.error.dark || "#f7768e") : "#f7768e"
    property color yellow: "#e0af68"
    property color blue: loadedColors ? (loadedColors.primary.dark || "#7aa2f7") : "#7aa2f7"
    property color green: "#9ece6a"
    property color surface: loadedColors ? (loadedColors.surface_container.dark || "#24283b") : "#24283b"
    property color border: loadedColors ? (loadedColors.outline.dark || "#414868") : "#414868"
    property color subtext: loadedColors ? (loadedColors.on_surface_variant.dark || "#565f89") : "#565f89"
    property color orange: "#ff9e64"
    property color teal: loadedColors ? (loadedColors.secondary.dark || "#73daca") : "#73daca"
    property color accent: loadedColors ? (loadedColors.primary.dark || "#7aa2f7") : "#7aa2f7"
    property color text: fg
    property color tile: loadedColors ? (loadedColors.surface_variant.dark || "#444b6a") : "#444b6a"
    property color tileActive: loadedColors ? (loadedColors.secondary_container.dark || "#3b4261") : "#3b4261"
    property color accentActive: accent
    property color urgent: red
    property color secondary: subtext
    property color iconMuted: subtext
    property color red_dim: Qt.rgba(red.r, red.g, red.b, 0.1)

    // Widget Defaults
    property int toggleHeight: 64
    property int toggleIconSize: 24
    property int sliderHeight: 64
    property int sliderIconSize: 20
    property color sliderTrack: surface
    property color sliderFill: accent
    property color sliderThumb: fg
    property var loadedColors: null

    function refreshColors() {
        try {
            var content = (typeof colorsFile.text === 'function') ? colorsFile.text() : colorsFile.text;
            if (!content || content.length === 0) {
                Logger.d("Colors", "Content is empty or null");
                return ;
            }
            var json = JSON.parse(content);
            Logger.d("Colors", "Successfully parsed. Keys:", Object.keys(json));
            if (json.colors) {
                loadedColors = json.colors;
            } else {
                Logger.i("Colors", "'colors' key missing, using root json object");
                loadedColors = json;
            }
        } catch (e) {
            Logger.w("Colors", "Failed to parse colors.json:", e);
        }
    }

    Component.onCompleted: {
        Logger.i("Colors", "Initialized. Path:", colorsFile.path);
        refreshColors();
    }

    FileView {
        id: colorsFile

        path: Quickshell.env("HOME") + "/.cache/mannu/colors.json"
        watchChanges: true
        onFileChanged: {
            Logger.d("Colors", "File changed, reloading...");
            colorsFile.reload();
        }
        onLoaded: {
            Logger.d("Colors", "File loaded, refreshing colors...");
            refreshColors();
        }
        onLoadFailed: {
            Logger.w("Colors", "File load failed.");
        }
    }

    Timer {
        interval: 1000
        running: loadedColors === null
        repeat: true
        onTriggered: {
            Logger.i("Colors", "Retrying file load...");
            colorsFile.reload();
            refreshColors();
        }
    }

    Behavior on bg {
        ColorAnimation {
            duration: 200
        }

    }

    Behavior on fg {
        ColorAnimation {
            duration: 200
        }

    }

    Behavior on muted {
        ColorAnimation {
            duration: 200
        }

    }

    Behavior on red {
        ColorAnimation {
            duration: 200
        }

    }

    Behavior on blue {
        ColorAnimation {
            duration: 200
        }

    }

    Behavior on surface {
        ColorAnimation {
            duration: 200
        }

    }

    Behavior on border {
        ColorAnimation {
            duration: 200
        }

    }

    Behavior on subtext {
        ColorAnimation {
            duration: 200
        }

    }

    Behavior on teal {
        ColorAnimation {
            duration: 200
        }

    }

    Behavior on accent {
        ColorAnimation {
            duration: 200
        }

    }

    Behavior on tile {
        ColorAnimation {
            duration: 200
        }

    }

    Behavior on tileActive {
        ColorAnimation {
            duration: 200
        }

    }

}
