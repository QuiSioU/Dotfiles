/* quickshell/widgets/base/drawer/Drawer.qml */


import Quickshell
import Quickshell.Hyprland
import QtQuick
import ElyseanShell.Blobs

PanelWindow {
    id: root

    // ── Enums ─────────────────────────────────────────────────────────────────
    enum Edge {
        Bottom,
        Top,
        Left,
        Right
    }

    // ── Public properties ─────────────────────────────────────────────────────
    property int   edge:          Drawer.Edge.Bottom
    property color blobColor:     "#ffffff"
    property real  blobSmoothing: 36
    property real  blobRadius:    18

    // ── Default children land in the content area ─────────────────────────────
    default property alias content: contentArea.data

    // ── Internal ──────────────────────────────────────────────────────────────
    readonly property real blobPad: blobSmoothing * 1.5
    readonly property bool _isVertical: edge === Drawer.Edge.Bottom || edge === Drawer.Edge.Top

    property bool _closing: false

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

    implicitWidth:  _contentW + blobPad * 2 + (!_isVertical ? blobPad : 0)
    implicitHeight: _contentH + blobPad * 2 + ( _isVertical ? blobPad : 0)

    color:         "transparent"
    focusable:     true
    visible:       false
    exclusiveZone: 0

    // ── Panel anchors ─────────────────────────────────────────────────────────
    anchors {
        bottom: edge === Drawer.Edge.Bottom || edge === Drawer.Edge.Left || edge === Drawer.Edge.Right
        top:    edge === Drawer.Edge.Top    || edge === Drawer.Edge.Left || edge === Drawer.Edge.Right
        left:   edge === Drawer.Edge.Left   || edge === Drawer.Edge.Top  || edge === Drawer.Edge.Bottom
        right:  edge === Drawer.Edge.Right  || edge === Drawer.Edge.Top  || edge === Drawer.Edge.Bottom
    }

    // ── Focus grab ────────────────────────────────────────────────────────────
    HyprlandFocusGrab {
        windows: [ root ]
        active:  root.visible
        onCleared: root.close()
    }

    // ── Open / close ──────────────────────────────────────────────────────────
    onVisibleChanged: {
        if (!visible) return
        _closing = false
        _playSlide(true)
    }

    function close() {
        if (_closing) return
        _closing = true
        _playSlide(false)
    }

    function _playSlide(opening) {
        switch (root.edge) {
            case Drawer.Edge.Bottom:
                slideAnim.property = "y"
                slideAnim.from     = opening ? root.implicitHeight : blobPad * 2
                slideAnim.to       = opening ? blobPad * 2 : root.implicitHeight
                break
            case Drawer.Edge.Top:
                slideAnim.property = "y"
                slideAnim.from     = opening ? -root.implicitHeight : -blobPad * 2 + 50
                slideAnim.to       = opening ? -blobPad * 2 + 50 : -root.implicitHeight
                break
            case Drawer.Edge.Left:
                slideAnim.property = "x"
                slideAnim.from     = opening ? -root.implicitWidth : 0
                slideAnim.to       = opening ? 0 : -root.implicitWidth
                break
            case Drawer.Edge.Right:
                slideAnim.property = "x"
                slideAnim.from     = opening ? root.implicitWidth : 0
                slideAnim.to       = opening ? 0 : root.implicitWidth
                break
        }
        slideAnim.start()
    }

    // ── Blob group ────────────────────────────────────────────────────────────
    BlobGroup {
        id: blobGroup
        smoothing: root.blobSmoothing
        color:     root.blobColor
    }

    // ── Screen-edge anchor — fixed, never slides ──────────────────────────────
    BlobInvertedRect {
        id: screenEdge
        group:  blobGroup
        radius: 0

        x: _isVertical  ? (root.width - root.implicitWidth) / 2
                        : edge === Drawer.Edge.Right ? blobPad + _contentW
                        : 0
        y: edge === Drawer.Edge.Bottom  ? root.implicitHeight + 3
                                        : edge === Drawer.Edge.Top ? -blobPad * 2
                                        : 0

        width:  _isVertical ? root.implicitWidth : blobPad * 2
        height: _isVertical ? blobPad * 2        : root.implicitHeight

        borderTop:    edge === Drawer.Edge.Bottom ? blobPad : 0
        borderBottom: edge === Drawer.Edge.Top    ? blobPad : 0
        borderLeft:   edge === Drawer.Edge.Right  ? blobPad : 0
        borderRight:  edge === Drawer.Edge.Left   ? blobPad : 0
    }

    // ── BlobRects — one per content child, rendered BELOW content ─────────────
    // At window root so scene coords match shader expectations.
    // Track slideContainer so they follow the slide animation.
    Repeater {
        model: contentArea.children.length

        delegate: BlobRect {
            required property int index
            readonly property Item _child: contentArea.children[index]

            group:       blobGroup
            radius:      root.blobRadius
            stiffness:   300
            damping:     50
            deformScale: 0

            x:       slideContainer.x + contentArea.x + _child.x
            y:       slideContainer.y + contentArea.y + _child.y
            width:   _child.width
            height:  _child.height
            visible: _child.visible
        }
    }

    // ── Sliding container — declared AFTER Repeater so it renders on top ──────
    Item {
        id: slideContainer
        width:  root.implicitWidth
        height: root.implicitHeight

        clip: true
        anchors.horizontalCenter: _isVertical ? parent.horizontalCenter : undefined
        anchors.verticalCenter:   _isVertical ? undefined               : parent.verticalCenter

        NumberAnimation {
            id: slideAnim
            target:      slideContainer
            duration:    500
            easing.type: Easing.OutExpo
            onStopped: {
                if (root._closing) {
                    root._closing = false
                    root.visible  = false
                }
            }
        }

        Item {
            id: contentArea
            x:      root.blobPad
            y:      root.blobPad
            width:  root._contentW
            height: root._contentH
        }
    }
}
