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
            spacing: 22

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
                    font.pixelSize: 13
                    font.family: Theme.fontFamily
                }
            }

            // ═══════════════════════════════════════════════════════════
            // UNIFIED HERO CARD: Cloudflare WARP Tunnel Controller
            // ═══════════════════════════════════════════════════════════
            Rectangle {
                width: parent.width
                implicitHeight: heroCol.implicitHeight + 40
                radius: Theme.radiusLg
                color: Theme.bgCard
                border.color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning)
                              ? Qt.alpha(Theme.accent, 0.45)
                              : Theme.borderDim
                border.width: 1

                Behavior on border.color { ColorAnimation { duration: 220 } }

                Column {
                    id: heroCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 20
                    spacing: 16

                    // Top Row: Pulsing LED + Title & Status + Action Button
                    Item {
                        width: parent.width
                        height: 48

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 14

                            // Pulsing Status Indicator
                            Item {
                                width: 36; height: 36
                                anchors.verticalCenter: parent.verticalCenter

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 34; height: 34; radius: 17
                                    color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning)
                                           ? "#10b981"
                                           : (typeof proxyManager !== "undefined" && proxyManager.autoConnecting ? "#eab308" : "#64748b")
                                    opacity: 0.16

                                    SequentialAnimation on scale {
                                        running: (typeof proxyManager !== "undefined" && (proxyManager.warpRunning || proxyManager.autoConnecting))
                                        loops: Animation.Infinite
                                        NumberAnimation { from: 0.88; to: 1.22; duration: 1200; easing.type: Easing.InOutQuad }
                                        NumberAnimation { from: 1.22; to: 0.88; duration: 1200; easing.type: Easing.InOutQuad }
                                    }
                                }

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 12; height: 12; radius: 6
                                    color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning)
                                           ? "#10b981"
                                           : (typeof proxyManager !== "undefined" && proxyManager.autoConnecting ? "#eab308" : "#64748b")
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4

                                Row {
                                    spacing: 10
                                    Text {
                                        text: I18n.language === "tr" ? "Cloudflare WARP (Uygulama İçi Tünel)" : "Cloudflare WARP (In-App Tunnel)"
                                        color: Theme.textPrimary
                                        font.pixelSize: 15
                                        font.family: Theme.fontFamily
                                        font.weight: Font.Bold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    // Subtle status pill
                                    Rectangle {
                                        height: 20
                                        width: warpBadgeTxt.implicitWidth + 14
                                        radius: 10
                                        color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning)
                                               ? Qt.alpha("#10b981", 0.14)
                                               : (typeof proxyManager !== "undefined" && proxyManager.autoConnecting) ? "#22eab308" : Theme.bgElevated
                                        border.color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning)
                                                      ? Qt.alpha("#10b981", 0.45)
                                                      : (typeof proxyManager !== "undefined" && proxyManager.autoConnecting) ? "#eab308" : Theme.borderDim
                                        border.width: 1
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            id: warpBadgeTxt
                                            anchors.centerIn: parent
                                            text: {
                                                if (typeof proxyManager === "undefined") return I18n.language === "tr" ? "Kapalı" : "Inactive"
                                                if (proxyManager.autoConnecting) return I18n.language === "tr" ? "Bağlanıyor..." : "Connecting..."
                                                if (proxyManager.warpRunning) return I18n.language === "tr" ? "Korumalı • Aktif" : "Protected • Active"
                                                return I18n.language === "tr" ? "Doğrudan Bağlantı" : "Direct Connection"
                                            }
                                            color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning)
                                                   ? "#10b981"
                                                   : (typeof proxyManager !== "undefined" && proxyManager.autoConnecting) ? "#eab308" : Theme.textSecondary
                                            font.pixelSize: 10
                                            font.family: Theme.fontFamily
                                            font.weight: Font.DemiBold
                                        }
                                    }
                                }

                                Text {
                                    text: {
                                        if (typeof proxyManager !== "undefined" && proxyManager.warpRunning) {
                                            return I18n.language === "tr"
                                                   ? "Yalnızca YuYuInstaller trafiği Cloudflare üzerinden şifreleniyor. Oyun ve diğer uygulamalar etkilenmez."
                                                   : "Only YuYuInstaller traffic is routed through Cloudflare. Games and other apps remain untouched."
                                        }
                                        if (typeof proxyManager !== "undefined" && !proxyManager.autoConnecting && proxyManager.autoStatusMessage.indexOf("engeli") !== -1) {
                                            return proxyManager.autoStatusMessage
                                        }
                                        return I18n.language === "tr"
                                               ? "Eduroam, üniversite ve yurt ağlarındaki engelleri sistem VPN'i kurmadan aşar."
                                               : "Bypasses campus, eduroam and dorm firewalls with zero system-wide network changes."
                                    }
                                    color: (typeof proxyManager !== "undefined" && !proxyManager.autoConnecting && proxyManager.autoStatusMessage.indexOf("engeli") !== -1)
                                           ? Theme.error
                                           : Theme.textSecondary
                                    font.pixelSize: 12
                                    font.family: Theme.fontFamily
                                }
                            }
                        }

                        // Action Button: Solid Cyan when disconnected, Ghost/Outline when connected (red only on hover)
                        Rectangle {
                            width: 132; height: 38
                            radius: Theme.radiusMd
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            readonly property bool isRunning: (typeof proxyManager !== "undefined" && proxyManager.warpRunning)
                            readonly property bool isConnecting: (typeof proxyManager !== "undefined" && proxyManager.autoConnecting)

                            color: {
                                if (isConnecting) return Theme.bgElevated
                                if (isRunning) return warpBtnMouse.containsMouse ? Qt.alpha(Theme.error, 0.16) : "transparent"
                                return warpBtnMouse.containsMouse ? Theme.accentHover : Theme.accent
                            }
                            border.color: {
                                if (isConnecting) return Theme.borderDim
                                if (isRunning) return warpBtnMouse.containsMouse ? Theme.error : Theme.borderBright
                                return "transparent"
                            }
                            border.width: (isRunning || isConnecting) ? 1 : 0

                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: {
                                    if (typeof proxyManager === "undefined") return "Connect"
                                    if (proxyManager.autoConnecting) return I18n.language === "tr" ? "Bağlanıyor..." : "Connecting..."
                                    if (proxyManager.warpRunning) return I18n.language === "tr" ? "Tüneli Kapat" : "Disconnect"
                                    return I18n.language === "tr" ? "Tüneli Başlat" : "Connect Tunnel"
                                }
                                color: {
                                    if (parent.isConnecting) return Theme.textSecondary
                                    if (parent.isRunning) return warpBtnMouse.containsMouse ? Theme.error : Theme.textPrimary
                                    return "#070a12"
                                }
                                font.pixelSize: 12
                                font.family: Theme.fontFamily
                                font.weight: Font.DemiBold
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

                    // Divider line
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.borderDim
                    }

                    // 4-Column Telemetry Strip (Always visible, clean single source of truth)
                    Row {
                        width: parent.width
                        spacing: 12

                        // Col 1: Protocol
                        Column {
                            width: (parent.width - 36) / 4
                            spacing: 3
                            Text {
                                text: I18n.language === "tr" ? "PROTOKOL" : "PROTOCOL"
                                color: Theme.textMuted
                                font.pixelSize: 10
                                font.family: Theme.fontFamily
                                font.weight: Font.Bold
                                font.letterSpacing: 0.5
                            }
                            Text {
                                text: (typeof proxyManager !== "undefined" && (proxyManager.warpRunning || proxyManager.autoConnecting))
                                      ? "MASQUE / TLS 443"
                                      : (I18n.language === "tr" ? "Doğrudan (HTTPS)" : "Direct (HTTPS)")
                                color: Theme.textPrimary
                                font.pixelSize: 12
                                font.family: Theme.fontFamily
                                font.weight: Font.DemiBold
                            }
                        }

                        // Col 2: Local Endpoint
                        Column {
                            width: (parent.width - 36) / 4
                            spacing: 3
                            Text {
                                text: I18n.language === "tr" ? "YEREL TÜNEL" : "LOCAL ENDPOINT"
                                color: Theme.textMuted
                                font.pixelSize: 10
                                font.family: Theme.fontFamily
                                font.weight: Font.Bold
                                font.letterSpacing: 0.5
                            }
                            Text {
                                text: (typeof proxyManager !== "undefined" && proxyManager.warpRunning)
                                      ? "127.0.0.1:40000"
                                      : "—"
                                color: Theme.textPrimary
                                font.pixelSize: 12
                                font.family: Theme.fontFamily
                                font.weight: Font.DemiBold
                            }
                        }

                        // Col 3: Exit IP
                        Column {
                            width: (parent.width - 36) / 4
                            spacing: 3
                            Text {
                                text: I18n.language === "tr" ? "ÇIKIŞ IP ADRESİ" : "EXIT IP ADDRESS"
                                color: Theme.textMuted
                                font.pixelSize: 10
                                font.family: Theme.fontFamily
                                font.weight: Font.Bold
                                font.letterSpacing: 0.5
                            }
                            Text {
                                text: {
                                    if (typeof proxyManager !== "undefined" && proxyManager.warpRunning) {
                                        return (proxyManager.autoExitIp !== "") ? proxyManager.autoExitIp : "Cloudflare Edge"
                                    }
                                    return I18n.language === "tr" ? "Standart ISP" : "Standard ISP"
                                }
                                color: (typeof proxyManager !== "undefined" && proxyManager.warpRunning) ? Theme.accent : Theme.textSecondary
                                font.pixelSize: 12
                                font.family: Theme.fontFamily
                                font.weight: Font.DemiBold
                            }
                        }

                        // Col 4: Scope
                        Column {
                            width: (parent.width - 36) / 4
                            spacing: 3
                            Text {
                                text: I18n.language === "tr" ? "KAPSAM" : "ISOLATION SCOPE"
                                color: Theme.textMuted
                                font.pixelSize: 10
                                font.family: Theme.fontFamily
                                font.weight: Font.Bold
                                font.letterSpacing: 0.5
                            }
                            Text {
                                text: I18n.language === "tr" ? "Yalnızca Uygulama" : "App-Only (Isolated)"
                                color: Theme.textPrimary
                                font.pixelSize: 12
                                font.family: Theme.fontFamily
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }
            }

            // ═══════════════════════════════════════════════════════════
            // 3-COLUMN COMPACT FEATURE HIGHLIGHTS
            // ═══════════════════════════════════════════════════════════
            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: I18n.language === "tr" ? "TÜNEL MİMARİSİ" : (I18n.language === "uk" ? "АРХІТЕКТУРА ТУНЕЛЮ" : "TUNNEL ARCHITECTURE")
                    color: Theme.textSecondary
                    font.pixelSize: 11
                    font.family: Theme.fontFamily
                    font.weight: Font.Bold
                    font.letterSpacing: 0.8
                }

                Row {
                    width: parent.width
                    spacing: 12

                    // Feature Card 1: Campus & Eduroam
                    Rectangle {
                        width: (parent.width - 24) / 3
                        height: 138
                        radius: Theme.radiusLg
                        color: Theme.bgCard
                        border.color: Theme.borderDim
                        border.width: 1

                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 10

                            Rectangle {
                                width: 32; height: 32; radius: 8
                                color: Theme.bgElevated
                                border.color: Theme.borderDim
                                border.width: 1

                                Canvas {
                                    anchors.centerIn: parent
                                    width: 16; height: 16
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.reset();
                                        ctx.strokeStyle = Theme.accent;
                                        ctx.fillStyle = Theme.accent;
                                        ctx.lineWidth = 1.6;
                                        ctx.lineCap = "round";
                                        var radii = [3, 6.2, 9.4];
                                        for (var i = 0; i < radii.length; i++) {
                                            ctx.beginPath();
                                            ctx.arc(8, 13.5, radii[i], Math.PI * 1.25, Math.PI * 1.75);
                                            ctx.stroke();
                                        }
                                        ctx.beginPath();
                                        ctx.arc(8, 13.5, 1.3, 0, Math.PI * 2);
                                        ctx.fill();
                                    }
                                }
                            }

                            Text {
                                text: I18n.language === "tr" ? "Eduroam & Yurt Uyumlu" : "Eduroam & Campus Ready"
                                color: Theme.textPrimary
                                font.pixelSize: 13
                                font.family: Theme.fontFamily
                                font.weight: Font.DemiBold
                                width: parent.width
                                elide: Text.ElideRight
                            }

                            Text {
                                text: I18n.language === "tr"
                                      ? "UDP engelleyen güvenlik duvarlarını standart HTTPS (TCP 443) üzerinden aşar."
                                      : "Uses standard HTTPS (TCP 443) to bypass firewalls that block UDP packets."
                                color: Theme.textSecondary
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                                wrapMode: Text.WordWrap
                                width: parent.width
                                lineHeight: 1.25
                            }
                        }
                    }

                    // Feature Card 2: App-Isolated
                    Rectangle {
                        width: (parent.width - 24) / 3
                        height: 138
                        radius: Theme.radiusLg
                        color: Theme.bgCard
                        border.color: Theme.borderDim
                        border.width: 1

                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 10

                            Rectangle {
                                width: 32; height: 32; radius: 8
                                color: Theme.bgElevated
                                border.color: Theme.borderDim
                                border.width: 1

                                Canvas {
                                    anchors.centerIn: parent
                                    width: 16; height: 16
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.reset();
                                        ctx.strokeStyle = Theme.accent;
                                        ctx.lineWidth = 1.6;
                                        ctx.lineCap = "round";
                                        ctx.lineJoin = "round";
                                        ctx.strokeRect(1.5, 2.5, 13, 8.5);
                                        ctx.beginPath();
                                        ctx.moveTo(8, 11); ctx.lineTo(8, 14);
                                        ctx.moveTo(5, 14); ctx.lineTo(11, 14);
                                        ctx.stroke();
                                    }
                                }
                            }

                            Text {
                                text: I18n.language === "tr" ? "%100 Uygulama İçi İzole" : "100% App-Isolated"
                                color: Theme.textPrimary
                                font.pixelSize: 13
                                font.family: Theme.fontFamily
                                font.weight: Font.DemiBold
                                width: parent.width
                                elide: Text.ElideRight
                            }

                            Text {
                                text: I18n.language === "tr"
                                      ? "Oyun pinginizi, Discord veya tarayıcı trafiğinizi kesinlikle etkilemez."
                                      : "Never touches system network settings, game ping, or other running apps."
                                color: Theme.textSecondary
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                                wrapMode: Text.WordWrap
                                width: parent.width
                                lineHeight: 1.25
                            }
                        }
                    }

                    // Feature Card 3: Zero Setup
                    Rectangle {
                        width: (parent.width - 24) / 3
                        height: 138
                        radius: Theme.radiusLg
                        color: Theme.bgCard
                        border.color: Theme.borderDim
                        border.width: 1

                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 10

                            Rectangle {
                                width: 32; height: 32; radius: 8
                                color: Theme.bgElevated
                                border.color: Theme.borderDim
                                border.width: 1

                                Canvas {
                                    anchors.centerIn: parent
                                    width: 16; height: 16
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.reset();
                                        ctx.strokeStyle = Theme.accent;
                                        ctx.lineWidth = 1.6;
                                        ctx.lineCap = "round";
                                        ctx.lineJoin = "round";
                                        ctx.beginPath();
                                        ctx.moveTo(9.5, 1.5);
                                        ctx.lineTo(3.5, 9);
                                        ctx.lineTo(7.5, 9);
                                        ctx.lineTo(6.5, 14.5);
                                        ctx.lineTo(12.5, 7);
                                        ctx.lineTo(8.5, 7);
                                        ctx.closePath();
                                        ctx.stroke();
                                    }
                                }
                            }

                            Text {
                                text: I18n.language === "tr" ? "Sıfır Sürücü & Tam Hız" : "Zero Drivers & Full Speed"
                                color: Theme.textPrimary
                                font.pixelSize: 13
                                font.family: Theme.fontFamily
                                font.weight: Font.DemiBold
                                width: parent.width
                                elide: Text.ElideRight
                            }

                            Text {
                                text: I18n.language === "tr"
                                      ? "Sanal ağ adaptörü veya yönetici izni gerekmez; Cloudflare Anycast hızı."
                                      : "No TAP adapter or admin rights required; powered by Cloudflare Anycast."
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
