// widgets/Launcher/Base/Entry.qml

import QtQuick

QtObject {
    property string name: ""
    property string icon: ""
    property string comment: ""
    property var action: () => {}
}
