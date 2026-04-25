/* quickshell/services/Notification/NotificationService.qml */


pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

    property list<var> notifications: []
    property int _seq: 0

    // ── JSON log ───────────────────────────────────────────────────────────

    FileView {
        id: logFile
        path: Quickshell.env("HOME") + "/.local/share/quickshell/notifications.json"
    }

    function _appendLog(appName, summary, body) {
        const entry = {
            time:    new Date().toISOString(),
            app:     appName || "unknown",
            summary: summary || "",
            body:    body    || ""
        };

        let arr = [];
        
        try { arr = JSON.parse(logFile.text()); }
        catch(e) {}

        arr.push(entry);
        logFile.setText(JSON.stringify(arr, null, 2));
    }

    // ── Notification daemon ────────────────────────────────────────────────

    NotificationServer {
        id: server
        actionsSupported:    false
        bodySupported:       true
        bodyMarkupSupported: false
        imageSupported:      false
        keepOnReload:        false

        onNotification: function(notif) {
            if (!notif.appName && !notif.summary && !notif.body) return;

            notif.tracked = true;

            // Replace if same protocol id (app is updating an existing notif)
            const idStr = String(notif.id || "");
            if (idStr !== "") {
                const existing = root.notifications.find(n => n._pid === idStr);
                if (existing) {
                    existing._stopTimer();
                    root.notifications = root.notifications.filter(n => n !== existing);
                    existing.destroy();
                }
            }

            const entry = _entryComp.createObject(root, {
                seqId:   root._seq++,
                _pid:    idStr,
                appName: notif.appName || "",
                summary: notif.summary || "",
                body:    notif.body    || "",
                _notif:  notif
            });

            root.notifications = [entry, ...root.notifications];
            root._appendLog(notif.appName, notif.summary, notif.body);
        }
    }

    // ── Entry ──────────────────────────────────────────────────────────────

    Component {
        id: _entryComp

        QtObject {
            property int    seqId:   0
            property string _pid:    ""
            property string appName: ""
            property string summary: ""
            property string body:    ""
            property var    _notif:  null

            property var _timer: Timer {
                interval: 4000
                running:  true
                repeat:   false
                onTriggered: parent.dismiss()
            }

            function _stopTimer() { _timer.stop(); }

            function dismiss() {
                _timer.stop();
                root.notifications = root.notifications.filter(n => n !== this);
                if (_notif) try { _notif.dismiss(); } catch(e) {}
                destroy();
            }
        }
    }
}
