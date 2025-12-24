import QtQuick
import Quickshell
import Quickshell.Io

Item {
    readonly property color bg: loadedColors ? (loadedColors.surface.dark || "#1a1b26") : "#1a1b26"
    readonly property color fg: loadedColors ? (loadedColors.on_surface.dark || "#a9b1d6") : "#a9b1d6"
    readonly property color muted: loadedColors ? (loadedColors.surface_variant.dark || "#444b6a") : "#444b6a"
    readonly property color cyan: "#0db9d7" // Keep hardcoded or map to similar
    readonly property color purple: "#ad8ee6"
    readonly property color red: loadedColors ? (loadedColors.error.dark || "#f7768e") : "#f7768e"
    readonly property color yellow: "#e0af68"
    readonly property color blue: loadedColors ? (loadedColors.primary.dark || "#7aa2f7") : "#7aa2f7"
    readonly property color green: "#9ece6a"
    readonly property color surface: loadedColors ? (loadedColors.surface_container.dark || "#24283b") : "#24283b"
    readonly property color border: loadedColors ? (loadedColors.outline.dark || "#414868") : "#414868"
    readonly property color subtext: loadedColors ? (loadedColors.on_surface_variant.dark || "#565f89") : "#565f89"
    readonly property color orange: "#ff9e64"
    readonly property color teal: loadedColors ? (loadedColors.secondary.dark || "#73daca") : "#73daca"
    readonly property color accent: loadedColors ? (loadedColors.primary.dark || "#7aa2f7") : "#7aa2f7"
    readonly property color text: fg
    readonly property color tile: loadedColors ? (loadedColors.surface_variant.dark || "#444b6a") : "#444b6a"
    readonly property color tileActive: loadedColors ? (loadedColors.secondary_container.dark || "#3b4261") : "#3b4261"
    readonly property color accentActive: accent
    readonly property color urgent: red
    readonly property color secondary: subtext // Overriding the 'secondary' map if needed, or just alias to what Views expect
    readonly property color iconMuted: subtext
    readonly property color red_dim: Qt.rgba(red.r, red.g, red.b, 0.1)
    property var loadedColors: null

    function refreshColors() {
        try {
            var content = (typeof colorsFile.text === 'function') ? colorsFile.text() : colorsFile.text;
            if (!content || content.length === 0) {
                console.log("[Colors] Content is empty or null");
                return ;
            }
            var json = JSON.parse(content);
            console.log("[Colors] Successfully parsed. Keys:", Object.keys(json));
            if (json.colors) {
                loadedColors = json.colors;
            } else {
                console.log("[Colors] 'colors' key missing, using root json object");
                loadedColors = json;
            }
        } catch (e) {
            console.warn("[Colors] Failed to parse colors.json:", e);
        }
    }

    Component.onCompleted: {
        console.log("[Colors] Initialized. Path:", colorsFile.path);
        refreshColors();
    }

    FileView {
        id: colorsFile

        path: Quickshell.env("HOME") + "/.cache/mannu/colors.json"
        watchChanges: true
        onFileChanged: {
            console.log("[Colors] File changed, reloading...");
            colorsFile.reload();
        }
        onLoaded: {
            console.log("[Colors] File loaded, refreshing colors...");
            refreshColors();
        }
        onLoadFailed: {
            console.warn("[Colors] File load failed.");
        }
    }

    Timer {
        interval: 1000
        running: loadedColors === null
        repeat: true
        onTriggered: {
            console.log("[Colors] Retrying file load...");
            colorsFile.reload();
            refreshColors();
        }
    }

}
