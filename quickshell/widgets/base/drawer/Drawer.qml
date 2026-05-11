/* quickshell/widgets/base/drawer/Drawer.qml */


import Quickshell
import Quickshell.Hyprland
import QtQuick
import ElyseanShell.Blobs

PanelWindow {
    id: drawer_panwin

    // ── Enums ─────────────────────────────────────────────────────────────────
    enum Edge {
        Bottom,
        Top,
        Left,
        Right
    }

    // ── Public properties ─────────────────────────────────────────────────────
    property int   edge:          Drawer.Edge.Bottom
    property color blobColor:     "#4488ff"
    property real  blobSmoothing: 36
    property real  blobRadius:    18

    // ── Default children land directly in the slide container ─────────────────
    default property alias content: contentArea.data

    // ── Internal ──────────────────────────────────────────────────────────────
    readonly property real blobPad: blobSmoothing * 1.5
    readonly property bool _isVertical: edge === Drawer.Edge.Bottom || edge === Drawer.Edge.Top

    // Bounding box of all direct children
    readonly property real _contentW: {
        let s = 0
        for (let i = 0; i < contentArea.children.length; i++) {
            const c = contentArea.children[i]
            if (c.visible) s = Math.max(s, c.width)
        }
        return s
    }
    readonly property real _contentH: {
        let s = 0
        for (let i = 0; i < contentArea.children.length; i++) {
            const c = contentArea.children[i]
            if (c.visible) s = Math.max(s, c.height)
        }
        return s
    }

    // PanelWindow size: content + padding on both sides + edge strip on one side
    implicitWidth:  _contentW + blobPad * 2 + (!_isVertical ? blobPad : 0)
    implicitHeight: _contentH + blobPad * 2 + ( _isVertical ? blobPad : 0)

    color:     "transparent"
    focusable: true
    visible:   false

    // ── Panel anchors — full-length along the docked edge ─────────────────────
    anchors {
        bottom: edge === Drawer.Edge.Bottom || edge === Drawer.Edge.Left || edge === Drawer.Edge.Right
        top:    edge === Drawer.Edge.Top    || edge === Drawer.Edge.Left || edge === Drawer.Edge.Right
        left:   edge === Drawer.Edge.Left   || edge === Drawer.Edge.Top  || edge === Drawer.Edge.Bottom
        right:  edge === Drawer.Edge.Right  || edge === Drawer.Edge.Top  || edge === Drawer.Edge.Bottom
    }

    // ── Focus grab — dismiss on click-outside ─────────────────────────────────
    HyprlandFocusGrab {
        windows: [ drawer_panwin ]
        active:  drawer_panwin.visible
        onCleared: drawer_panwin.visible = false
    }

    // ── Slide animation ───────────────────────────────────────────────────────
    onVisibleChanged: {
        if (!visible) return
        switch (drawer_panwin.edge) {
            case Drawer.Edge.Bottom:
                slideAnim.property = "y"
                slideAnim.from     = drawer_panwin.implicitHeight
                slideAnim.to       = 0
                break
            case Drawer.Edge.Top:
                slideAnim.property = "y"
                slideAnim.from     = -drawer_panwin.implicitHeight
                slideAnim.to       = 0
                break
            case Drawer.Edge.Left:
                slideAnim.property = "x"
                slideAnim.from     = -drawer_panwin.implicitWidth
                slideAnim.to       = 0
                break
            case Drawer.Edge.Right:
                slideAnim.property = "x"
                slideAnim.from     = drawer_panwin.implicitWidth
                slideAnim.to       = 0
                break
        }
        slideAnim.start()
    }

    // ── Blob group ────────────────────────────────────────────────────────────
    BlobGroup {
        id: blobGroup
        smoothing: drawer_panwin.blobSmoothing
        color:     drawer_panwin.blobColor
    }

    // ── Screen-edge anchor — the wall blobs merge into ────────────────────────
    BlobInvertedRect {
        id: screenEdge
        group:  blobGroup
        radius: 0

        x: edge === Drawer.Edge.Right  ? blobPad + _contentW : 0
        y: edge === Drawer.Edge.Bottom ? blobPad + _contentH : 0

        width:  _isVertical ? drawer_panwin.implicitWidth : blobPad * 2
        height: _isVertical ? blobPad * 2        : drawer_panwin.implicitHeight

        borderTop:    edge === Drawer.Edge.Bottom ? blobPad : 0
        borderBottom: edge === Drawer.Edge.Top    ? blobPad : 0
        borderLeft:   edge === Drawer.Edge.Right  ? blobPad : 0
        borderRight:  edge === Drawer.Edge.Left   ? blobPad : 0
    }

    // ── Sliding container ─────────────────────────────────────────────────────
    Item {
        id: slideContainer
        width:  drawer_panwin.implicitWidth
        height: drawer_panwin.implicitHeight

        anchors.horizontalCenter: _isVertical ? parent.horizontalCenter : undefined
        anchors.verticalCenter:   _isVertical ? undefined               : parent.verticalCenter

        NumberAnimation {
            id: slideAnim
            target:   slideContainer
            duration: 420
            easing.type: Easing.OutExpo
        }

        // ── One BlobRect per direct child ─────────────────────────────────────
        Repeater {
            model: contentArea.children.length

            delegate: BlobRect {
                required property int index
                readonly property Item _child: contentArea.children[index]

                group:       blobGroup
                radius:      drawer_panwin.blobRadius
                stiffness:   180
                damping:     14
                deformScale: 0.0004

                x:       contentArea.x + _child.x
                y:       contentArea.y + _child.y
                width:   _child.width
                height:  _child.height
                visible: _child.visible
            }
        }

        // ── Content area — default children land here ─────────────────────────
        Item {
            id: contentArea
            x:      drawer_panwin.blobPad
            y:      drawer_panwin.blobPad
            width:  drawer_panwin._contentW
            height: drawer_panwin._contentH
        }
    }
}
