#include "ProxyManager.h"
#include <QNetworkProxy>
#include <QUrl>
#include <QRegularExpression>
#include <iostream>

ProxyManager *ProxyManager::s_instance = nullptr;

ProxyManager::ProxyManager(QObject *parent)
    : QObject(parent)
    , m_testNam(new QNetworkAccessManager(this))
    , m_autoNam(new QNetworkAccessManager(this))
    , m_fetchNam(new QNetworkAccessManager(this))
{
    s_instance = this;
    initAutoPool();
    loadSettings();
    fetchLiveProxies();
}

ProxyManager::~ProxyManager() {
    if (s_instance == this) {
        s_instance = nullptr;
    }
}

ProxyManager* ProxyManager::instance() {
    return s_instance;
}

void ProxyManager::initAutoPool() {
    m_autoPool.clear();

    // High-uptime, fast public proxy nodes across Europe and North America
    m_autoPool.append({"Germany (Frankfurt)", "DE", "159.65.120.144", 1080, true, -1});
    m_autoPool.append({"Netherlands (Amsterdam)", "NL", "185.162.228.110", 1080, true, -1});
    m_autoPool.append({"France (Paris)", "FR", "51.15.242.202", 1080, true, -1});
    m_autoPool.append({"United Kingdom (London)", "GB", "51.89.255.67", 8080, false, -1});
    m_autoPool.append({"United States (New York)", "US", "192.241.178.115", 1080, true, -1});
    m_autoPool.append({"Sweden (Stockholm)", "SE", "185.105.109.40", 1080, true, -1});
    m_autoPool.append({"Germany (Berlin)", "DE", "194.38.20.26", 1080, true, -1});
    m_autoPool.append({"Netherlands (Rotterdam)", "NL", "185.220.101.5", 8080, false, -1});
    m_autoPool.append({"United States (Los Angeles)", "US", "198.199.86.11", 1080, true, -1});
    m_autoPool.append({"Canada (Toronto)", "CA", "142.93.155.19", 1080, true, -1});
}

void ProxyManager::fetchLiveProxies() {
    // Dynamically retrieve fresh elite public SOCKS5 proxies from public repository
    QNetworkRequest req(QUrl("https://api.proxyscrape.com/v2/?request=displayproxies&protocol=socks5&timeout=2500&country=DE,NL,FR,GB,US,SE&ssl=all&anonymity=elite"));
    req.setHeader(QNetworkRequest::UserAgentHeader, "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/131.0.0.0 Safari/537.36");

    QNetworkReply *reply = m_fetchNam->get(req);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            QString content = QString::fromUtf8(reply->readAll());
            QStringList lines = content.split(QRegularExpression("[\r\n]+"), Qt::SkipEmptyParts);
            int addedCount = 0;
            for (const QString &line : lines) {
                QString trimmed = line.trimmed();
                if (trimmed.isEmpty()) continue;
                QStringList parts = trimmed.split(":");
                if (parts.size() == 2) {
                    bool ok = false;
                    int port = parts[1].toInt(&ok);
                    if (ok && port > 0 && port <= 65535) {
                        m_autoPool.append({"Global Cloud Node", "GL", parts[0], port, true, -1});
                        addedCount++;
                        if (addedCount >= 30) break; // Keep top 30 fresh entries
                    }
                }
            }
            std::cout << "[ProxyManager] Auto VPN pool updated with " << addedCount << " live nodes." << std::endl;
        }
        reply->deleteLater();
    });
}

