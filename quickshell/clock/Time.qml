pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root
    readonly property string time: Qt.formatDateTime(clock.date, "dddd MM/dd/yyyy\nhh:mm t")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
