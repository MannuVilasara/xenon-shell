import QtQuick

Item {
    readonly property color bg: "#1a1b26"
    readonly property color fg: "#a9b1d6"
    readonly property color muted: "#444b6a"
    readonly property color cyan: "#0db9d7"
    readonly property color purple: "#ad8ee6"
    readonly property color red: "#f7768e"
    readonly property color yellow: "#e0af68"
    readonly property color blue: "#7aa2f7"
    readonly property color green: "#9ece6a"
    
    // Additional Semantic Colors
    readonly property color surface: "#24283b" // Surface color (slightly lighter than bg)
    readonly property color border: "#414868"  // Border/Outline
    readonly property color subtext: "#565f89" // Subtext
    readonly property color orange: "#ff9e64"  // Orange
    readonly property color teal: "#73daca"    // Teal/Accent
    readonly property color accent: "#7aa2f7"  // Accent (Blue)

    // Derived properties for views
    readonly property color red_dim: Qt.rgba(red.r, red.g, red.b, 0.1)
}