#include "TrayManager.h"
#include <QCoreApplication>
#include <QDir>

#ifdef _WIN32
#define WM_TRAY_NOTIFY (WM_USER + 200)
#define ID_TRAY_RESTORE 1001
#define ID_TRAY_QUIT 1002

static const wchar_t *TRAY_WINDOW_CLASS = L"YuYuInstallerTrayMsgClass";

static LRESULT CALLBACK TrayWndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    if (msg == WM_TRAY_NOTIFY) {
        TrayManager *mgr = reinterpret_cast<TrayManager*>(GetWindowLongPtrW(hwnd, GWLP_USERDATA));
        if (mgr) {
            mgr->handleTrayMessage(lParam);
            return 0;
        }
    }
    return DefWindowProcW(hwnd, msg, wParam, lParam);
}
#endif

TrayManager::TrayManager(QObject *parent)
    : QObject(parent)
{
}

TrayManager::~TrayManager() {
    hideTrayIcon();
#ifdef _WIN32
    destroyMessageWindow();
#endif
}

#ifdef _WIN32
void TrayManager::createMessageWindow() {
    if (m_hwndMsg) return;

    HINSTANCE hInst = GetModuleHandleW(nullptr);

    WNDCLASSEXW wc = {sizeof(WNDCLASSEXW)};
    wc.lpfnWndProc = TrayWndProc;
    wc.hInstance = hInst;
    wc.lpszClassName = TRAY_WINDOW_CLASS;
    RegisterClassExW(&wc);

    m_hwndMsg = CreateWindowExW(0, TRAY_WINDOW_CLASS, L"YuYuInstallerTrayMsg",
                                0, 0, 0, 0, 0,
                                HWND_MESSAGE, nullptr, hInst, nullptr);
    if (m_hwndMsg) {
        SetWindowLongPtrW(m_hwndMsg, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(this));
    }
}

void TrayManager::destroyMessageWindow() {
    if (m_hwndMsg) {
        DestroyWindow(m_hwndMsg);
        m_hwndMsg = nullptr;
    }
}
#endif

void TrayManager::showTrayIcon() {
    if (m_isAdded) return;

#ifdef _WIN32
    createMessageWindow();
    if (!m_hwndMsg) return;

    int cx = GetSystemMetrics(SM_CXSMICON);
    int cy = GetSystemMetrics(SM_CYSMICON);
    if (cx <= 0) cx = 16;
    if (cy <= 0) cy = 16;

    m_hIcon = (HICON)LoadImageW(GetModuleHandleW(nullptr), MAKEINTRESOURCEW(1), IMAGE_ICON, cx, cy, LR_DEFAULTCOLOR);
    if (!m_hIcon) {
        QString icoPath = QCoreApplication::applicationDirPath() + "/assets/app.ico";
        std::wstring wIco = QDir::toNativeSeparators(icoPath).toStdWString();
        m_hIcon = (HICON)LoadImageW(nullptr, wIco.c_str(), IMAGE_ICON, cx, cy, LR_LOADFROMFILE);
    }
    if (!m_hIcon) {
        m_hIcon = (HICON)LoadIconW(GetModuleHandleW(nullptr), MAKEINTRESOURCEW(1));
    }

    NOTIFYICONDATAW nid = {sizeof(NOTIFYICONDATAW)};
    nid.hWnd = m_hwndMsg;
    nid.uID = 1;
    nid.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;
    nid.uCallbackMessage = WM_TRAY_NOTIFY;
    nid.hIcon = m_hIcon;
    wcsncpy_s(nid.szTip, m_lastToolTip.toStdWString().c_str(), _TRUNCATE);

    if (Shell_NotifyIconW(NIM_ADD, &nid)) {
        m_isAdded = true;
        emit visibilityChanged();
    }
#else
    m_isAdded = true;
    emit visibilityChanged();
#endif
}

void TrayManager::hideTrayIcon() {
    if (!m_isAdded) return;

#ifdef _WIN32
    if (m_hwndMsg) {
        NOTIFYICONDATAW nid = {sizeof(NOTIFYICONDATAW)};
        nid.hWnd = m_hwndMsg;
        nid.uID = 1;
        Shell_NotifyIconW(NIM_DELETE, &nid);
    }
    if (m_hIcon) {
        DestroyIcon(m_hIcon);
        m_hIcon = nullptr;
    }
#endif

    m_isAdded = false;
    emit visibilityChanged();
}

void TrayManager::updateToolTip(const QString &tip) {
    m_lastToolTip = tip.trimmed().isEmpty() ? "YuYuInstaller" : tip.trimmed();

#ifdef _WIN32
    if (!m_isAdded || !m_hwndMsg) return;

    NOTIFYICONDATAW nid = {sizeof(NOTIFYICONDATAW)};
    nid.hWnd = m_hwndMsg;
    nid.uID = 1;
    nid.uFlags = NIF_TIP;
    wcsncpy_s(nid.szTip, m_lastToolTip.toStdWString().c_str(), _TRUNCATE);
    Shell_NotifyIconW(NIM_MODIFY, &nid);
#endif
}

void TrayManager::showNotification(const QString &title, const QString &message) {
    if (!m_isAdded) {
        showTrayIcon();
    }

#ifdef _WIN32
    if (!m_hwndMsg) return;

    NOTIFYICONDATAW nid = {sizeof(NOTIFYICONDATAW)};
    nid.hWnd = m_hwndMsg;
    nid.uID = 1;
    nid.uFlags = NIF_INFO;
    wcsncpy_s(nid.szInfoTitle, title.toStdWString().c_str(), _TRUNCATE);
    wcsncpy_s(nid.szInfo, message.toStdWString().c_str(), _TRUNCATE);
    nid.dwInfoFlags = NIIF_INFO;
    Shell_NotifyIconW(NIM_MODIFY, &nid);
#endif
}

#ifdef _WIN32
void TrayManager::handleTrayMessage(LPARAM lParam) {
    switch (lParam) {
    case WM_LBUTTONUP:
    case WM_LBUTTONDBLCLK:
        emit requestRestoreWindow();
        break;
    case WM_RBUTTONUP:
    case WM_CONTEXTMENU:
        showContextMenu();
        break;
    default:
        break;
    }
}

void TrayManager::showContextMenu() {
    if (!m_hwndMsg) return;

    POINT pt;
    GetCursorPos(&pt);

    HMENU hMenu = CreatePopupMenu();
    AppendMenuW(hMenu, MF_STRING, ID_TRAY_RESTORE, L"YuYuInstaller'ı Aç");
    AppendMenuW(hMenu, MF_SEPARATOR, 0, nullptr);
    AppendMenuW(hMenu, MF_STRING, ID_TRAY_QUIT, L"İndirmeleri Duraklat ve Çık");

    SetForegroundWindow(m_hwndMsg);

    int cmd = TrackPopupMenu(hMenu, TPM_RETURNCMD | TPM_RIGHTBUTTON | TPM_NONOTIFY,
                             pt.x, pt.y, 0, m_hwndMsg, nullptr);
    DestroyMenu(hMenu);

    if (cmd == ID_TRAY_RESTORE) {
        emit requestRestoreWindow();
    } else if (cmd == ID_TRAY_QUIT) {
        emit requestQuit();
    }
}
#endif
