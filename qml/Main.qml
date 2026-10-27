import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import YuYuInstaller

ApplicationWindow {
    id: window
    width: 1060
    height: 700
    minimumWidth: 840
    minimumHeight: 560
    visible: true
    title: I18n.t("appName") + " - " + I18n.t("appSubtitle")
    flags: Qt.Window | Qt.FramelessWindowHint
    color: "#0a0d13"

    // Base dark fallback
    Rectangle {
        anchors.fill: parent
        color: "#0a0d13"
    }

    // Looping Video Background Layer (Direct Hardware Accelerated)
    VideoBackground {
        id: bgVideo
        anchors.fill: parent
        source: "assets/bg.mp4"
        playing: window.active && downloadManager.videoBackgroundEnabled
        targetFps: 45
    }

    // Hafif karartma: videonun görünmesi için düşük tutuldu
    Rectangle {
        anchors.fill: parent
        color: "#070a12"
        opacity: 0.15
    }

    // Subtle ambient gradient background glow
    Rectangle {
        width: 420
        height: 420
        radius: 210
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: -120
        opacity: 0.08
        color: Theme.accentBlue
    }

    Rectangle {
        width: 380
        height: 380
        radius: 190
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: -100
        opacity: 0.06
        color: Theme.accent
    }

    // ═══════════════════════════════════════════════════════════════
    // Custom Glass Title Bar (Frameless Seamless Window Header)
    // ═══════════════════════════════════════════════════════════════
    Rectangle {
        id: customTitleBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 32
        z: 1000
        color: "#33080b12"

        // Native window drag & double-click maximize
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onPressed: {
                if (mouse.button === Qt.LeftButton) {
                    window.startSystemMove();
                }
            }
            onDoubleClicked: {
                if (window.visibility === Window.Maximized) {
                    window.showNormal();
                } else {
                    window.showMaximized();
                }
            }
        }

        // Center Subtle Title
        Text {
            anchors.centerIn: parent
            text: I18n.t("appName") + " - " + I18n.t("appSubtitle")
            color: Theme.textMuted
            font.pixelSize: 11
            font.family: Theme.fontFamily
        }

        // Right Window Controls (Minimize, Maximize / Restore, Close)
        Row {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            spacing: 0

            // Minimize
            Rectangle {
                width: 46
                height: parent.height
                color: minBtnMa.containsMouse ? "#20ffffff" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "—"
                    color: minBtnMa.containsMouse ? "#ffffff" : Theme.textSecondary
                    font.pixelSize: 10
                    font.family: "Segoe UI"
                }

                MouseArea {
                    id: minBtnMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: window.showMinimized()
                }
            }

            // Maximize / Restore
            Rectangle {
                width: 46
                height: parent.height
                color: maxBtnMa.containsMouse ? "#20ffffff" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: window.visibility === Window.Maximized ? "❐" : "▢"
                    color: maxBtnMa.containsMouse ? "#ffffff" : Theme.textSecondary
                    font.pixelSize: 12
                    font.family: "Segoe UI"
                }

                MouseArea {
                    id: maxBtnMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (window.visibility === Window.Maximized) {
                            window.showNormal();
                        } else {
                            window.showMaximized();
                        }
                    }
                }
            }

            // Close
            Rectangle {
                width: 46
                height: parent.height
                color: closeBtnMa.containsMouse ? "#e81123" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: closeBtnMa.containsMouse ? "#ffffff" : Theme.textSecondary
                    font.pixelSize: 11
                    font.family: "Segoe UI"
                }

                MouseArea {
                    id: closeBtnMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: window.close()
                }
            }
        }

        // Bottom frosted divider line
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Theme.borderDim
        }
    }

    Row {
        anchors.top: customTitleBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        // Sidebar
        Sidebar {
            id: sidebarNav
            height: parent.height
            width: 220
        }

        // Main View Stack
        Item {
            width: parent.width - sidebarNav.width
            height: parent.height

            StackLayout {
                anchors.fill: parent
                currentIndex: sidebarNav.activeTab

                DashboardView {
                    id: dashboardView
                    onNavigateToQueue: sidebarNav.activeTab = 1
                }

                QueueView {
                    id: queueView
                }

                UpdatesView {
                    id: updatesView
                }

                ProxyView {
                    id: proxyView
                }

                SettingsView {
                    id: settingsView
                }
            }
        }
    }

    // Floating Update Notification Card (HUD Toast with Live Download Progress)
    Rectangle {
        id: updateBanner
        property bool dismissed: false
        readonly property bool isDownloading: (typeof updateManager !== "undefined" && updateManager.downloading)
        visible: !dismissed && (typeof updateManager !== "undefined" && (updateManager.updateAvailable || isDownloading) && sidebarNav.activeTab !== 2)

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 20
        width: 330
        implicitHeight: bannerCol.implicitHeight + 24
        radius: Theme.radiusLg
        color: "#cc111827"
        border.color: isDownloading ? Theme.accent : Theme.borderBright
        border.width: 1

        Behavior on border.color { ColorAnimation { duration: 200 } }

        Column {
            id: bannerCol
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            // Header Row: Pulsing LED, Title, and Clean Vector Close Button
            Item {
                width: parent.width
                height: 20

                Row {
                    anchors.left: parent.left
                    anchors.right: closeBtnItem.left
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    // Pulsing Status Dot
                    Item {
                        width: 10; height: 10
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            anchors.centerIn: parent
                            width: 10; height: 10; radius: 5
                            color: Theme.accent
                            opacity: 0.35
                            SequentialAnimation on scale {
                                running: updateBanner.visible
                                loops: Animation.Infinite
                                NumberAnimation { from: 0.8; to: 1.4; duration: 1000; easing.type: Easing.InOutQuad }
                                NumberAnimation { from: 1.4; to: 0.8; duration: 1000; easing.type: Easing.InOutQuad }
                            }
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 6; height: 6; radius: 3
                            color: Theme.accent
                        }
                    }

                    Text {
                        text: (typeof updateManager !== "undefined" && updateManager.latestVersion) ? I18n.t("updateBannerTitle").arg(updateManager.latestVersion) : ""
                        color: Theme.textPrimary
                        font.pixelSize: 12
                        font.family: Theme.fontFamily
                        font.weight: Font.Bold
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                        width: parent.width - 18
                    }
                }

                // Clean Vector Close Button (No emoji)
                Item {
                    id: closeBtnItem
                    width: 20; height: 20
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        color: closeBannerMouse.containsMouse ? Theme.bgCardHover : "transparent"
                    }

                    Canvas {
                        id: closeCanvas
                        anchors.centerIn: parent
                        width: 10; height: 10
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            ctx.strokeStyle = closeBannerMouse.containsMouse ? Theme.textPrimary : Theme.textMuted;
                            ctx.lineWidth = 1.5;
                            ctx.lineCap = "round";
                            ctx.beginPath();
                            ctx.moveTo(1.5, 1.5); ctx.lineTo(8.5, 8.5);
                            ctx.moveTo(8.5, 1.5); ctx.lineTo(1.5, 8.5);
                            ctx.stroke();
                        }
                    }

                    MouseArea {
                        id: closeBannerMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onContainsMouseChanged: closeCanvas.requestPaint()
                        onClicked: updateBanner.dismissed = true
                    }
                }
            }

            // State A: Download in Progress with Live Bar
            Column {
                width: parent.width
                spacing: 6
                visible: updateBanner.isDownloading

                Item {
                    width: parent.width
                    height: 16

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: I18n.t("downloadingUpdate")
                        color: Theme.accent
                        font.pixelSize: 11
                        font.family: Theme.fontFamily
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: (typeof updateManager !== "undefined") ? (updateManager.downloadProgress + "%") : "0%"
                        color: Theme.textPrimary
                        font.pixelSize: 11
                        font.family: Theme.fontFamily
                        font.weight: Font.Bold
                    }
                }

                // Progress Bar
                Rectangle {
                    width: parent.width
                    height: 6
                    radius: 3
                    color: Theme.bgInput
                    clip: true

                    Rectangle {
                        height: parent.height
                        width: (typeof updateManager !== "undefined") ? (parent.width * (updateManager.downloadProgress / 100.0)) : 0
                        radius: 3
                        color: Theme.accent

                        Behavior on width { NumberAnimation { duration: 150 } }
                    }
                }
            }

            // State B: Idle / Ready to Update
            Item {
                width: parent.width
                height: 28
                visible: !updateBanner.isDownloading

                Text {
                    anchors.left: parent.left
                    anchors.right: updateBtnRect.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: (typeof updateManager !== "undefined" && updateManager.statusMessage) ? updateManager.statusMessage : ""
                    color: Theme.textSecondary
                    font.pixelSize: 11
                    font.family: Theme.fontFamily
                    elide: Text.ElideRight
                }

                // Update Now Action Button
                Rectangle {
                    id: updateBtnRect
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: updateBtnText.implicitWidth + 24
                    height: 28
                    radius: 6
                    color: updateBtnMouse.containsMouse ? Theme.accentHover : Theme.accent

                    Behavior on color { ColorAnimation { duration: 150 } }

                    MouseArea {
                        id: updateBtnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (typeof updateManager !== "undefined") {
                                updateManager.startDownloadAndInstall()
                            }
                        }
                    }

                    Text {
                        id: updateBtnText
                        anchors.centerIn: parent
                        text: I18n.t("updateBannerAction")
                        color: "#07090e"
                        font.pixelSize: 11
                        font.family: Theme.fontFamily
                        font.weight: Font.Bold
                    }
                }
            }
        }
    }

    // Outer window border (when not maximized)
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: Theme.borderDim
        border.width: window.visibility === Window.Maximized ? 0 : 1
        z: 9999
        enabled: false
    }

    // Resize handles for frameless window
    Item {
        id: resizeHandles
        anchors.fill: parent
        enabled: window.visibility !== Window.Maximized
        z: 2000

        // Left
        MouseArea {
            anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
            anchors.topMargin: 8; anchors.bottomMargin: 8; width: 6
            cursorShape: Qt.SizeHorCursor
            onPressed: window.startSystemResize(Qt.LeftEdge)
        }
        // Right
        MouseArea {
            anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: parent.bottom
            anchors.topMargin: 8; anchors.bottomMargin: 8; width: 6
            cursorShape: Qt.SizeHorCursor
            onPressed: window.startSystemResize(Qt.RightEdge)
        }
        // Top
        MouseArea {
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
            anchors.leftMargin: 8; anchors.rightMargin: 8; height: 4
            cursorShape: Qt.SizeVerCursor
            onPressed: window.startSystemResize(Qt.TopEdge)
        }
        // Bottom
        MouseArea {
            anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
            anchors.leftMargin: 8; anchors.rightMargin: 8; height: 6
            cursorShape: Qt.SizeVerCursor
            onPressed: window.startSystemResize(Qt.BottomEdge)
        }
        // Corners
        MouseArea {
            anchors.top: parent.top; anchors.left: parent.left; width: 8; height: 8
            cursorShape: Qt.SizeFDiagCursor
            onPressed: window.startSystemResize(Qt.TopEdge | Qt.LeftEdge)
        }
        MouseArea {
            anchors.top: parent.top; anchors.right: parent.right; width: 8; height: 8
            cursorShape: Qt.SizeBDiagCursor
            onPressed: window.startSystemResize(Qt.TopEdge | Qt.RightEdge)
        }
        MouseArea {
            anchors.bottom: parent.bottom; anchors.left: parent.left; width: 8; height: 8
            cursorShape: Qt.SizeBDiagCursor
            onPressed: window.startSystemResize(Qt.BottomEdge | Qt.LeftEdge)
        }
        MouseArea {
            anchors.bottom: parent.bottom; anchors.right: parent.right; width: 8; height: 8
            cursorShape: Qt.SizeFDiagCursor
            onPressed: window.startSystemResize(Qt.BottomEdge | Qt.RightEdge)
        }
    }
}
