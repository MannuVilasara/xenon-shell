import Qt.labs.folderlistmodel
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services
pragma Singleton

Singleton {
    id: root

    property string defaultDirectory: Config.wallpaperDirectory
    property var currentWallpapers: ({
    })
    property var wallpaperLists: ({
    })
    property int scanningCount: 0
    readonly property bool scanning: (scanningCount > 0)
    property bool isInitialized: false
    property string wallpaperCacheFile: Quickshell.env("HOME") + "/.cache/mannu/wallpapers.json"
    property string defaultWallpaper: ""

    signal wallpaperChanged(string screenName, string path)
    signal wallpaperListChanged(string screenName, int count)

    function init() {
        console.log("[WallpaperService] Starting service");
        dirCreator.running = true;
        Qt.callLater(loadFromCache);
        Qt.callLater(refreshWallpapersList);
    }

    function loadFromCache() {
        wallpaperCacheView.path = wallpaperCacheFile;
    }

    function getWallpaper(screenName) {
        return currentWallpapers[screenName] || root.defaultWallpaper;
    }

    function changeWallpaper(path, screenName) {
        if (screenName !== undefined) {
            _setWallpaper(screenName, path);
        } else {
            for (var i = 0; i < Quickshell.screens.length; i++) {
                _setWallpaper(Quickshell.screens[i].name, path);
            }
        }
    }

    function _setWallpaper(screenName, path) {
        if (path === "" || path === undefined)
            return ;

        if (screenName === undefined) {
            console.log("[WallpaperService] No screen specified");
            return ;
        }
        var oldPath = currentWallpapers[screenName] || "";
        currentWallpapers[screenName] = path;
        saveTimer.restart();
        if (oldPath !== path)
            root.wallpaperChanged(screenName, path);

        console.log("[WallpaperService] Set wallpaper for", screenName, "to", path);
        generateColors(path);
    }

    function generateColors(path) {
        if (!path)
            return ;

        var cachePath = Quickshell.env("HOME") + "/.cache/mannu/colors.json";
        var logPath = Quickshell.env("HOME") + "/.cache/mannu/matugen.log";
        var cmd = "/usr/bin/matugen image '" + path + "' -j hex > '" + cachePath + "' 2> '" + logPath + "'";
        console.log("[WallpaperService] Generating colors command:", cmd);
        matugenProcess.command = ["sh", "-c", cmd];
        matugenProcess.running = true;
    }

    function getWallpapersList(screenName) {
        if (screenName != undefined && wallpaperLists[screenName] != undefined)
            return wallpaperLists[screenName];

        return [];
    }

    function refreshWallpapersList() {
        console.log("[WallpaperService] Refreshing wallpapers list");
        scanningCount = 0;
        for (var i = 0; i < wallpaperScanners.count; i++) {
            var scanner = wallpaperScanners.objectAt(i);
            if (scanner)
                (function(s) {
                    var directory = root.defaultDirectory;
                    s.currentDirectory = "/tmp";
                    Qt.callLater(function() {
                        s.currentDirectory = directory;
                    });
                })(scanner);

        }
    }

    Component.onCompleted: {
        init();
    }

    Process {
        id: dirCreator

        command: ["mkdir", "-p", Quickshell.env("HOME") + "/.cache/mannu"]
        running: false
    }

    Process {
        id: matugenProcess

        running: false
        onExited: (code, status) => {
            if (code === 0)
                console.log("[WallpaperService] Matugen finished successfully");
            else
                console.error("[WallpaperService] Matugen failed with code:", code);
        }
    }

    FileView {
        id: wallpaperCacheView

        path: ""
        onLoaded: {
            root.currentWallpapers = wallpaperCacheAdapter.wallpapers || {
            };
            root.defaultWallpaper = wallpaperCacheAdapter.defaultWallpaper || "";
            console.log("[WallpaperService] Loaded wallpapers from cache:", Object.keys(root.currentWallpapers).length, "screens");
            var screens = Object.keys(root.currentWallpapers);
            if (screens.length > 0) {
                var firstWallpaper = root.currentWallpapers[screens[0]];
                console.log("[WallpaperService] Generating initial colors from:", firstWallpaper);
                generateColors(firstWallpaper);
            }
            root.isInitialized = true;
        }
        onLoadFailed: (error) => {
            console.log("[WallpaperService] Cache file doesn't exist or failed to load, starting with empty wallpapers");
            root.currentWallpapers = {
            };
            root.isInitialized = true;
        }

        adapter: JsonAdapter {
            id: wallpaperCacheAdapter

            property var wallpapers: ({
            })
            property string defaultWallpaper: ""
        }

    }

    Timer {
        id: saveTimer

        interval: 500
        repeat: false
        onTriggered: {
            wallpaperCacheAdapter.wallpapers = root.currentWallpapers;
            wallpaperCacheAdapter.defaultWallpaper = root.defaultWallpaper;
            wallpaperCacheView.writeAdapter();
            console.log("[WallpaperService] Saved wallpapers to cache file");
        }
    }

    Instantiator {
        id: wallpaperScanners

        model: Quickshell.screens

        delegate: FolderListModel {
            property string screenName: modelData.name
            property string currentDirectory: root.defaultDirectory

            folder: "file://" + currentDirectory
            nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.gif", "*.webp", "*.bmp", "*.svg"]
            showDirs: false
            sortField: FolderListModel.Name
            onCurrentDirectoryChanged: {
                folder = "file://" + currentDirectory;
            }
            onStatusChanged: {
                if (status === FolderListModel.Null) {
                    root.wallpaperLists[screenName] = [];
                    root.wallpaperListChanged(screenName, 0);
                } else if (status === FolderListModel.Loading) {
                    root.wallpaperLists[screenName] = [];
                    scanningCount++;
                } else if (status === FolderListModel.Ready) {
                    var files = [];
                    for (var i = 0; i < count; i++) {
                        var directory = root.defaultDirectory;
                        var filepath = directory + "/" + get(i, "fileName");
                        files.push(filepath);
                    }
                    root.wallpaperLists[screenName] = files;
                    scanningCount--;
                    console.log("[WallpaperService] List refreshed for", screenName, "count:", files.length);
                    root.wallpaperListChanged(screenName, files.length);
                }
            }
        }

    }

}
