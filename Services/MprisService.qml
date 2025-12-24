import QtQuick
import Quickshell
import Quickshell.Services.Mpris
pragma Singleton

Singleton {
    id: root

    property alias activePlayer: instance.activePlayer
    property bool isPlaying: activePlayer ? activePlayer.playbackState === MprisPlaybackState.Playing : false
    property string title: activePlayer ? activePlayer.trackTitle : "No Media"
    property string artist: activePlayer ? activePlayer.trackArtist : ""
    property string album: activePlayer ? activePlayer.trackAlbum : ""
    property string artUrl: activePlayer ? activePlayer.trackArtUrl : ""

    function updateActivePlayer() {
        const players = Mpris.players.values;
        const playing = players.find((p) => {
            return p.playbackState === MprisPlaybackState.Playing;
        });
        if (playing) {
            instance.activePlayer = playing;
        } else if (players.length > 0) {
            if (!instance.activePlayer || !players.includes(instance.activePlayer))
                instance.activePlayer = players[0];

        } else {
            instance.activePlayer = null;
        }
    }

    function playPause() {
        if (activePlayer && activePlayer.canTogglePlaying)
            activePlayer.togglePlaying();

    }

    function next() {
        if (activePlayer && activePlayer.canGoNext)
            activePlayer.next();

    }

    function previous() {
        if (activePlayer && activePlayer.canGoPrevious)
            activePlayer.previous();

    }

    Component.onCompleted: updateActivePlayer()

    QtObject {
        id: instance

        property var players: Mpris.players.values
        property var activePlayer: null
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: updateActivePlayer()
    }

    Connections {
        function onValuesChanged() {
            updateActivePlayer();
        }

        target: Mpris.players
    }

}
