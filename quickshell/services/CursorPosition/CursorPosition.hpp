/* quickshell/services/CursorPosition.hpp */


#ifndef CURSOR_POSITION_SERVICE_H
#define CURSOR_POSITION_SERVICE_H

#include <QObject>
#include <QPointF>
#include <QProcess>
#include <qqmlintegration.h>

class CursorPosition : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(qreal x READ x NOTIFY positionChanged)
    Q_PROPERTY(qreal y READ y NOTIFY positionChanged)

public:
    explicit CursorPosition(QObject* parent = nullptr);

    qreal x() const;
    qreal y() const;

    Q_INVOKABLE void update();

signals:
    void positionChanged();
    void ready();

private slots:
    void onProcessFinished(int exitCode);

private:
    QPointF m_pos;
    QProcess* m_process;
};

#endif /* CURSOR_POSITION_SERVICE_H */
