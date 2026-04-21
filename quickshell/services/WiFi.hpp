/* quickshell/services/WiFi.hpp */


#ifndef WIFI_SERVICE_H
#define WIFI_SERVICE_H

#include <QObject>
#include <QString>
#include <QDBusObjectPath>
#include <qqmlintegration.h>

class WiFiService : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(int     strength  READ strength  NOTIFY strengthChanged)   // 0-100
    Q_PROPERTY(int     bitrate   READ bitrate   NOTIFY bitrateChanged)    // kbit/s

public:
    explicit WiFiService(QObject* parent = nullptr);

    bool enabled() const;
    int  strength() const;
    int  bitrate()  const;

    void setEnabled(bool on);

signals:
    void enabledChanged();
    void strengthChanged();
    void bitrateChanged();

private slots:
    void onNmPropertiesChanged(const QString& interface,
                               const QVariantMap& changed,
                               const QStringList& invalidated);

    void onDevicePropertiesChanged(const QString& interface,
                                   const QVariantMap& changed,
                                   const QStringList& invalidated);

    void onApPropertiesChanged(const QString& interface,
                               const QVariantMap& changed,
                               const QStringList& invalidated);

private:
    void fetchInitialState();
    void connectToDevice(const QDBusObjectPath& devicePath);
    void connectToAccessPoint(const QDBusObjectPath& apPath);
    QString activeWirelessDevicePath() const;
    QString activeAccessPointPath(const QString& devicePath) const;

    bool m_enabled = false;
    int    m_strength = 0;
    int    m_bitrate  = 0;

    QString m_devicePath;
    QString m_apPath;
};

#endif /* WIFI_SERVICE_H */
