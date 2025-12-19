pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    property alias activePlayer: instance.activePlayer
    property bool isPlaying: activePlayer ? activePlayer.playbackStatus === 0 : false
    
    // Track Info
    property string title: activePlayer ? activePlayer.trackTitle : "No Media"
    property string artist: activePlayer ? activePlayer.trackArtist : ""
    property string album: activePlayer ? activePlayer.trackAlbum : ""
    property string artUrl: activePlayer ? activePlayer.trackArtUrl : ""
    
    // Internal management to auto-select player
    QtObject {
        id: instance
        property var players: Mpris.players.values
        property var activePlayer: players.length > 0 ? players[0] : null
    }

    // Listen for new players
    // Connections {
    //    target: Mpris
    //    function onPlayersChanged() { ... }
    // }
    
    // Use Binding to auto-update. Mpris.players.values should trigger update.
    Binding {
        target: instance
        property: "activePlayer"
        value: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
        when: !instance.activePlayer || !Mpris.players.values.includes(instance.activePlayer)
    }
    
    // Actually simpler: just bind it directly.
    // property var activePlayer: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    // But we want manual override capability if needed (though not implemented yet).
    // Let's stick to simple binding for now.

    
    function playPause() {
        if (activePlayer && activePlayer.canTogglePlaying) activePlayer.togglePlaying()
    }
    
    function next() {
        if (activePlayer && activePlayer.canGoNext) activePlayer.next()
    }
    
    function previous() {
        if (activePlayer && activePlayer.canGoPrevious) activePlayer.previous()
    }
}
