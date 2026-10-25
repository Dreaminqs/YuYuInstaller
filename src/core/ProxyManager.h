#pragma once

#include <QObject>
#include <QString>
#include <QVector>
#include <QNetworkProxy>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QElapsedTimer>
#include <QSettings>
#include <QTimer>

struct AutoProxyNode {
    QString country;
    QString countryCode;
    QString host;
    int port;
    bool isSocks5;
    int latency{-1};
};

class ProxyManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(int proxyMode READ proxyMode WRITE setProxyMode NOTIFY proxyModeChanged)
    Q_PROPERTY(QString host READ host WRITE setHost NOTIFY hostChanged)
    Q_PROPERTY(int port READ port WRITE setPort NOTIFY portChanged)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY(bool isTesting READ isTesting NOTIFY isTestingChanged)
    Q_PROPERTY(int testStatus READ testStatus NOTIFY testStatusChanged)
    Q_PROPERTY(QString testMessage READ testMessage NOTIFY testMessageChanged)
    Q_PROPERTY(QString proxyUrl READ proxyUrl NOTIFY proxyUrlChanged)

    // Auto In-App VPN Properties
    Q_PROPERTY(bool autoConnecting READ isAutoConnecting NOTIFY autoConnectingChanged)
    Q_PROPERTY(bool autoConnected READ isAutoConnected NOTIFY autoConnectedChanged)
    Q_PROPERTY(QString autoLocation READ autoLocation NOTIFY autoLocationChanged)
    Q_PROPERTY(QString autoCountryCode READ autoCountryCode NOTIFY autoCountryCodeChanged)
    Q_PROPERTY(int autoLatency READ autoLatency NOTIFY autoLatencyChanged)
    Q_PROPERTY(QString autoStatusMessage READ autoStatusMessage NOTIFY autoStatusMessageChanged)
    Q_PROPERTY(QString autoProtocol READ autoProtocol NOTIFY autoProtocolChanged)
    Q_PROPERTY(QString autoExitIp READ autoExitIp NOTIFY autoExitIpChanged)

public:
    enum ProxyMode {
        ModeAutoVPN = 0,        // In-App Smart VPN / Auto Public Tunnel
        ModeSocks5 = 1,         // SOCKS5 (Tor, Cloudflare WARP, v2ray, Clash, SSH)
        ModeHttp = 2            // HTTP / HTTPS Proxy
    };
    Q_ENUM(ProxyMode)

    enum TestStatus {
        StatusNone = 0,
        StatusSuccess = 1,
        StatusFailed = 2
    };
    Q_ENUM(TestStatus)

    explicit ProxyManager(QObject *parent = nullptr);
    ~ProxyManager() override;

    static ProxyManager* instance();

    bool isEnabled() const { return m_enabled; }
    int proxyMode() const { return m_proxyMode; }
    QString host() const { return m_host; }
    int port() const { return m_port; }
    QString username() const { return m_username; }
    QString password() const { return m_password; }
    bool isTesting() const { return m_isTesting; }
    int testStatus() const { return m_testStatus; }
    QString testMessage() const { return m_testMessage; }
    QString proxyUrl() const;

    // Auto VPN Getters
    bool isAutoConnecting() const { return m_autoConnecting; }
    bool isAutoConnected() const { return m_autoConnected; }
    QString autoLocation() const { return m_autoLocation; }
    QString autoCountryCode() const { return m_autoCountryCode; }
    int autoLatency() const { return m_autoLatency; }
    QString autoStatusMessage() const { return m_autoStatusMessage; }
    QString autoProtocol() const { return m_autoIsSocks5 ? "SOCKS5" : "HTTP"; }
    QString autoExitIp() const { return m_autoExitIp; }

public slots:
    void setEnabled(bool enabled);
    void setProxyMode(int mode);
    void setHost(const QString &host);
    void setPort(int port);
    void setUsername(const QString &user);
    void setPassword(const QString &pass);

    void applyProxy();
    void loadSettings();
    void saveSettings();
    void testConnection();

    // Auto In-App VPN Slots
    void startAutoTunnel();
    void switchAutoTunnelNode();
    void stopAutoTunnel();

signals:
    void enabledChanged();
    void proxyModeChanged();
    void hostChanged();
    void portChanged();
    void usernameChanged();
    void passwordChanged();
    void isTestingChanged();
    void testStatusChanged();
    void testMessageChanged();
    void proxyUrlChanged();

    // Auto VPN Signals
    void autoConnectingChanged();
    void autoConnectedChanged();
    void autoLocationChanged();
    void autoCountryCodeChanged();
    void autoLatencyChanged();
    void autoStatusMessageChanged();
    void autoProtocolChanged();
    void autoExitIpChanged();

private:
    static ProxyManager *s_instance;

    void initAutoPool();
    void fetchLiveProxies();
    void testBatch(int startIndex);

    int m_batchPending{0};
    bool m_batchWon{false};

    bool m_enabled{false};
    int m_proxyMode{ModeAutoVPN}; // Default to Auto In-App VPN
    QString m_host{"127.0.0.1"};
    int m_port{40000};
    QString m_username{""};
    QString m_password{""};

    bool m_isTesting{false};
    int m_testStatus{StatusNone};
    QString m_testMessage{""};

    // Auto In-App VPN State
    bool m_autoConnecting{false};
    bool m_autoConnected{false};
    QString m_autoHost{""};
    int m_autoPort{0};
    bool m_autoIsSocks5{true};
    QString m_autoLocation{""};
    QString m_autoCountryCode{"GL"};
    int m_autoLatency{-1};
    QString m_autoStatusMessage{"Ready to connect"};
    QString m_autoExitIp{""};

    QVector<AutoProxyNode> m_autoPool;
    int m_currentPoolIndex{0};

    QNetworkAccessManager *m_testNam{nullptr};
    QNetworkAccessManager *m_autoNam{nullptr};
    QNetworkAccessManager *m_fetchNam{nullptr};
    QElapsedTimer m_timer;
};
