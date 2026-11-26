#include "ProxyManager.h"
#include <QNetworkProxy>
#include <QUrl>
#include <QRegularExpression>
#include <QCoreApplication>
#include <QFileInfo>
#include <QDir>
#include <QStandardPaths>
#include <QTcpSocket>
#include <QTimer>
#include <QFile>
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
}

ProxyManager::~ProxyManager() {
    stopWarpTunnel();
    if (s_instance == this) {
        s_instance = nullptr;
    }
}

ProxyManager* ProxyManager::instance() {
    return s_instance;
}

void ProxyManager::initAutoPool() {
    m_autoPool.clear();
}

void ProxyManager::fetchLiveProxies() {
    // Deprecated: YuYuInstaller now uses dedicated embedded Cloudflare WARP (usque MASQUE tunnel).
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
        return QString("%1://%2@%3:%4").arg(scheme, m_username, m_host, QString::number(m_port));
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

static QString findBundledExecutable(const QString &name) {
    const QStringList candidates = {
        QCoreApplication::applicationDirPath() + "/" + name,
        QCoreApplication::applicationDirPath() + "/build/" + name,
        QDir::currentPath() + "/build/" + name,
        QDir::currentPath() + "/" + name
    };
    for (const auto &p : candidates) {
        if (QFileInfo::exists(p)) {
            return QDir::toNativeSeparators(p);
        }
    }
    return QString();
}

QString ProxyManager::findWarpExecutable() {
    return findBundledExecutable("warp-plus.exe");
}

QString ProxyManager::findUsqueExecutable() {
    return findBundledExecutable("usque.exe");
}

bool ProxyManager::isWarpAvailable() const {
    return !findUsqueExecutable().isEmpty() || !findWarpExecutable().isEmpty();
}

void ProxyManager::toggleWarpTunnel() {
    if (m_warpRunning || m_autoConnecting) {
        stopWarpTunnel();
    } else {
        startWarpTunnel();
    }
}

void ProxyManager::markWarpActive(const QString &location) {
    if (m_warpRunning) return;

    m_warpRunning = true;
    m_autoConnecting = false;
    m_autoConnected = true;
    m_autoHost = "127.0.0.1";
    m_autoPort = 40000;
    m_autoIsSocks5 = true;
    m_autoLocation = location;
    m_autoCountryCode = "CF";
    m_autoLatency = 15;
    m_autoStatusMessage = "Cloudflare WARP Aktif (Eduroam Engeli Aşıldı)";
    m_enabled = true;
    m_proxyMode = ModeAutoVPN;

    applyProxy();

    emit warpRunningChanged();
    emit autoConnectingChanged();
    emit autoConnectedChanged();
    emit enabledChanged();
    emit proxyModeChanged();
    emit autoLocationChanged();
    emit autoCountryCodeChanged();
    emit autoLatencyChanged();
    emit autoStatusMessageChanged();
    emit autoProtocolChanged();
    emit autoExitIpChanged();
    emit proxyUrlChanged();
}

void ProxyManager::handleWarpProcessExit(QProcess *proc) {
    // Ignore exit notifications from processes we already replaced / stopped.
    if (proc != m_warpProcess) return;

    m_warpProcess = nullptr;
    proc->deleteLater();
    ++m_warpSession;

    const bool wasRunning = m_warpRunning;
    m_warpRunning = false;
    m_autoConnecting = false;
    emit warpRunningChanged();
    emit autoConnectingChanged();

    if (wasRunning && m_autoPort == 40000) {
        m_autoConnected = false;
        m_enabled = false;
        m_autoStatusMessage = "WARP tüneli kapandı.";
        emit autoConnectedChanged();
        emit enabledChanged();
        emit autoStatusMessageChanged();
        emit proxyUrlChanged();
        applyProxy();
    }
}

void ProxyManager::failWarpTunnel(const QString &message) {
    stopWarpTunnel();
    m_autoStatusMessage = message;
    emit autoStatusMessageChanged();
}

void ProxyManager::startWarpTunnel() {
    if (m_warpRunning || m_autoConnecting) return;

    // Preferred engine: usque (MASQUE over HTTP/2 + TLS, TCP 443).
    // eduroam and most campus networks drop WireGuard UDP traffic (warp-plus completes the
    // handshake but every data packet is filtered), while TCP 443 is always allowed.
    const QString usquePath = findUsqueExecutable();
    if (!usquePath.isEmpty()) {
        startUsqueTunnel(usquePath);
        return;
    }

    // Legacy fallback: warp-plus (WireGuard over UDP)
    QString exePath = findWarpExecutable();
    if (exePath.isEmpty()) {
        m_autoStatusMessage = "WARP motoru (usque.exe / warp-plus.exe) bulunamadı.";
        emit autoStatusMessageChanged();
        return;
    }

    if (m_warpProcess) {
        QProcess *old = m_warpProcess;
        m_warpProcess = nullptr;
        old->kill();
        old->deleteLater();
    }

    const int session = ++m_warpSession;
    QProcess *proc = new QProcess(this);
    m_warpProcess = proc;
    proc->setProcessChannelMode(QProcess::MergedChannels);
    QString cacheDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/warp_cache";
    QDir().mkpath(cacheDir);

    QStringList args;
    args << "-4";
    args << "-b" << "127.0.0.1:40000";
    args << "--dns" << "1.1.1.1";
    args << "-e" << "162.159.195.243:2408";
    args << "--cache-dir" << QDir::toNativeSeparators(cacheDir);

    m_autoConnecting = true;
    m_autoStatusMessage = "Cloudflare WARP tüneli kuruluyor...";
    emit autoConnectingChanged();
    emit autoStatusMessageChanged();

    connect(proc, &QProcess::readyReadStandardOutput, this, [this, proc]() {
        QByteArray out = proc->readAllStandardOutput();
        std::cout << "[WARP] " << out.toStdString() << std::endl;
        if (proc != m_warpProcess) return;
        const QString str = QString::fromUtf8(out);
        if (str.contains("serving proxy") || str.contains("connection test successful")) {
            markWarpActive("Cloudflare WARP (Yerleşik Tünel)");
        }
    });

    connect(proc, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this,
            [this, proc](int, QProcess::ExitStatus) { handleWarpProcessExit(proc); });

    proc->start(exePath, args);

    QTimer::singleShot(20000, this, [this, session]() {
        if (session != m_warpSession || m_warpRunning || !m_autoConnecting) return;
        failWarpTunnel("WARP tüneli kurulamadı (Ağ / Eduroam engeli tespit edildi).");
    });
}

void ProxyManager::startUsqueTunnel(const QString &exePath) {
    const QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/usque";
    QDir().mkpath(dataDir);
    const QString configPath = QDir::toNativeSeparators(dataDir + "/config.json");

    const int session = ++m_warpSession;
    m_autoConnecting = true;
    m_autoStatusMessage = "Cloudflare WARP tüneli kuruluyor (TCP 443)...";
    emit autoConnectingChanged();
    emit autoStatusMessageChanged();

    if (QFileInfo::exists(configPath)) {
        launchUsqueSocks(exePath, configPath, session);
        return;
    }

    // First run: register a free Cloudflare WARP device (one-time, stored in AppData)
    m_autoStatusMessage = "Cloudflare WARP hesabı oluşturuluyor...";
    emit autoStatusMessageChanged();

    QProcess *reg = new QProcess(this);
    m_usqueRegProcess = reg;
    reg->setProcessChannelMode(QProcess::MergedChannels);
    connect(reg, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this,
            [this, reg, exePath, configPath, session](int exitCode, QProcess::ExitStatus status) {
        std::cout << "[WARP/usque register] " << reg->readAll().toStdString() << std::endl;
        if (m_usqueRegProcess == reg) m_usqueRegProcess = nullptr;
        reg->deleteLater();
        if (session != m_warpSession) return;

        if (status == QProcess::NormalExit && exitCode == 0 && QFileInfo::exists(configPath)) {
            launchUsqueSocks(exePath, configPath, session);
        } else {
            QFile::remove(configPath);
            failWarpTunnel("WARP hesabı oluşturulamadı (Cloudflare'a ulaşılamadı).");
        }
    });
    reg->start(exePath, {"-c", configPath, "register", "-a"});
}

void ProxyManager::launchUsqueSocks(const QString &exePath, const QString &configPath, int session) {
    if (m_warpProcess) {
        QProcess *old = m_warpProcess;
        m_warpProcess = nullptr;
        old->kill();
        old->deleteLater();
    }

    QProcess *proc = new QProcess(this);
    m_warpProcess = proc;
    m_usqueVerifying = false;
    proc->setProcessChannelMode(QProcess::MergedChannels);

    connect(proc, &QProcess::readyReadStandardOutput, this, [this, proc, session]() {
        QByteArray out = proc->readAllStandardOutput();
        std::cout << "[WARP/usque] " << out.toStdString() << std::endl;
        if (proc != m_warpProcess || session != m_warpSession) return;
        const QString text = QString::fromUtf8(out);
        if (!m_usqueVerifying && (text.contains("Connected to MASQUE server") || text.contains("SOCKS proxy listening"))) {
            m_usqueVerifying = true;
            m_autoStatusMessage = "WARP tüneli doğrulanıyor...";
            emit autoStatusMessageChanged();
            // Small delay if triggered on 'SOCKS proxy listening' so '--always-reconnect' finishes TLS handshake
            const int delayMs = text.contains("Connected to MASQUE server") ? 50 : 600;
            QTimer::singleShot(delayMs, this, [this, session]() {
                verifyUsqueTunnel(session, 1);
            });
        }
    });

    connect(proc, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this,
            [this, proc](int, QProcess::ExitStatus) { handleWarpProcessExit(proc); });

    QStringList args;
    args << "-c" << configPath << "socks";
    args << "-b" << "127.0.0.1" << "-p" << "40000";
    args << "--http2";                 // TLS over TCP 443: passes eduroam / campus firewalls
    args << "--always-reconnect";      // Connect immediately and prevent idle tunnel drops
    args << "-S";                      // Disable IPv6 inside tunnel for faster IPv4 CDN resolution
    args << "-d" << "1.1.1.1" << "-d" << "1.0.0.1";
    proc->start(exePath, args);

    // Hard timeout for the whole connect + verify sequence
    QTimer::singleShot(45000, this, [this, session]() {
        if (session != m_warpSession || m_warpRunning || !m_autoConnecting) return;
        failWarpTunnel("WARP tüneli kurulamadı (Cloudflare'a TCP 443 üzerinden ulaşılamadı).");
    });
}

void ProxyManager::verifyUsqueTunnel(int session, int attempt) {
    if (session != m_warpSession || m_warpRunning || !m_warpProcess) return;

    // usque connects lazily on first traffic, so a real request through the proxy both
    // establishes the tunnel and proves that traffic actually flows through Cloudflare.
    QNetworkAccessManager *nam = new QNetworkAccessManager(this);
    nam->setProxy(QNetworkProxy(QNetworkProxy::Socks5Proxy, "127.0.0.1", 40000));

    QNetworkRequest req(QUrl("https://www.cloudflare.com/cdn-cgi/trace"));
    req.setHeader(QNetworkRequest::UserAgentHeader, "YuYuInstaller");
    QNetworkReply *reply = nam->get(req);

    QTimer *timeout = new QTimer(reply);
    timeout->setSingleShot(true);
    connect(timeout, &QTimer::timeout, reply, [reply]() {
        if (reply->isRunning()) reply->abort();
    });
    timeout->start(12000);

    connect(reply, &QNetworkReply::finished, this, [this, reply, nam, session, attempt]() {
        const QString body = QString::fromUtf8(reply->readAll());
        const bool ok = reply->error() == QNetworkReply::NoError
                        && (body.contains("warp=on") || body.contains("warp=plus"));
        reply->deleteLater();
        nam->deleteLater();
        if (session != m_warpSession || m_warpRunning) return;

        if (ok) {
            const QRegularExpressionMatch ip = QRegularExpression("(?m)^ip=(.+)$").match(body);
            if (ip.hasMatch()) m_autoExitIp = ip.captured(1).trimmed();
            markWarpActive("Cloudflare WARP (MASQUE / TCP 443)");
            return;
        }

        if (attempt < 4) {
            QTimer::singleShot(1500, this, [this, session, attempt]() {
                verifyUsqueTunnel(session, attempt + 1);
            });
        } else {
            failWarpTunnel("WARP tüneli kurulamadı (Ağ trafiği Cloudflare'a iletilemedi).");
        }
    });
}

void ProxyManager::stopWarpTunnel() {
    ++m_warpSession;
    m_usqueVerifying = false;

    if (m_usqueRegProcess) {
        QProcess *reg = m_usqueRegProcess;
        m_usqueRegProcess = nullptr;
        reg->kill();
        reg->deleteLater();
    }

    if (m_warpProcess) {
        QProcess *proc = m_warpProcess;
        m_warpProcess = nullptr;   // detach first so the finished handler ignores it
        if (proc->state() != QProcess::NotRunning) {
            proc->terminate();
            if (!proc->waitForFinished(500)) {
                proc->kill();
                proc->waitForFinished(500);
            }
        }
        proc->deleteLater();
    }

    m_warpRunning = false;
    m_autoConnecting = false;
    emit warpRunningChanged();
    emit autoConnectingChanged();

    if (m_autoPort == 40000) {
        m_autoConnected = false;
        m_enabled = false;
        m_autoStatusMessage = "Bağlantı kapalı";
        emit autoConnectedChanged();
        emit enabledChanged();
        emit autoStatusMessageChanged();
        emit proxyUrlChanged();
        applyProxy();
    }
}

void ProxyManager::startAutoTunnel() {
    startWarpTunnel();
}

void ProxyManager::testBatch(int startIndex) {
    Q_UNUSED(startIndex);
}

void ProxyManager::switchAutoTunnelNode() {
    if (m_warpRunning) {
        stopWarpTunnel();
    }
    startWarpTunnel();
}

void ProxyManager::stopAutoTunnel() {
    if (m_warpRunning) {
        stopWarpTunnel();
    }
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
