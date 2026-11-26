import QtQuick
import QtQuick.Controls
import YuYuInstaller

Item {
    id: root

    Flickable {
        anchors.fill: parent
        anchors.margins: 28
        contentHeight: contentCol.height + 40
        clip: true

        Column {
            id: contentCol
            width: Math.min(parent.width, 760)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            // Header Section
            Column {
                spacing: 4
                Text {
                    text: I18n.t("proxyTitle")
                    color: Theme.textPrimary
                    font.pixelSize: 22
                    font.family: Theme.fontFamily
                    font.weight: Font.Bold
                }
                Text {
                    text: I18n.language === "tr"
                          ? "Cloudflare WARP tüneli ile okul, yurt ve eduroam engellerini aşın, indirmelerinizi güvenceye alın."
                          : (I18n.language === "uk"
                             ? "Обходьте блокування в мережах eduroam, університетах та гуртожитках за допомогою Cloudflare WARP."
                             : "Bypass campus, dorm and eduroam firewalls securely with Cloudflare WARP in-app tunnel.")
                    color: Theme.textSecondary
                    font.pixelSize: 12
                    font.family: Theme.fontFamily
                }
            }

            // Card 1: Master Status & Quick Switch
            Rectangle {
                width: parent.width
                implicitHeight: statusCol.implicitHeight + 32
                radius: Theme.radiusLg
                color: Theme.bgCard
                border.color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning) ? Theme.accent : Theme.borderDim
                border.width: 1

                Behavior on border.color { ColorAnimation { duration: 250 } }

                Column {
                    id: statusCol
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Item {
                        width: parent.width
                        height: 38

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 12

                            // Pulsing status LED
                            Item {
                                width: 28; height: 28
                                anchors.verticalCenter: parent.verticalCenter

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 26; height: 26; radius: 13
                                    color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning)
                                           ? Theme.accent
                                           : (typeof proxyManager !== "undefined" && proxyManager.autoConnecting ? "#eab308" : "#64748b")
                                    opacity: 0.18

                                    SequentialAnimation on scale {
                                        running: (typeof proxyManager !== "undefined" && (proxyManager.warpRunning || proxyManager.autoConnecting))
                                        loops: Animation.Infinite
                                        NumberAnimation { from: 0.9; to: 1.28; duration: 1200; easing.type: Easing.InOutQuad }
                                        NumberAnimation { from: 1.28; to: 0.9; duration: 1200; easing.type: Easing.InOutQuad }
                                    }
                                }

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 12; height: 12; radius: 6
                                    color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning)
                                           ? Theme.accent
                                           : (typeof proxyManager !== "undefined" && proxyManager.autoConnecting ? "#eab308" : "#64748b")
                                }
                            }

                            // Status Info
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2

                                Text {
                                    text: I18n.language === "tr" ? "Tünel Bağlantı Durumu" : (I18n.language === "uk" ? "Статус тунелю" : "Tunnel Connection Status")
                                    color: Theme.textSecondary
                                    font.pixelSize: 10
                                    font.family: Theme.fontFamily
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    text: {
                                        if (typeof proxyManager === "undefined") return "Tünel Kapalı"
                                        if (proxyManager.autoConnecting) return I18n.language === "tr" ? "Cloudflare Ağına Bağlanılıyor..." : "Connecting to Cloudflare Network..."
                                        if (proxyManager.warpRunning) return I18n.language === "tr" ? "Cloudflare WARP Aktif (Korumalı)" : "Cloudflare WARP Active (Protected)"
                                        return I18n.language === "tr" ? "Doğrudan Bağlantı (Tünel Kapalı)" : "Direct Connection (Tunnel Inactive)"
                                    }
                                    color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning)
                                           ? Theme.accent
                                           : (typeof proxyManager !== "undefined" && proxyManager.autoConnecting ? "#eab308" : Theme.textPrimary)
                                    font.pixelSize: 13
                                    font.family: Theme.fontFamily
                                    font.weight: Font.Bold
                                }
                            }
                        }

                        // Animated Master Toggle Switch
                        Item {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            width: 50; height: 26

                            Rectangle {
                                anchors.fill: parent
                                radius: 13
                                color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning) ? Theme.accent : "#222c3c"
                                border.color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning) ? Theme.accent : Theme.borderDim
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 200 } }

                                Rectangle {
                                    width: 20; height: 20; radius: 10
                                    color: "#ffffff"
                                    y: 3
                                    x: (typeof proxyManager !== "undefined" && proxyManager.warpRunning) ? 27 : 3

                                    Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: (typeof proxyManager !== "undefined" && proxyManager.autoConnecting) ? Qt.ArrowCursor : Qt.PointingHandCursor
                                    enabled: typeof proxyManager !== "undefined" && !proxyManager.autoConnecting
                                    onClicked: {
                                        if (typeof proxyManager !== "undefined") {
                                            proxyManager.toggleWarpTunnel()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Active Protocol Summary Bar
                    Rectangle {
                        width: parent.width
                        height: 30
                        radius: Theme.radiusMd
                        color: Theme.bgElevated
                        border.color: Theme.borderDim
                        border.width: 1

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 10

                            Text {
                                text: {
                                    if (typeof proxyManager === "undefined" || !proxyManager.warpRunning) {
                                        if (typeof proxyManager !== "undefined" && proxyManager.autoConnecting) {
                                            return "Cloudflare WARP (MASQUE / TCP 443): " + proxyManager.autoStatusMessage
                                        }
                                        return I18n.language === "tr" ? "Doğrudan bağlantı aktif (Proxy kapalı)" : "Direct connection active (Proxy inactive)"
                                    }
                                    var ipPart = (proxyManager.autoExitIp !== "") ? (" • Çıkış IP: " + proxyManager.autoExitIp) : ""
                                    return "Cloudflare WARP: " + proxyManager.autoLocation + ipPart + " (127.0.0.1:40000)"
                                }
                                color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning) ? Theme.accent : Theme.textSecondary
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }

            // Card 2: Main Cloudflare WARP Controller Card
            Rectangle {
                width: parent.width
                implicitHeight: warpCol.implicitHeight + 32
                radius: Theme.radiusLg
                color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning) ? "#102334" : "#131b26"
                border.color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning) ? Theme.accent : (Theme.accent + "55")
                border.width: (typeof proxyManager !== "undefined" && proxyManager.warpRunning) ? 1.5 : 1

                Behavior on color { ColorAnimation { duration: 250 } }
                Behavior on border.color { ColorAnimation { duration: 250 } }

                Column {
                    id: warpCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 18
                    spacing: 16

                    // Header Row with Title, Badge, and Action Button
                    Row {
                        width: parent.width
                        spacing: 12

                        Column {
                            width: parent.width - 140
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 6

                            Row {
                                spacing: 8
                                Text {
                                    text: I18n.language === "tr" ? "Cloudflare WARP (Uygulama İçi Tünel)" : "Cloudflare WARP (In-App Tunnel)"
                                    color: Theme.textPrimary
                                    font.pixelSize: 14
                                    font.family: Theme.fontFamily
                                    font.weight: Font.Bold
                                }

                                Rectangle {
                                    height: 20
                                    width: warpBadgeTxt.implicitWidth + 12
                                    radius: 10
                                    color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning)
                                           ? Theme.accent + "22"
                                           : (typeof proxyManager !== "undefined" && proxyManager.autoConnecting) ? "#eab30822" : "#222c3c"
                                    border.color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning)
                                                  ? Theme.accent
                                                  : (typeof proxyManager !== "undefined" && proxyManager.autoConnecting) ? "#eab308" : Theme.borderDim
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        id: warpBadgeTxt
                                        anchors.centerIn: parent
                                        text: {
                                            if (typeof proxyManager === "undefined") return "Kapalı"
                                            if (proxyManager.autoConnecting) return I18n.language === "tr" ? "Bağlanıyor..." : "Connecting..."
                                            if (proxyManager.warpRunning) return "Aktif • 127.0.0.1:40000"
                                            return I18n.language === "tr" ? "Devre Dışı" : "Disabled"
                                        }
                                        color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning)
                                               ? Theme.accent
                                               : (typeof proxyManager !== "undefined" && proxyManager.autoConnecting) ? "#eab308" : Theme.textSecondary
                                        font.pixelSize: 10
                                        font.family: Theme.fontFamily
                                        font.weight: Font.DemiBold
                                    }
                                }
                            }

                            Text {
                                width: parent.width
                                text: {
                                    if (typeof proxyManager !== "undefined" && proxyManager.warpRunning) {
                                        return I18n.language === "tr"
                                               ? "Aktif: Yalnızca YuYuInstaller Cloudflare ağına tünellendi. Bilgisayarınızın geri kalanı, oyunlar veya diğer uygulamalar etkilenmez."
                                               : "Active: Only YuYuInstaller traffic is securely routed through Cloudflare. System, ping, and other apps are unaffected."
                                    }
                                    if (typeof proxyManager !== "undefined" && !proxyManager.autoConnecting && proxyManager.autoStatusMessage.indexOf("engeli") !== -1) {
                                        return proxyManager.autoStatusMessage
                                    }
                                    return I18n.language === "tr"
                                           ? "Eduroam, üniversite ve yurt ağlarındaki engelleri aşar. Sisteme harici VPN kurmaz, doğrudan uygulama içinde çalışır."
                                           : "Bypasses campus, eduroam and dorm firewalls. Runs strictly inside the application with zero system-wide network changes."
                                }
                                color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning)
                                       ? Theme.accent
                                       : ((typeof proxyManager !== "undefined" && proxyManager.autoStatusMessage.indexOf("engeli") !== -1) ? "#f87171" : Theme.textSecondary)
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                                wrapMode: Text.WordWrap
                                lineHeight: 1.3
                            }
                        }

                        // Toggle Action Button
                        Rectangle {
                            width: 128; height: 38
                            radius: Theme.radiusMd
                            anchors.verticalCenter: parent.verticalCenter
                            color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning)
                                   ? (warpBtnMouse.containsMouse ? "#dc2626" : Theme.error)
                                   : ((typeof proxyManager !== "undefined" && proxyManager.autoConnecting)
                                      ? "#334155"
                                      : (warpBtnMouse.containsMouse ? "#00e5ab" : Theme.accent))

                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: {
                                    if (typeof proxyManager === "undefined") return "Aç"
                                    if (proxyManager.autoConnecting) return I18n.language === "tr" ? "Bağlanıyor..." : "Connecting..."
                                    if (proxyManager.warpRunning) return I18n.language === "tr" ? "Tüneli Kapat" : "Disconnect"
                                    return I18n.language === "tr" ? "Tüneli Başlat" : "Connect Tunnel"
                                }
                                color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning)
                                       ? "#ffffff"
                                       : ((typeof proxyManager !== "undefined" && proxyManager.autoConnecting) ? "#94a3b8" : "#070a12")
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                                font.weight: Font.Bold
                            }

                            MouseArea {
                                id: warpBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: (typeof proxyManager !== "undefined" && proxyManager.autoConnecting) ? Qt.ArrowCursor : Qt.PointingHandCursor
                                enabled: typeof proxyManager !== "undefined" && !proxyManager.autoConnecting
                                onClicked: {
                                    if (typeof proxyManager !== "undefined") {
                                        proxyManager.toggleWarpTunnel()
                                    }
                                }
                            }
                        }
                    }

                    // Live Diagnostics / Network Details Box (Shown when active)
                    Rectangle {
                        visible: typeof proxyManager !== "undefined" && (proxyManager.warpRunning || proxyManager.autoConnecting)
                        width: parent.width
                        implicitHeight: detailsGrid.implicitHeight + 20
                        radius: Theme.radiusMd
                        color: Theme.bgElevated
                        border.color: Theme.borderDim
                        border.width: 1

                        Grid {
                            id: detailsGrid
                            anchors.fill: parent
                            anchors.margins: 12
                            columns: 2
                            rowSpacing: 10
                            columnSpacing: 16

                            // Detail 1: Node / Protocol
                            Column {
                                width: (detailsGrid.width - 16) * 0.5
                                spacing: 2
                                Text {
                                    text: I18n.language === "tr" ? "Protokol & Port" : "Protocol & Port"
                                    color: Theme.textSecondary
                                    font.pixelSize: 10
                                    font.family: Theme.fontFamily
                                }
                                Text {
                                    text: "MASQUE / HTTP/2 (TCP 443 TLS)"
                                    color: Theme.textPrimary
                                    font.pixelSize: 11
                                    font.family: Theme.fontFamily
                                    font.weight: Font.Bold
                                }
                            }

                            // Detail 2: Exit IP
                            Column {
                                width: (detailsGrid.width - 16) * 0.5
                                spacing: 2
                                Text {
                                    text: I18n.language === "tr" ? "Çıkış IP Adresi" : "Exit IP Address"
                                    color: Theme.textSecondary
                                    font.pixelSize: 10
                                    font.family: Theme.fontFamily
                                }
                                Text {
                                    text: (typeof proxyManager !== "undefined" && proxyManager.autoExitIp !== "")
                                          ? proxyManager.autoExitIp
                                          : (I18n.language === "tr" ? "Cloudflare Edge Ağı" : "Cloudflare Edge Network")
                                    color: Theme.accent
                                    font.pixelSize: 11
                                    font.family: Theme.fontFamily
                                    font.weight: Font.Bold
                                }
                            }

                            // Detail 3: Location
                            Column {
                                width: (detailsGrid.width - 16) * 0.5
                                spacing: 2
                                Text {
                                    text: I18n.language === "tr" ? "Tünel Tipi" : "Tunnel Type"
                                    color: Theme.textSecondary
                                    font.pixelSize: 10
                                    font.family: Theme.fontFamily
                                }
                                Text {
                                    text: (typeof proxyManager !== "undefined" && proxyManager.autoLocation !== "")
                                          ? proxyManager.autoLocation
                                          : "Cloudflare WARP (Yerel SOCKS5)"
                                    color: Theme.textPrimary
                                    font.pixelSize: 11
                                    font.family: Theme.fontFamily
                                    font.weight: Font.Bold
                                }
                            }

                            // Detail 4: Status / Isolation
                            Column {
                                width: (detailsGrid.width - 16) * 0.5
                                spacing: 2
                                Text {
                                    text: I18n.language === "tr" ? "İzolasyon Seviyesi" : "Isolation Level"
                                    color: Theme.textSecondary
                                    font.pixelSize: 10
                                    font.family: Theme.fontFamily
                                }
                                Text {
                                    text: I18n.language === "tr" ? "100% İzole • Yalnızca YuYuInstaller" : "100% Isolated • YuYuInstaller Only"
                                    color: Theme.accent
                                    font.pixelSize: 11
                                    font.family: Theme.fontFamily
                                    font.weight: Font.Bold
                                }
                            }
                        }
                    }
                }
            }

            // Card 3: Feature Highlights
            Column {
                width: parent.width
                spacing: 10

                Text {
                    text: I18n.language === "tr" ? "WARP Tüneli Hakkında Bilgiler" : "About Cloudflare WARP Tunnel"
                    color: Theme.textPrimary
                    font.pixelSize: 13
                    font.family: Theme.fontFamily
                    font.weight: Font.Bold
                }

                // Feature 1
                Rectangle {
                    width: parent.width
                    implicitHeight: f1Row.implicitHeight + 20
                    radius: Theme.radiusMd
                    color: Theme.bgCard
                    border.color: Theme.borderDim
                    border.width: 1

                    Row {
                        id: f1Row
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Rectangle {
                            width: 32; height: 32; radius: 16
                            color: Theme.accent + "20"
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: "🎓"
                                font.pixelSize: 15
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 48
                            spacing: 3

                            Text {
                                text: I18n.language === "tr" ? "Eduroam & Üniversite / Yurt Ağları ile Tam Uyumlu" : "Fully Compatible with Eduroam & Campus Wi-Fi"
                                color: Theme.textPrimary
                                font.pixelSize: 12
                                font.family: Theme.fontFamily
                                font.weight: Font.Bold
                            }
                            Text {
                                text: I18n.language === "tr"
                                      ? "Standart WireGuard/UDP paketlerini engelleyen katı üniversite ve yurt güvenlik duvarlarında bile standart HTTPS (TCP 443) portunu kullanarak kesintisiz tünel oluşturur."
                                      : "Connects via standard HTTPS port (TCP 443) to overcome strict firewall restrictions that block traditional WireGuard UDP packets."
                                color: Theme.textSecondary
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                                wrapMode: Text.WordWrap
                                width: parent.width
                                lineHeight: 1.25
                            }
                        }
                    }
                }

                // Feature 2
                Rectangle {
                    width: parent.width
                    implicitHeight: f2Row.implicitHeight + 20
                    radius: Theme.radiusMd
                    color: Theme.bgCard
                    border.color: Theme.borderDim
                    border.width: 1

                    Row {
                        id: f2Row
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Rectangle {
                            width: 32; height: 32; radius: 16
                            color: Theme.accent + "20"
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: "⚡"
                                font.pixelSize: 15
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 48
                            spacing: 3

                            Text {
                                text: I18n.language === "tr" ? "Yalnızca Uygulama İçi (İzole Tünel)" : "App-Isolated (No System Lag or Ping Increase)"
                                color: Theme.textPrimary
                                font.pixelSize: 12
                                font.family: Theme.fontFamily
                                font.weight: Font.Bold
                            }
                            Text {
                                text: I18n.language === "tr"
                                      ? "Bilgisayarınızın genel internet bağlantısını, Discord, Spotify veya oyun pinglerinizi kesinlikle etkilemez. Sadece YuYuInstaller'ın indirmeleri tünellenir."
                                      : "Does not touch your system network settings, games or other apps. Only YuYuInstaller media downloads are tunneled."
                                color: Theme.textSecondary
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                                wrapMode: Text.WordWrap
                                width: parent.width
                                lineHeight: 1.25
                            }
                        }
                    }
                }

                // Feature 3
                Rectangle {
                    width: parent.width
                    implicitHeight: f3Row.implicitHeight + 20
                    radius: Theme.radiusMd
                    color: Theme.bgCard
                    border.color: Theme.borderDim
                    border.width: 1

                    Row {
                        id: f3Row
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Rectangle {
                            width: 32; height: 32; radius: 16
                            color: Theme.accent + "20"
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: "🔒"
                                font.pixelSize: 15
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 48
                            spacing: 3

                            Text {
                                text: I18n.language === "tr" ? "Sıfır Kurulum & Yüksek Hız" : "Zero Setup & Maximum Speed"
                                color: Theme.textPrimary
                                font.pixelSize: 12
                                font.family: Theme.fontFamily
                                font.weight: Font.Bold
                            }
                            Text {
                                text: I18n.language === "tr"
                                      ? "Harici sanal ağ kartı (TAP adaptörü) veya yönetici izni gerekmez. Cloudflare'ın küresel Anycast ağı ile en yüksek hızda indirme sağlar."
                                      : "No virtual network adapter drivers or administrative privileges needed. Backed by Cloudflare's global Anycast backbone."
                                color: Theme.textSecondary
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                                wrapMode: Text.WordWrap
                                width: parent.width
                                lineHeight: 1.25
                            }
                        }
                    }
                }
            }
        }
    }
}