QString ProxyManager::proxyUrl() const {
    if (!m_enabled) {
        return "";
    }

    if (m_proxyMode == ModeAutoVPN) {
        if (!m_autoConnected || m_autoHost.isEmpty()) {
            return "";
        }
        return QString("%1://%2:%3").arg(m_autoIsSocks5 ? "socks5" : "http", m_autoHost, QString::number(m_autoPort));
    }

    if (m_host.trimmed().isEmpty() || m_port <= 0) {
        return "";
    }

    QString scheme = (m_proxyMode == ModeSocks5) ? "socks5" : "http";
    if (!m_username.isEmpty()) {
        if (!m_password.isEmpty()) {
            return QString("%1://%2:%3@%4:%5").arg(scheme, m_username, m_password, m_host, QString::number(m_port));
        }
        return QString("%1://%2@%3:%5").arg(scheme, m_username, m_host, QString::number(m_port));
    }
    return QString("%1://%2:%3").arg(scheme, m_host, QString::number(m_port));
}

void ProxyManager::setEnabled(bool enabled) {
    if (m_enabled != enabled) {
        m_enabled = enabled;
        emit enabledChanged();
        emit proxyUrlChanged();
        saveSettings();
        applyProxy();

        if (m_enabled && m_proxyMode == ModeAutoVPN && !m_autoConnected) {
            startAutoTunnel();
        } else if (!m_enabled && m_autoConnected) {
            stopAutoTunnel();
        }
    }
}

void ProxyManager::setProxyMode(int mode) {
    if (m_proxyMode != mode) {
        m_proxyMode = mode;
        emit proxyModeChanged();
        emit proxyUrlChanged();
        saveSettings();
        applyProxy();

        if (m_enabled && m_proxyMode == ModeAutoVPN) {
            startAutoTunnel();
        }
    }
}

