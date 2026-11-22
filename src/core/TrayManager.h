#pragma once

#include <QObject>
#include <QString>

#ifdef _WIN32
#include <windows.h>
#include <shellapi.h>
#endif

class TrayManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isVisible READ isVisible NOTIFY visibilityChanged)

public:
    explicit TrayManager(QObject *parent = nullptr);
    ~TrayManager() override;

    bool isVisible() const { return m_isAdded; }

    Q_INVOKABLE void showTrayIcon();
    Q_INVOKABLE void hideTrayIcon();
    Q_INVOKABLE void updateToolTip(const QString &tip);
    Q_INVOKABLE void showNotification(const QString &title, const QString &message);

#ifdef _WIN32
    void handleTrayMessage(LPARAM lParam);
    void showContextMenu();
#endif

signals:
    void visibilityChanged();
    void requestRestoreWindow();
    void requestQuit();

private:
#ifdef _WIN32
    void createMessageWindow();
    void destroyMessageWindow();

    HWND m_hwndMsg = nullptr;
    HICON m_hIcon = nullptr;
#endif
    bool m_isAdded = false;
    QString m_lastToolTip = "YuYuInstaller";
};
