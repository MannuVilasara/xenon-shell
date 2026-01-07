import QtQuick
import qs.Core
import qs.Services
import qs.Services.Compositor

Item {
    id: root

    property var config: Config
    property alias colors: colorsService
    property alias cpu: cpuService
    property alias os: osService
    property alias mem: memService
    property alias disk: diskService
    property alias time: timeService
    property alias timezone: timezoneService
    property alias volume: volumeService
    property alias activeWindow: compositorService
    property alias layout: compositorService
    property alias appState: appStateService
    property var network: NetworkService
    property var bluetooth: BluetoothService

    Colors {
        id: colorsService
    }

    CpuService {
        id: cpuService
    }

    OsService {
        id: osService
    }

    MemService {
        id: memService
    }

    DiskService {
        id: diskService
    }

    TimeService {
        id: timeService
    }

    TimeZone {
        id: timezoneService
    }

    Compositor {
        id: compositorService
    }

    GlobalState {
        id: appStateService
    }

    VolumeService {
        id: volumeService
    }

}
