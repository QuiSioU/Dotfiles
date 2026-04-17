/* quickshell/services/WiFi.cpp */


#include "WiFi.hpp"

#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDBusVariant>
#include <QDebug>

static const QString NM_SERVICE   = "org.freedesktop.NetworkManager";
static const QString NM_PATH      = "/org/freedesktop/NetworkManager";
static const QString NM_IFACE     = "org.freedesktop.NetworkManager";
static const QString PROPS_IFACE  = "org.freedesktop.DBus.Properties";

WiFiService::WiFiService(QObject* parent) : QObject(parent) {
    fetchInitialState();

    QDBusConnection::systemBus().connect(
        NM_SERVICE,
        NM_PATH,
        PROPS_IFACE,
        "PropertiesChanged",
        this,
        SLOT(onPropertiesChanged(QString, QVariantMap, QStringList))
    );
}

bool WiFiService::enabled() const { return m_enabled; }

void WiFiService::setEnabled(bool on) {
    if (m_enabled == on) return;

    QDBusInterface nm(NM_SERVICE, NM_PATH, PROPS_IFACE,
                      QDBusConnection::systemBus());
    nm.asyncCall("Set",
                 NM_IFACE,
                 QString("WirelessEnabled"),
                 QVariant::fromValue(QDBusVariant(on)));
    // State will update reactively via PropertiesChanged
}

void WiFiService::fetchInitialState() {
    QDBusInterface nm(NM_SERVICE, NM_PATH, PROPS_IFACE,
                      QDBusConnection::systemBus());
    QDBusReply<QVariant> reply = nm.call("Get", NM_IFACE, QString("WirelessEnabled"));
    if (reply.isValid()) {
        m_enabled = reply.value().toBool();
    } else {
        qWarning() << "WiFiService: failed to get WirelessEnabled:" << reply.error().message();
    }
}

void WiFiService::onPropertiesChanged(const QString& interface,
                                       const QVariantMap& changed,
                                       const QStringList&)
{
    if (interface != NM_IFACE) return;
    if (!changed.contains("WirelessEnabled")) return;

    const bool newVal = changed["WirelessEnabled"].toBool();
    if (m_enabled == newVal) return;
    m_enabled = newVal;
    emit enabledChanged();
}
