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

    // High-uptime, fast verified live public proxy nodes
    m_autoPool.append({"Netherlands (Amsterdam)", "NL", "144.124.251.24", 10649, false, -1});
    m_autoPool.append({"Netherlands (Amsterdam)", "NL", "144.124.251.24", 11205, false, -1});
    m_autoPool.append({"United States (Azure)", "US", "4.144.146.21", 80, false, -1});
    m_autoPool.append({"Germany (Frankfurt)", "DE", "194.150.110.134", 80, false, -1});
    m_autoPool.append({"Netherlands (Amsterdam)", "NL", "144.124.251.24", 10023, false, -1});
    m_autoPool.append({"Germany (Frankfurt)", "DE", "159.65.120.144", 1080, true, -1});
    m_autoPool.append({"France (Paris)", "FR", "51.15.242.202", 1080, true, -1});
    m_autoPool.append({"Netherlands (Rotterdam)", "NL", "145.220.227.154", 8080, false, -1});
    m_autoPool.append({"United States (New York)", "US", "192.241.178.115", 1080, true, -1});
    m_autoPool.append({"United Kingdom (London)", "GB", "51.89.255.67", 8080, false, -1});
}

void ProxyManager::fetchLiveProxies() {
    // Dynamically retrieve fresh verified HTTPS proxies from GitHub RAW repository
    QNetworkRequest req(QUrl("https://raw.githubusercontent.com/roosterkid/openproxylist/main/HTTPS_RAW.txt"));
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
                        m_autoPool.append({"Global Cloud Node", "GL", parts[0], port, false, -1});
                        addedCount++;
                        if (addedCount >= 40) break;
                    }
                }
            }
            std::cout << "[ProxyManager] Auto VPN pool updated with " << addedCount << " live HTTPS nodes." << std::endl;
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
        } else if (!m_enabled) {
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
            std::cout << "[ProxyManager] Auto VPN active: " << m_autoHost.toStdString() << ":" << m_autoPort
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
    m_batchWon = false;
    m_autoStatusMessage = "Connecting to fast node...";
    emit autoConnectingChanged();
    emit autoConnectedChanged();
    emit autoStatusMessageChanged();

    testBatch(m_currentPoolIndex);
}

void ProxyManager::testBatch(int startIndex) {
    if (!m_enabled || m_proxyMode != ModeAutoVPN) {
        m_autoConnecting = false;
        emit autoConnectingChanged();
        return;
    }

    if (m_autoPool.isEmpty() || startIndex >= m_currentPoolIndex + 16) {
        m_autoConnecting = false;
        m_autoConnected = false;
        m_autoStatusMessage = "No node responded. Click to retry.";
        emit autoConnectingChanged();
        emit autoConnectedChanged();
        emit autoStatusMessageChanged();
        return;
    }

    m_batchWon = false;
    int batchSize = qMin(4, m_autoPool.size());
    m_batchPending = batchSize;

    for (int i = 0; i < batchSize; ++i) {
        int idx = (startIndex + i) % m_autoPool.size();
        AutoProxyNode node = m_autoPool[idx];

        QNetworkAccessManager *probeNam = new QNetworkAccessManager(this);
        QNetworkProxy proxy(node.isSocks5 ? QNetworkProxy::Socks5Proxy : QNetworkProxy::HttpProxy,
                            node.host, static_cast<quint16>(node.port));
        probeNam->setProxy(proxy);

        QNetworkRequest req(QUrl("https://cp.cloudflare.com/generate_204"));
        req.setHeader(QNetworkRequest::UserAgentHeader, "YuYuInstaller/1.1.9");

        QElapsedTimer *timer = new QElapsedTimer();
        timer->start();

        QNetworkReply *reply = probeNam->get(req);
        reply->ignoreSslErrors();

        // 2-second timeout per candidate
        QTimer *timeoutTimer = new QTimer(reply);
        timeoutTimer->setSingleShot(true);
        connect(timeoutTimer, &QTimer::timeout, reply, [reply]() {
            if (reply->isRunning()) {
                reply->abort();
            }
        });
        timeoutTimer->start(2000);

        connect(reply, &QNetworkReply::finished, this, [this, reply, timeoutTimer, timer, probeNam, node, idx, startIndex]() {
            timeoutTimer->stop();
            qint64 elapsedMs = timer->elapsed();
            delete timer;

            int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
            bool ok = (reply->error() == QNetworkReply::NoError) && (statusCode == 204 || statusCode == 200);

            if (ok && !m_batchWon && m_enabled && m_proxyMode == ModeAutoVPN) {
                m_batchWon = true;
                m_currentPoolIndex = (idx + 1) % m_autoPool.size();
                m_autoConnecting = false;
                m_autoConnected = true;
                m_autoHost = node.host;
                m_autoPort = node.port;
                m_autoIsSocks5 = node.isSocks5;
                m_autoLocation = node.country;
                m_autoCountryCode = node.countryCode;
                m_autoLatency = static_cast<int>(elapsedMs);
                m_autoStatusMessage = QString("Connected (%1 ms)").arg(elapsedMs);
                m_autoExitIp = node.host;

                emit autoConnectingChanged();
                emit autoConnectedChanged();
                emit autoLocationChanged();
                emit autoCountryCodeChanged();
                emit autoLatencyChanged();
                emit autoStatusMessageChanged();
                emit autoProtocolChanged();
                emit autoExitIpChanged();
                emit proxyUrlChanged();

                applyProxy();

                // Concurrently query external exit IP through this proxy to confirm real IP concealment
                QNetworkAccessManager *ipNam = new QNetworkAccessManager(this);
                QNetworkProxy ipProxy(node.isSocks5 ? QNetworkProxy::Socks5Proxy : QNetworkProxy::HttpProxy,
                                      node.host, static_cast<quint16>(node.port));
                ipNam->setProxy(ipProxy);
                QNetworkRequest ipReq(QUrl("https://api.ipify.org"));
                ipReq.setHeader(QNetworkRequest::UserAgentHeader, "YuYuInstaller/1.1.9");
                QNetworkReply *ipReply = ipNam->get(ipReq);
                ipReply->ignoreSslErrors();
                QTimer *ipTimeout = new QTimer(ipReply);
                ipTimeout->setSingleShot(true);
                connect(ipTimeout, &QTimer::timeout, ipReply, [ipReply]() {
                    if (ipReply->isRunning()) ipReply->abort();
                });
                ipTimeout->start(3500);
                connect(ipReply, &QNetworkReply::finished, this, [this, ipReply, ipNam, ipTimeout]() {
                    ipTimeout->stop();
                    if (ipReply->error() == QNetworkReply::NoError) {
                        QString raw = QString::fromUtf8(ipReply->readAll()).trimmed();
                        if (!raw.isEmpty()) {
                            m_autoExitIp = raw;
                            emit autoExitIpChanged();
                        }
                    }
                    ipReply->deleteLater();
                    ipNam->deleteLater();
                });
            }

            reply->deleteLater();
            probeNam->deleteLater();

            m_batchPending--;
            if (m_batchPending <= 0 && !m_batchWon) {
                // Entire batch failed, try next batch!
                testBatch(startIndex + 4);
            }
        });
    }
}

