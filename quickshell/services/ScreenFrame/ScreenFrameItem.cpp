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
    if (qFuzzyCompare(m_top, t) && qFuzzyCompare(m_bottom, t) &&
        qFuzzyCompare(m_left, t) && qFuzzyCompare(m_right, t)) return;
    m_top = m_bottom = m_left = m_right = t;
    emit thicknessChanged();
    update();
}

void ScreenFrameItem::setThicknessTop(qreal t) {
    if (qFuzzyCompare(m_top, t)) return;
    m_top = t;
    emit thicknessChanged();
    update();
}

void ScreenFrameItem::setThicknessBottom(qreal t) {
    if (qFuzzyCompare(m_bottom, t)) return;
    m_bottom = t;
    emit thicknessChanged();
    update();
}

void ScreenFrameItem::setThicknessLeft(qreal t) {
    if (qFuzzyCompare(m_left, t)) return;
    m_left = t;
    emit thicknessChanged();
    update();
}

void ScreenFrameItem::setThicknessRight(qreal t) {
    if (qFuzzyCompare(m_right, t)) return;
    m_right = t;
    emit thicknessChanged();
    update();
}

void ScreenFrameItem::setBorderSize(qreal s) {
    if (qFuzzyCompare(m_borderSize, s)) return;
    m_borderSize = s;
    emit borderSizeChanged();
    update();
}

void ScreenFrameItem::setBorderColor(const QColor& c) {
    if (m_borderColor == c) return;
    m_borderColor = c;
    emit borderColorChanged();
    update();
}

void ScreenFrameItem::setShadowSize(qreal s) {
    if (qFuzzyCompare(m_shadowSize, s)) return;
    m_shadowSize = s;
    emit shadowSizeChanged();
    update();
}

void ScreenFrameItem::setShadowOpacity(int o) {
    if (m_shadowOpacity == o) return;
    m_shadowOpacity = o;
    emit shadowOpacityChanged();
    update();
}

void ScreenFrameItem::paint(QPainter* painter) {
    const qreal w = width();
    const qreal h = height();
 
    const qreal minT   = qMin(qMin(m_top, m_bottom), qMin(m_left, m_right));
    const qreal innerR = qMax(0.0, m_radius - minT);
 
    QPainterPath outer;
    outer.addRect(0, 0, w, h);
 
    QPainterPath inner;
    inner.addRoundedRect(m_left, m_top, w - m_left - m_right, h - m_top - m_bottom, innerR, innerR);
 
    painter->setRenderHint(QPainter::Antialiasing, true);
    painter->fillPath(outer.subtracted(inner), m_color);
 
    const qreal borderR = qMax(0.0, innerR + m_borderSize);
    QPainterPath borderInner;
    borderInner.addRoundedRect(
        m_left - m_borderSize,
        m_top  - m_borderSize,
        w - m_left - m_right + 2 * m_borderSize,
        h - m_top  - m_bottom + 2 * m_borderSize,
        borderR, borderR
    );
    painter->fillPath(inner.subtracted(borderInner), m_borderColor);
 
    const qreal ss = m_shadowSize;
    if (ss > 0.0) {
        QColor shadowStart(0, 0, 0, m_shadowOpacity);
        QColor shadowEnd(0, 0, 0, 0);
 
        painter->setClipPath(inner);
 
        // Top
        { QLinearGradient g(0, m_top, 0, m_top + ss); g.setColorAt(0, shadowStart); g.setColorAt(1, shadowEnd);
        painter->fillRect(QRectF(m_left + innerR, m_top, w - m_left - m_right - 2*innerR, ss), g); }
        // Bottom
        { QLinearGradient g(0, h - m_bottom, 0, h - m_bottom - ss); g.setColorAt(0, shadowStart); g.setColorAt(1, shadowEnd);
        painter->fillRect(QRectF(m_left + innerR, h - m_bottom - ss, w - m_left - m_right - 2*innerR, ss), g); }
        // Left
        { QLinearGradient g(m_left, 0, m_left + ss, 0); g.setColorAt(0, shadowStart); g.setColorAt(1, shadowEnd);
        painter->fillRect(QRectF(m_left, m_top + innerR, ss, h - m_top - m_bottom - 2*innerR), g); }
        // Right
        { QLinearGradient g(w - m_right, 0, w - m_right - ss, 0); g.setColorAt(0, shadowStart); g.setColorAt(1, shadowEnd);
        painter->fillRect(QRectF(w - m_right - ss, m_top + innerR, ss, h - m_top - m_bottom - 2*innerR), g); }
 
        // Corners — gradient runs from opaque at the arc edge (innerR) to
        // transparent at (innerR + ss), matching the straight-edge shadows.
        auto corner = [&](QPointF c) {
            QRadialGradient g(c, innerR);
            g.setFocalPoint(c);

            if (innerR > 0.0) {
                g.setColorAt(1.0, shadowStart);
                qreal shadowStop = qMax(0.0, (innerR - ss) / innerR);
                g.setColorAt(shadowStop, shadowEnd);
                g.setColorAt(0.0, shadowEnd);
            }

            // Determine if we are on the left or right, top or bottom
            // so we can move the fillRect into the correct quadrant.
            qreal xOffset = (c.x() < w / 2) ? -innerR : 0;
            qreal yOffset = (c.y() < h / 2) ? -innerR : 0;

            painter->save();
            // This draws the 1/4th square that actually sits inside your window
            painter->fillRect(QRectF(c.x() + xOffset, c.y() + yOffset, innerR, innerR), g);
            painter->restore();
        };
        corner({m_left    + innerR, m_top       + innerR});
        corner({w-m_right - innerR, m_top       + innerR});
        corner({w-m_right - innerR, h-m_bottom  - innerR});
        corner({m_left    + innerR, h-m_bottom  - innerR});
 
        painter->setClipping(false);
    }
}
