import Quickshell
import QtQuick
import "Base"

Launcher {
    id: root

    Component.onCompleted: rebuildEntries()

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() { root.rebuildEntries() }
    }

    function rebuildEntries() {
        entries = DesktopEntries.applications.values
            .filter(app => !app.noDisplay)
            .map(app => ({
                name: app.name,
                icon: app.icon ?? "",
                comment: app.comment ?? "",
                action: (function(a) { return () => a.execute() })(app)
            }))
    }
}