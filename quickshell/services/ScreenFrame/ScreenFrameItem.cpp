/* quickshell/services/ScreenFrame/ScreenFrameItem.cpp */


/* quickshell/services/ScreenFrame/ScreenFrameItem.cpp */

#include "ScreenFrameItem.hpp"

#include <QPainter>
#include <QPainterPath>

ScreenFrameItem::ScreenFrameItem(QQuickItem* parent)
    : QQuickPaintedItem(parent)
{
    setRenderTarget(QQuickPaintedItem::FramebufferObject);
    setAntialiasing(true);
}

void ScreenFrameItem::setColor(const QColor& c) {
    if (m_color == c) return;
    m_color = c;
    emit colorChanged();
    update();
}

void ScreenFrameItem::setRadius(qreal r) {
    if (qFuzzyCompare(m_radius, r)) return;
    m_radius = r;
    emit radiusChanged();
    update();
}

void ScreenFrameItem::setThickness(qreal t) {
    if (qFuzzyCompare(m_thickness, t)) return;
    m_thickness = t;
    emit thicknessChanged();
    update();
}

void ScreenFrameItem::paint(QPainter* painter) {
    const qreal w = width();
    const qreal h = height();
    const qreal t = m_thickness;

    // Outer path: the full screen rectangle (sharp corners)
    QPainterPath outer;
    outer.addRect(0, 0, w, h);

    // Inner path: the hole with rounded corners
    // Inner radius = outer radius minus thickness, clamped to 0
    const qreal innerR = qMax(0.0, m_radius - t);
    QPainterPath inner;
    inner.addRoundedRect(t, t, w - 2*t, h - 2*t, innerR, innerR);

    // Frame = outer minus inner
    QPainterPath frame = outer.subtracted(inner);

    painter->setRenderHint(QPainter::Antialiasing, true);
    painter->fillPath(frame, m_color);
}
