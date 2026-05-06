/* quickshell/services/CursorPosition/CursorPositionService.cpp */


#include "CursorPositionService.hpp"
#include <QByteArray>

CursorPosition::CursorPosition(QObject* parent)
    : QObject(parent), m_process(new QProcess(this)) {

    connect(m_process, &QProcess::finished, this, &CursorPosition::onProcessFinished);
}

qreal CursorPosition::x() const { return m_pos.x(); }
qreal CursorPosition::y() const { return m_pos.y(); }

void CursorPosition::update() {
    if (m_process->state() == QProcess::NotRunning) {
        m_process->start("hyprctl", QStringList() << "cursorpos");
    }
}

void CursorPosition::onProcessFinished(int exitCode) {
    if (exitCode != 0) return;
    // output is "x, y"
    const QString out = QString::fromUtf8(m_process->readAllStandardOutput()).trimmed();
    const QStringList parts = out.split(", ");
    if (parts.size() == 2) {
        m_pos.setX(parts[0].toDouble());
        m_pos.setY(parts[1].toDouble());
        emit positionChanged();
        emit ready();
    }
}
