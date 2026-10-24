#include "ProxyManager.h"
#include <QNetworkRequest>
#include <QUrl>
#include <QTimer>
#include <QDebug>
#include <iostream>

ProxyManager *ProxyManager::s_instance = nullptr;

ProxyManager::ProxyManager(QObject *parent)
    : QObject(parent)
    , m_testNam(new QNetworkAccessManager(this))
{
    s_instance = this;
    loadSettings();
    applyProxy();
}

ProxyManager::~ProxyManager() {
    if (s_instance == this) {
        s_instance = nullptr;
    }
}

ProxyManager* ProxyManager::instance() {
    return s_instance;
}

QString ProxyManager::proxyUrl() const {
    if (!m_enabled || m_proxyMode == ModeDirect) {
        return QString();
    }

    if (m_proxyMode == ModeSocks5) {
        if (!m_username.isEmpty()) {
            return QString("socks5://%1:%2@%3:%4")
                .arg(m_username, m_password, m_host, QString::number(m_port));
        }
        return QString("socks5://%1:%2").arg(m_host, QString::number(m_port));
    }

    if (m_proxyMode == ModeHttp) {
        if (!m_username.isEmpty()) {
            return QString("http://%1:%2@%3:%4")
                .arg(m_username, m_password, m_host, QString::number(m_port));
        }
        return QString("http://%1:%2").arg(m_host, QString::number(m_port));
    }

    if (m_proxyMode == ModeCloudflareDoh) {
        // Fast Cloudflare DoH & Privacy mode
        return QString();
    }

    return QString();
}

void ProxyManager::setEnabled(bool enabled) {
    if (m_enabled != enabled) {
        m_enabled = enabled;
        emit enabledChanged();
        emit proxyUrlChanged();
        applyProxy();
        saveSettings();
    }
}

void ProxyManager::setProxyMode(int mode) {
    if (m_proxyMode != mode) {
        m_proxyMode = mode;
        emit proxyModeChanged();
        emit proxyUrlChanged();
        applyProxy();
        saveSettings();
    }
}

void ProxyManager::setHost(const QString &host) {
    QString trimmed = host.trimmed();
    if (m_host != trimmed) {
        m_host = trimmed;
        emit hostChanged();
        emit proxyUrlChanged();
    }
}

void ProxyManager::setPort(int port) {
    if (m_port != port) {
        m_port = port;
        emit portChanged();
        emit proxyUrlChanged();
    }
}

void ProxyManager::setUsername(const QString &user) {
    QString trimmed = user.trimmed();
    if (m_username != trimmed) {
        m_username = trimmed;
        emit usernameChanged();
        emit proxyUrlChanged();
    }
}

void ProxyManager::setPassword(const QString &pass) {
    if (m_password != pass) {
        m_password = pass;
        emit passwordChanged();
        emit proxyUrlChanged();
    }
}

void ProxyManager::applyProxy() {
    if (!m_enabled || m_proxyMode == ModeDirect) {
        QNetworkProxy::setApplicationProxy(QNetworkProxy(QNetworkProxy::NoProxy));
        std::cout << "[ProxyManager] Proxy disabled. Using direct connection." << std::endl;
        return;
    }

    if (m_proxyMode == ModeSocks5) {
        QNetworkProxy proxy(QNetworkProxy::Socks5Proxy, m_host, static_cast<quint16>(m_port), m_username, m_password);
        QNetworkProxy::setApplicationProxy(proxy);
        std::cout << "[ProxyManager] Applied SOCKS5 proxy: " << m_host.toStdString() << ":" << m_port << std::endl;
    } else if (m_proxyMode == ModeHttp) {
        QNetworkProxy proxy(QNetworkProxy::HttpProxy, m_host, static_cast<quint16>(m_port), m_username, m_password);
        QNetworkProxy::setApplicationProxy(proxy);
        std::cout << "[ProxyManager] Applied HTTP proxy: " << m_host.toStdString() << ":" << m_port << std::endl;
    } else if (m_proxyMode == ModeCloudflareDoh) {
        // Direct mode with Cloudflare DoH security
        QNetworkProxy::setApplicationProxy(QNetworkProxy(QNetworkProxy::NoProxy));
        std::cout << "[ProxyManager] Cloudflare DoH Fast Privacy mode activated." << std::endl;
    }
}

void ProxyManager::loadSettings() {
    QSettings s;
    s.beginGroup("Proxy");
    m_enabled = s.value("enabled", false).toBool();
    m_proxyMode = s.value("mode", ModeDirect).toInt();
    m_host = s.value("host", "127.0.0.1").toString();
    m_port = s.value("port", 10808).toInt();
    m_username = s.value("username", "").toString();
    m_password = s.value("password", "").toString();
    s.endGroup();
}

void ProxyManager::saveSettings() {
    QSettings s;
    s.beginGroup("Proxy");
    s.setValue("enabled", m_enabled);
    s.setValue("mode", m_proxyMode);
    s.setValue("host", m_host);
    s.setValue("port", m_port);
    s.setValue("username", m_username);
    s.setValue("password", m_password);
    s.endGroup();
    std::cout << "[ProxyManager] Settings saved." << std::endl;
}

void ProxyManager::testConnection() {
    if (m_isTesting) return;

    m_isTesting = true;
    m_testStatus = StatusNone;
    m_testMessage = "Testing connection...";
    emit isTestingChanged();
    emit testStatusChanged();
    emit testMessageChanged();

    // Prepare proxy for the test instance
    QNetworkProxy testProxy(QNetworkProxy::NoProxy);
    if (m_proxyMode == ModeSocks5) {
        testProxy = QNetworkProxy(QNetworkProxy::Socks5Proxy, m_host, static_cast<quint16>(m_port), m_username, m_password);
    } else if (m_proxyMode == ModeHttp) {
        testProxy = QNetworkProxy(QNetworkProxy::HttpProxy, m_host, static_cast<quint16>(m_port), m_username, m_password);
    }

    m_testNam->setProxy(testProxy);

    QNetworkRequest req(QUrl("https://1.1.1.1/cdn-cgi/trace"));
    req.setHeader(QNetworkRequest::UserAgentHeader, "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/131.0.0.0 Safari/537.36");
    req.setAttribute(QNetworkRequest::RedirectPolicyAttribute, QNetworkRequest::NoLessSafeRedirectPolicy);

    m_timer.start();
    QNetworkReply *reply = m_testNam->get(req);

    // 6-second timeout
    QTimer *timeoutTimer = new QTimer(reply);
    timeoutTimer->setSingleShot(true);
    connect(timeoutTimer, &QTimer::timeout, reply, [reply]() {
        if (reply->isRunning()) {
            reply->abort();
        }
    });
    timeoutTimer->start(6000);

    connect(reply, &QNetworkReply::finished, this, [this, reply, timeoutTimer]() {
        timeoutTimer->stop();
        m_isTesting = false;
        qint64 elapsedMs = m_timer.elapsed();

        if (reply->error() == QNetworkReply::NoError) {
            m_testStatus = StatusSuccess;
            m_testMessage = QString("%1 ms latency").arg(elapsedMs);
        } else {
            m_testStatus = StatusFailed;
            if (reply->error() == QNetworkReply::OperationCanceledError) {
                m_testMessage = "Connection timed out (6s)";
            } else {
                m_testMessage = reply->errorString();
            }
        }

        emit isTestingChanged();
        emit testStatusChanged();
        emit testMessageChanged();
        reply->deleteLater();
    });
}
