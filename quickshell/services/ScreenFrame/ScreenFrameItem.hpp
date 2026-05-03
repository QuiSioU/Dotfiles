/* quickshell/services/ScreenFrame/ScreenFrameItem.hpp */


/* quickshell/services/ScreenFrame/ScreenFrameItem.hpp */

#pragma once

#include <QColor>
#include <QQuickPaintedItem>
#include <qqmlintegration.h>

class ScreenFrameItem : public QQuickPaintedItem {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QColor color     READ color     WRITE setColor     NOTIFY colorChanged)
    Q_PROPERTY(qreal  radius    READ radius    WRITE setRadius    NOTIFY radiusChanged)
    Q_PROPERTY(qreal  thickness READ thickness WRITE setThickness NOTIFY thicknessChanged)

public:
    explicit ScreenFrameItem(QQuickItem* parent = nullptr);

    QColor color()     const { return m_color; }
    qreal  radius()    const { return m_radius; }
    qreal  thickness() const { return m_thickness; }

    void setColor(const QColor& c);
    void setRadius(qreal r);
    void setThickness(qreal t);

    void paint(QPainter* painter) override;

signals:
    void colorChanged();
    void radiusChanged();
    void thicknessChanged();

private:
    QColor m_color     = QColor(30, 30, 46);
    qreal  m_radius    = 15.0;
    qreal  m_thickness = 10.0;
};
