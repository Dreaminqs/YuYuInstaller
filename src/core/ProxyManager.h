#pragma once

#include <QObject>
#include <QString>
#include <QNetworkProxy>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QElapsedTimer>
#include <QSettings>

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

public:
    enum ProxyMode {
        ModeDirect = 0,         // Direct / Off
        ModeCloudflareDoh = 1,  // Cloudflare Fast Privacy & DoH
        ModeSocks5 = 2,         // Custom SOCKS5 (Tor, v2ray, Clash, SSH)
        ModeHttp = 3            // Custom HTTP / HTTPS Proxy
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

private:
    static ProxyManager *s_instance;

    bool m_enabled{false};
    int m_proxyMode{ModeDirect};
    QString m_host{"127.0.0.1"};
    int m_port{10808};
    QString m_username{""};
    QString m_password{""};

    bool m_isTesting{false};
    int m_testStatus{StatusNone};
    QString m_testMessage{""};

    QNetworkAccessManager *m_testNam{nullptr};
    QElapsedTimer m_timer;
};