void ProxyManager::switchAutoTunnelNode() {
    m_currentPoolIndex = (m_currentPoolIndex + 1) % qMax(1, m_autoPool.size());
    m_autoConnected = false;
    m_autoExitIp = "";
    emit autoConnectedChanged();
    emit autoExitIpChanged();
    emit proxyUrlChanged();
    startAutoTunnel();
}

void ProxyManager::stopAutoTunnel() {
    m_autoConnecting = false;
    m_autoConnected = false;
    m_autoExitIp = "";
    m_autoStatusMessage = "Tunnel stopped";
    emit autoConnectingChanged();
    emit autoConnectedChanged();
    emit autoExitIpChanged();
    emit autoStatusMessageChanged();
    emit proxyUrlChanged();
    applyProxy();
}

void ProxyManager::loadSettings() {
    QSettings s;
    s.beginGroup("Proxy");
    // ALWAYS start with VPN / Proxy disabled on app launch (user enables manually when desired)
    m_enabled = false;
    m_proxyMode = s.value("mode", ModeAutoVPN).toInt();
    m_host = s.value("host", "127.0.0.1").toString();
    m_port = s.value("port", 40000).toInt();
    m_username = s.value("username", "").toString();
    m_password = s.value("password", "").toString();
    s.endGroup();

    applyProxy();
}

void ProxyManager::saveSettings() {
    QSettings s;
    s.beginGroup("Proxy");
    s.setValue("enabled", false); // Keep false across restarts
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

    QNetworkRequest req(QUrl("https://cp.cloudflare.com/generate_204"));
    req.setHeader(QNetworkRequest::UserAgentHeader, "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/131.0.0.0 Safari/537.36");

    m_timer.start();
    QNetworkReply *reply = m_testNam->get(req);
    reply->ignoreSslErrors();

    // 5-second timeout
    QTimer *timeoutTimer = new QTimer(reply);
    timeoutTimer->setSingleShot(true);
    connect(timeoutTimer, &QTimer::timeout, reply, [reply]() {
        if (reply->isRunning()) {
            reply->abort();
        }
    });
    timeoutTimer->start(5000);

    connect(reply, &QNetworkReply::finished, this, [this, reply, timeoutTimer]() {
        timeoutTimer->stop();
        m_isTesting = false;
        qint64 elapsedMs = m_timer.elapsed();

        int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        if (reply->error() == QNetworkReply::NoError && (statusCode == 204 || statusCode == 200)) {
            m_testStatus = StatusSuccess;
            m_testMessage = QString("%1 ms latency").arg(elapsedMs);
        } else {
            m_testStatus = StatusFailed;
            if (reply->error() == QNetworkReply::OperationCanceledError) {
                m_testMessage = "Connection timed out (5s)";
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
