/* quickshell/services/WiFi.hpp */


#ifndef WIFI_SERVICE_H
#define WIFI_SERVICE_H

#include <QObject>
#include <QString>
#include <qqmlintegration.h>

class WiFiService : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)

public:
    explicit WiFiService(QObject* parent = nullptr);

    bool enabled() const;
    void setEnabled(bool on);

signals:
    void enabledChanged();

private slots:
    void onPropertiesChanged(const QString& interface,
                             const QVariantMap& changed,
                             const QStringList& invalidated);

private:
    void fetchInitialState();
    bool m_enabled = false;
};

#endif /* WIFI_SERVICE_H */
