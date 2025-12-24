import Quickshell
import qs.Modules.Background
import qs.Modules.Bar
import qs.Modules.Lock
import qs.Modules.Overlays
import qs.Services

ShellRoot {
    id: root

    Context {
        id: ctx
    }

    Background {
    }

    Lock {
        context: ctx
    }

    Overlays {
        context: ctx
    }

    BarWindow {
        context: ctx
    }

}
