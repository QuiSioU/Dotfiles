/* quickshell/services/ScreenFrame/ScreenFrameItem.hpp */


#pragma once

#include <QColor>
#include <QQuickPaintedItem>
#include <qqmlintegration.h>

class ScreenFrameItem : public QQuickPaintedItem {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QColor color           READ color           WRITE setColor           NOTIFY colorChanged)
    Q_PROPERTY(qreal  radius          READ radius          WRITE setRadius          NOTIFY radiusChanged)
    Q_PROPERTY(qreal  thickness       READ thickness       WRITE setThickness       NOTIFY thicknessChanged)
    Q_PROPERTY(qreal  thicknessTop    READ thicknessTop    WRITE setThicknessTop    NOTIFY thicknessChanged)
    Q_PROPERTY(qreal  thicknessBottom READ thicknessBottom WRITE setThicknessBottom NOTIFY thicknessChanged)
    Q_PROPERTY(qreal  thicknessLeft   READ thicknessLeft   WRITE setThicknessLeft   NOTIFY thicknessChanged)
    Q_PROPERTY(qreal  thicknessRight  READ thicknessRight  WRITE setThicknessRight  NOTIFY thicknessChanged)
    Q_PROPERTY(qreal  borderSize  READ borderSize  WRITE setBorderSize  NOTIFY borderSizeChanged)
    Q_PROPERTY(QColor borderColor READ borderColor WRITE setBorderColor NOTIFY borderColorChanged)
    Q_PROPERTY(qreal shadowSize    READ shadowSize    WRITE setShadowSize    NOTIFY shadowSizeChanged)
    Q_PROPERTY(int   shadowOpacity READ shadowOpacity WRITE setShadowOpacity NOTIFY shadowOpacityChanged)

public:
    explicit ScreenFrameItem(QQuickItem* parent = nullptr);

    QColor  color()              const { return m_color; }
    qreal   radius()             const { return m_radius; }
    qreal   thickness()          const { return m_top; }
    qreal   thicknessTop()       const { return m_top; }
    qreal   thicknessBottom()    const { return m_bottom; }
    qreal   thicknessLeft()      const { return m_left; }
    qreal   thicknessRight()     const { return m_right; }
    qreal   borderSize()         const { return m_borderSize; }
    QColor  borderColor()        const { return m_borderColor; }
    qreal   shadowSize()         const { return m_shadowSize; }
    int     shadowOpacity()      const { return m_shadowOpacity; }

    void setColor(const QColor& c);
    void setRadius(qreal r);
    void setThickness(qreal t);
    void setThicknessTop(qreal t);
    void setThicknessBottom(qreal t);
    void setThicknessLeft(qreal t);
    void setThicknessRight(qreal t);
    void setBorderSize(qreal s);
    void setBorderColor(const QColor& c);
    void setShadowSize(qreal s);
    void setShadowOpacity(int o);

    void paint(QPainter* painter) override;

signals:
    void colorChanged();
    void radiusChanged();
    void thicknessChanged();
    void borderSizeChanged();
    void borderColorChanged();
    void shadowSizeChanged();
    void shadowOpacityChanged();

private:
    QColor  m_color         = QColor(30, 30, 46);
    qreal   m_radius        = 15.0;
    qreal   m_top           = 10.0;
    qreal   m_bottom        = 10.0;
    qreal   m_left          = 10.0;
    qreal   m_right         = 10.0;
    qreal   m_borderSize    = 2.0;
    QColor  m_borderColor   = QColor(180, 190, 254);
    qreal   m_shadowSize    = 20.0;
    int     m_shadowOpacity = 80;    // 0-255
};