void ProxyManager::setHost(const QString &host) {
    if (m_host != host.trimmed()) {
        m_host = host.trimmed();
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
    if (m_username != user) {
        m_username = user;
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
    if (!m_enabled) {
        QNetworkProxy::setApplicationProxy(QNetworkProxy(QNetworkProxy::NoProxy));
        std::cout << "[ProxyManager] Direct connection active (Proxy disabled)." << std::endl;
        return;
    }

    if (m_proxyMode == ModeAutoVPN) {
        if (m_autoConnected && !m_autoHost.isEmpty()) {
            QNetworkProxy proxy(m_autoIsSocks5 ? QNetworkProxy::Socks5Proxy : QNetworkProxy::HttpProxy,
                                m_autoHost, static_cast<quint16>(m_autoPort));
            QNetworkProxy::setApplicationProxy(proxy);
            std::cout << "[ProxyManager] Auto VPN Tunnel active: " << m_autoHost.toStdString() << ":" << m_autoPort
                      << " (" << m_autoLocation.toStdString() << ")" << std::endl;
        } else {
            QNetworkProxy::setApplicationProxy(QNetworkProxy(QNetworkProxy::NoProxy));
        }
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
    }
}

void ProxyManager::startAutoTunnel() {
    if (m_autoConnecting) return;
    if (m_autoPool.isEmpty()) {
        initAutoPool();
    }

    m_autoConnecting = true;
    m_autoConnected = false;
    m_autoStatusMessage = "Scanning fastest node...";
    emit autoConnectingChanged();
    emit autoConnectedChanged();
    emit autoStatusMessageChanged();

    testNextCandidate(0);
}

void ProxyManager::testNextCandidate(int attemptCount) {
    if (!m_enabled || m_proxyMode != ModeAutoVPN) {
        m_autoConnecting = false;
        emit autoConnectingChanged();
        return;
    }

    if (attemptCount >= 5 || m_autoPool.isEmpty()) {
        m_autoConnecting = false;
        m_autoConnected = false;
        m_autoStatusMessage = "No node responded. Click to retry.";
        emit autoConnectingChanged();
        emit autoConnectedChanged();
        emit autoStatusMessageChanged();
        return;
    }

    int index = (m_currentPoolIndex + attemptCount) % m_autoPool.size();
    AutoProxyNode candidate = m_autoPool[index];

    QNetworkProxy testProxy(candidate.isSocks5 ? QNetworkProxy::Socks5Proxy : QNetworkProxy::HttpProxy,
                            candidate.host, static_cast<quint16>(candidate.port));
    m_autoNam->setProxy(testProxy);

    QNetworkRequest req(QUrl("https://1.1.1.1/cdn-cgi/trace"));
    req.setHeader(QNetworkRequest::UserAgentHeader, "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/131.0.0.0 Safari/537.36");
    req.setAttribute(QNetworkRequest::RedirectPolicyAttribute, QNetworkRequest::NoLessSafeRedirectPolicy);

    QElapsedTimer *timer = new QElapsedTimer();
    timer->start();

    QNetworkReply *reply = m_autoNam->get(req);

    // 2.5-second timeout for rapid failover
    QTimer *timeoutTimer = new QTimer(reply);
    timeoutTimer->setSingleShot(true);
    connect(timeoutTimer, &QTimer::timeout, reply, [reply]() {
        if (reply->isRunning()) {
            reply->abort();
        }
    });
    timeoutTimer->start(2500);

    connect(reply, &QNetworkReply::finished, this, [this, reply, timeoutTimer, timer, candidate, index, attemptCount]() {
        timeoutTimer->stop();
        qint64 elapsedMs = timer->elapsed();
        delete timer;

        if (reply->error() == QNetworkReply::NoError) {
            // Success! Node connected
            m_currentPoolIndex = (index + 1) % m_autoPool.size();
            m_autoConnecting = false;
            m_autoConnected = true;
            m_autoHost = candidate.host;
            m_autoPort = candidate.port;
            m_autoIsSocks5 = candidate.isSocks5;
            m_autoLocation = candidate.country;
            m_autoCountryCode = candidate.countryCode;
            m_autoLatency = static_cast<int>(elapsedMs);
            m_autoStatusMessage = QString("Connected (%1 ms)").arg(elapsedMs);

            emit autoConnectingChanged();
            emit autoConnectedChanged();
            emit autoLocationChanged();
            emit autoCountryCodeChanged();
            emit autoLatencyChanged();
            emit autoStatusMessageChanged();
            emit autoProtocolChanged();
            emit proxyUrlChanged();

            applyProxy();
        } else {
            // Try next candidate
            testNextCandidate(attemptCount + 1);
        }
        reply->deleteLater();
    });
}

void ProxyManager::switchAutoTunnelNode() {
    m_currentPoolIndex = (m_currentPoolIndex + 1) % qMax(1, m_autoPool.size());
    m_autoConnected = false;
    emit autoConnectedChanged();
    emit proxyUrlChanged();
    startAutoTunnel();
}

void ProxyManager::stopAutoTunnel() {
    m_autoConnecting = false;
    m_autoConnected = false;
    m_autoStatusMessage = "Tunnel stopped";
    emit autoConnectingChanged();
    emit autoConnectedChanged();
    emit autoStatusMessageChanged();
    emit proxyUrlChanged();
    applyProxy();
}

void ProxyManager::loadSettings() {
    QSettings s;
    s.beginGroup("Proxy");
    m_enabled = s.value("enabled", false).toBool();
    m_proxyMode = s.value("mode", ModeAutoVPN).toInt();
    m_host = s.value("host", "127.0.0.1").toString();
    m_port = s.value("port", 40000).toInt();
    m_username = s.value("username", "").toString();
    m_password = s.value("password", "").toString();
    s.endGroup();

    if (m_enabled && m_proxyMode == ModeAutoVPN) {
        startAutoTunnel();
    } else {
        applyProxy();
    }
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
    std::cout << "[ProxyManager] Proxy settings saved." << std::endl;
}

void ProxyManager::testConnection() {
    if (m_isTesting) return;

    m_isTesting = true;
    m_testStatus = StatusNone;
    m_testMessage = "Testing connection...";
    emit isTestingChanged();
    emit testStatusChanged();
    emit testMessageChanged();

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
            } else if (reply->error() == QNetworkReply::ProxyConnectionRefusedError) {
                m_testMessage = QString("Proxy not running on %1:%2").arg(m_host, QString::number(m_port));
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
