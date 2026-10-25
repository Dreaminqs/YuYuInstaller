import QtQuick
import QtQuick.Controls
import MediaGrab

Item {
    id: root

    property int selectedMode: (typeof proxyManager !== "undefined") ? proxyManager.proxyMode : 0
    property string localHost: (typeof proxyManager !== "undefined") ? proxyManager.host : "127.0.0.1"
    property int localPort: (typeof proxyManager !== "undefined") ? proxyManager.port : 40000
    property string localUser: (typeof proxyManager !== "undefined") ? proxyManager.username : ""
    property string localPass: (typeof proxyManager !== "undefined") ? proxyManager.password : ""
    property bool showPassword: false
    property bool savedNotification: false
    property bool showModeInfo: false

    Timer {
        id: notificationTimer
        interval: 3000
        onTriggered: root.savedNotification = false
    }

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
                    text: I18n.t("proxySubtitle")
                    color: Theme.textSecondary
                    font.pixelSize: 12
                    font.family: Theme.fontFamily
                }
            }

            // Card 1: Live Status & Master Switch
            Rectangle {
                width: parent.width
                implicitHeight: statusCol.implicitHeight + 32
                radius: Theme.radiusLg
                color: Theme.bgCard
                border.color: (typeof proxyManager !== "undefined" && proxyManager.enabled) ? Theme.accent : Theme.borderDim
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
                                    color: (typeof proxyManager !== "undefined" && proxyManager.enabled) ? "#00d29d" : "#64748b"
                                    opacity: 0.15

                                    SequentialAnimation on scale {
                                        running: (typeof proxyManager !== "undefined" && proxyManager.enabled)
                                        loops: Animation.Infinite
                                        NumberAnimation { from: 0.9; to: 1.25; duration: 1200; easing.type: Easing.InOutQuad }
                                        NumberAnimation { from: 1.25; to: 0.9; duration: 1200; easing.type: Easing.InOutQuad }
                                    }
                                }

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 12; height: 12; radius: 6
                                    color: (typeof proxyManager !== "undefined" && proxyManager.enabled) ? "#00d29d" : "#64748b"
                                }
                            }

                            // Status Info
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2

                                Text {
                                    text: I18n.t("proxyStatusCardTitle")
                                    color: Theme.textSecondary
                                    font.pixelSize: 10
                                    font.family: Theme.fontFamily
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    text: (typeof proxyManager !== "undefined" && proxyManager.enabled)
                                          ? I18n.t("proxyStatusActive")
                                          : I18n.t("proxyStatusInactive")
                                    color: (typeof proxyManager !== "undefined" && proxyManager.enabled)
                                           ? "#00d29d"
                                           : Theme.textPrimary
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
                                color: (typeof proxyManager !== "undefined" && proxyManager.enabled) ? Theme.accent : "#222c3c"
                                border.color: (typeof proxyManager !== "undefined" && proxyManager.enabled) ? Theme.accent : Theme.borderDim
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 200 } }

                                Rectangle {
                                    width: 20; height: 20; radius: 10
                                    color: "#ffffff"
                                    y: 3
                                    x: (typeof proxyManager !== "undefined" && proxyManager.enabled) ? 27 : 3

                                    Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (typeof proxyManager !== "undefined") {
                                            proxyManager.enabled = !proxyManager.enabled
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
                                    if (typeof proxyManager === "undefined" || !proxyManager.enabled)
                                        return I18n.t("proxyStatusInactive")
                                    if (proxyManager.proxyMode === 0) {
                                        if (proxyManager.autoConnecting) return "In-App VPN: " + I18n.t("proxyAutoConnecting")
                                        if (proxyManager.autoConnected) {
                                            var ipPart = (proxyManager.autoExitIp !== "") ? (" • IP: " + proxyManager.autoExitIp) : ""
                                            return "In-App VPN: " + proxyManager.autoLocation + ipPart + " (" + proxyManager.autoLatency + " ms)"
                                        }
                                        return "In-App VPN: " + proxyManager.autoStatusMessage
                                    }
                                    if (proxyManager.proxyMode === 1)
                                        return "SOCKS5: " + proxyManager.host + ":" + proxyManager.port
                                    if (proxyManager.proxyMode === 2)
                                        return "HTTP: " + proxyManager.host + ":" + proxyManager.port
                                    return ""
                                }
                                color: Theme.textSecondary
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Item { width: 8; height: 1 }

                            // Latency Badge if test passed (Manual mode)
                            Rectangle {
                                visible: (typeof proxyManager !== "undefined" && proxyManager.proxyMode !== 0 && proxyManager.testStatus === 1)
                                height: 20
                                width: latencyTxt.implicitWidth + 12
                                radius: 10
                                color: "#143a2d"
                                border.color: "#00d29d"
                                border.width: 1
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    id: latencyTxt
                                    anchors.centerIn: parent
                                    text: (typeof proxyManager !== "undefined") ? proxyManager.testMessage : ""
                                    color: "#00d29d"
                                    font.pixelSize: 10
                                    font.family: Theme.fontFamily
                                    font.weight: Font.DemiBold
                                }
                            }
                        }
                    }
                }
            }

            // Card 2: Tunnel Mode Selection (Auto VPN, SOCKS5, HTTP)
            Rectangle {
                width: parent.width
                implicitHeight: modeCol.implicitHeight + 32
                radius: Theme.radiusLg
                color: Theme.bgCard
                border.color: Theme.borderDim
                border.width: 1

                Column {
                    id: modeCol
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    // Header Row with Title and Info (i) Button
                    Item {
                        width: parent.width
                        height: 24

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: I18n.t("proxyModeTitle")
                            color: Theme.textPrimary
                            font.pixelSize: 13
                            font.family: Theme.fontFamily
                            font.weight: Font.Bold
                        }

                        // Info (i) Button on the right
                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 22; height: 22; radius: 11
                            color: root.showModeInfo ? Theme.accent : (infoMouse.containsMouse ? Theme.bgCardHover : Theme.bgElevated)
                            border.color: root.showModeInfo ? Theme.accent : Theme.borderDim
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: "i"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                font.family: Theme.fontFamily
                                color: root.showModeInfo ? "#07090e" : (infoMouse.containsMouse ? Theme.accent : Theme.textSecondary)
                            }

                            MouseArea {
                                id: infoMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.showModeInfo = !root.showModeInfo
                            }
                        }
                    }

                    // Expandable Information Guide Card
                    Rectangle {
                        visible: root.showModeInfo
                        width: parent.width
                        implicitHeight: infoBoxCol.implicitHeight + 20
                        radius: Theme.radiusMd
                        color: Theme.bgElevated
                        border.color: Theme.accent
                        border.width: 1

                        Column {
                            id: infoBoxCol
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: I18n.t("proxyInfoTitle")
                                color: Theme.accent
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                                font.weight: Font.Bold
                            }

                            Text {
                                text: I18n.t("proxyInfoVpn")
                                color: Theme.textPrimary
                                font.pixelSize: 10
                                font.family: Theme.fontFamily
                                wrapMode: Text.Wrap
                                width: parent.width
                            }

                            Text {
                                text: I18n.t("proxyInfoSocks5")
                                color: Theme.textSecondary
                                font.pixelSize: 10
                                font.family: Theme.fontFamily
                                wrapMode: Text.Wrap
                                width: parent.width
                            }

                            Text {
                                text: I18n.t("proxyInfoHttp")
                                color: Theme.textSecondary
                                font.pixelSize: 10
                                font.family: Theme.fontFamily
                                wrapMode: Text.Wrap
                                width: parent.width
                            }
                        }
                    }

                    // Mode 0: In-App Stealth VPN (Recommended / Zero Setup)
                    Rectangle {
                        width: parent.width
                        implicitHeight: 64
                        radius: Theme.radiusMd
                        color: (root.selectedMode === 0) ? Theme.activeTabBg : (m0Mouse.containsMouse ? Theme.bgCardHover : Theme.bgElevated)
                        border.color: (root.selectedMode === 0) ? Theme.accent : Theme.borderDim
                        border.width: 1

                        MouseArea {
                            id: m0Mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.selectedMode = 0
                                if (typeof proxyManager !== "undefined") {
                                    proxyManager.proxyMode = 0
                                }
                            }
                        }

                        Row {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Rectangle {
                                width: 48; height: 22; radius: 4
                                color: (root.selectedMode === 0) ? Theme.accent : "#222c3c"
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "VPN"
                                    color: (root.selectedMode === 0) ? "#07090e" : Theme.textSecondary
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                width: parent.width - 120

                                Text {
                                    text: I18n.t("proxyModeAutoVPN")
                                    color: (root.selectedMode === 0) ? Theme.accent : Theme.textPrimary
                                    font.pixelSize: 12
                                    font.family: Theme.fontFamily
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: I18n.t("proxyModeAutoVPNDesc")
                                    color: Theme.textSecondary
                                    font.pixelSize: 10
                                    font.family: Theme.fontFamily
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }

                            Rectangle {
                                width: 16; height: 16; radius: 8
                                anchors.verticalCenter: parent.verticalCenter
                                color: (root.selectedMode === 0) ? Theme.accent : "transparent"
                                border.color: (root.selectedMode === 0) ? Theme.accent : Theme.borderBright
                                border.width: 2

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 6; height: 6; radius: 3
                                    color: "#07090e"
                                    visible: root.selectedMode === 0
                                }
                            }
                        }
                    }

                    // Mode 1: SOCKS5
                    Rectangle {
                        width: parent.width
                        implicitHeight: 60
                        radius: Theme.radiusMd
                        color: (root.selectedMode === 1) ? Theme.activeTabBg : (m1Mouse.containsMouse ? Theme.bgCardHover : Theme.bgElevated)
                        border.color: (root.selectedMode === 1) ? Theme.accent : Theme.borderDim
                        border.width: 1

                        MouseArea {
                            id: m1Mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.selectedMode = 1
                                if (typeof proxyManager !== "undefined") {
                                    proxyManager.proxyMode = 1
                                }
                            }
                        }

                        Row {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Rectangle {
                                width: 72; height: 22; radius: 4
                                color: (root.selectedMode === 1) ? Theme.accent : "#222c3c"
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "SOCKS5"
                                    color: (root.selectedMode === 1) ? "#07090e" : Theme.textSecondary
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                width: parent.width - 120

                                Text {
                                    text: I18n.t("proxyModeSocks5")
                                    color: (root.selectedMode === 1) ? Theme.accent : Theme.textPrimary
                                    font.pixelSize: 12
                                    font.family: Theme.fontFamily
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: I18n.t("proxyModeSocks5Desc")
                                    color: Theme.textSecondary
                                    font.pixelSize: 10
                                    font.family: Theme.fontFamily
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }

                            Rectangle {
                                width: 16; height: 16; radius: 8
                                anchors.verticalCenter: parent.verticalCenter
                                color: (root.selectedMode === 1) ? Theme.accent : "transparent"
                                border.color: (root.selectedMode === 1) ? Theme.accent : Theme.borderBright
                                border.width: 2

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 6; height: 6; radius: 3
                                    color: "#07090e"
                                    visible: root.selectedMode === 1
                                }
                            }
                        }
                    }

                    // Mode 2: HTTP / HTTPS
                    Rectangle {
                        width: parent.width
                        implicitHeight: 60
                        radius: Theme.radiusMd
                        color: (root.selectedMode === 2) ? Theme.activeTabBg : (m2Mouse.containsMouse ? Theme.bgCardHover : Theme.bgElevated)
                        border.color: (root.selectedMode === 2) ? Theme.accent : Theme.borderDim
                        border.width: 1

                        MouseArea {
                            id: m2Mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.selectedMode = 2
                                if (typeof proxyManager !== "undefined") {
                                    proxyManager.proxyMode = 2
                                }
                            }
                        }

                        Row {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Rectangle {
                                width: 72; height: 22; radius: 4
                                color: (root.selectedMode === 2) ? Theme.accent : "#222c3c"
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "HTTP"
                                    color: (root.selectedMode === 2) ? "#07090e" : Theme.textSecondary
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                width: parent.width - 120

                                Text {
                                    text: I18n.t("proxyModeHttp")
                                    color: (root.selectedMode === 2) ? Theme.accent : Theme.textPrimary
                                    font.pixelSize: 12
                                    font.family: Theme.fontFamily
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: I18n.t("proxyModeHttpDesc")
                                    color: Theme.textSecondary
                                    font.pixelSize: 10
                                    font.family: Theme.fontFamily
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }

                            Rectangle {
                                width: 16; height: 16; radius: 8
                                anchors.verticalCenter: parent.verticalCenter
                                color: (root.selectedMode === 2) ? Theme.accent : "transparent"
                                border.color: (root.selectedMode === 2) ? Theme.accent : Theme.borderBright
                                border.width: 2

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 6; height: 6; radius: 3
                                    color: "#07090e"
                                    visible: root.selectedMode === 2
                                }
                            }
                        }
                    }
                }
            }

            // Card 3-A: In-App VPN Active Node Control (Shown ONLY in Mode 0)
            Rectangle {
                visible: root.selectedMode === 0
                width: parent.width
                implicitHeight: autoVpnCol.implicitHeight + 32
                radius: Theme.radiusLg
                color: Theme.bgCard
                border.color: Theme.borderDim
                border.width: 1

                Column {
                    id: autoVpnCol
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 14

                    Row {
                        width: parent.width
                        spacing: 8

                        Text {
                            text: "In-App VPN"
                            color: Theme.textPrimary
                            font.pixelSize: 13
                            font.family: Theme.fontFamily
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Item { width: 10; height: 1 }

                        // Node Status Chip
                        Rectangle {
                            height: 22
                            width: autoStatusChipTxt.implicitWidth + 16
                            radius: 11
                            color: (typeof proxyManager !== "undefined" && proxyManager.autoConnected) ? "#143a2d" : "#222c3c"
                            border.color: (typeof proxyManager !== "undefined" && proxyManager.autoConnected) ? "#00d29d" : Theme.borderDim
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: autoStatusChipTxt
                                anchors.centerIn: parent
                                text: {
                                    if (typeof proxyManager === "undefined") return "Ready"
                                    if (proxyManager.autoConnecting) return I18n.t("proxyAutoConnecting")
                                    if (proxyManager.autoConnected) return proxyManager.autoLocation + " (" + proxyManager.autoLatency + " ms)"
                                    return proxyManager.autoStatusMessage
                                }
                                color: (typeof proxyManager !== "undefined" && proxyManager.autoConnected) ? "#00d29d" : Theme.textSecondary
                                font.pixelSize: 10
                                font.family: Theme.fontFamily
                                font.weight: Font.DemiBold
                            }
                        }
                    }

                    // Node Info Details Box
                    Rectangle {
                        width: parent.width
                        implicitHeight: nodeDetailsRow.implicitHeight + 20
                        radius: Theme.radiusMd
                        color: Theme.bgElevated
                        border.color: Theme.borderDim
                        border.width: 1

                        Row {
                            id: nodeDetailsRow
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 16

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4
                                width: (parent.width - 16) * 0.55

                                Text {
                                    text: I18n.t("proxyAutoLocation")
                                    color: Theme.textSecondary
                                    font.pixelSize: 10
                                    font.family: Theme.fontFamily
                                }
                                Text {
                                    text: (typeof proxyManager !== "undefined" && proxyManager.autoConnected && proxyManager.autoLocation !== "")
                                          ? proxyManager.autoLocation
                                          : "Standby / Ready"
                                    color: Theme.textPrimary
                                    font.pixelSize: 12
                                    font.family: Theme.fontFamily
                                    font.weight: Font.Bold
                                }
                                Text {
                                    visible: (typeof proxyManager !== "undefined" && proxyManager.autoConnected)
                                    text: I18n.t("proxyExitIpLabel") + " " + ((proxyManager.autoExitIp !== "") ? proxyManager.autoExitIp : "Detecting...")
                                    color: "#00d29d"
                                    font.pixelSize: 10
                                    font.family: Theme.fontFamily
                                    font.weight: Font.DemiBold
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4
                                width: (parent.width - 16) * 0.45

                                Text {
                                    text: "Protocol / Latency:"
                                    color: Theme.textSecondary
                                    font.pixelSize: 10
                                    font.family: Theme.fontFamily
                                }
                                Text {
                                    text: (typeof proxyManager !== "undefined" && proxyManager.autoConnected)
                                          ? proxyManager.autoProtocol + " • " + proxyManager.autoLatency + " ms"
                                          : "--"
                                    color: (typeof proxyManager !== "undefined" && proxyManager.autoConnected) ? "#00d29d" : Theme.textSecondary
                                    font.pixelSize: 12
                                    font.family: Theme.fontFamily
                                    font.weight: Font.Bold
                                }
                                Text {
                                    visible: (typeof proxyManager !== "undefined" && proxyManager.autoConnected)
                                    text: "Tunnel Verified (Domain Hidden)"
                                    color: Theme.textSecondary
                                    font.pixelSize: 10
                                    font.family: Theme.fontFamily
                                }
                            }
                        }
                    }

                    // Action Buttons for Auto VPN
                    Row {
                        width: parent.width
                        spacing: 12

                        // Switch Server Node Button
                        Rectangle {
                            width: (parent.width - 12) * 0.5
                            height: 40
                            radius: Theme.radiusMd
                            color: switchMouse.containsMouse ? Theme.bgCardHover : Theme.bgElevated
                            border.color: Theme.borderBright
                            border.width: 1

                            MouseArea {
                                id: switchMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (typeof proxyManager !== "undefined") {
                                        proxyManager.enabled = true
                                        proxyManager.switchAutoTunnelNode()
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: I18n.t("proxyAutoSwitchBtn")
                                color: Theme.textPrimary
                                font.pixelSize: 12
                                font.family: Theme.fontFamily
                                font.weight: Font.DemiBold
                            }
                        }

                        // Connect / Reconnect Button
                        Rectangle {
                            width: (parent.width - 12) * 0.5
                            height: 40
                            radius: Theme.radiusMd
                            color: connectVpnMouse.containsMouse ? "#00e5ab" : Theme.accent

                            MouseArea {
                                id: connectVpnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (typeof proxyManager !== "undefined") {
                                        proxyManager.enabled = true
                                        proxyManager.startAutoTunnel()
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: {
                                    if (typeof proxyManager !== "undefined" && proxyManager.autoConnecting)
                                        return I18n.t("proxyAutoConnecting")
                                    if (typeof proxyManager !== "undefined" && proxyManager.autoConnected)
                                        return "Connected (Reconnect)"
                                    return "Connect"
                                }
                                color: "#07090e"
                                font.pixelSize: 12
                                font.family: Theme.fontFamily
                                font.weight: Font.Bold
                            }
                        }
                    }
                }
            }

            // Card 3-B: Server Configuration & Quick Presets (Shown for SOCKS5 or HTTP)
            Rectangle {
                visible: root.selectedMode !== 0
                width: parent.width
                implicitHeight: configCol.implicitHeight + 32
                radius: Theme.radiusLg
                color: Theme.bgCard
                border.color: Theme.borderDim
                border.width: 1

                Column {
                    id: configCol
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 14

                    Row {
                        width: parent.width
                        spacing: 8

                        Text {
                            text: I18n.t("proxyConfigTitle")
                            color: Theme.textPrimary
                            font.pixelSize: 13
                            font.family: Theme.fontFamily
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Item { width: 10; height: 1 }

                        // Quick Presets (Only shown for SOCKS5)
                        Row {
                            visible: root.selectedMode === 1
                            spacing: 6
                            anchors.verticalCenter: parent.verticalCenter

                            // WARP Preset
                            Rectangle {
                                height: 22
                                width: warpTxt.implicitWidth + 14
                                radius: 4
                                color: warpMouse.containsMouse ? Theme.bgCardHover : Theme.bgElevated
                                border.color: (root.localPort === 40000) ? Theme.accent : Theme.borderDim
                                border.width: 1

                                Text {
                                    id: warpTxt
                                    anchors.centerIn: parent
                                    text: "Cloudflare WARP (40000)"
                                    color: (root.localPort === 40000) ? Theme.accent : Theme.textSecondary
                                    font.pixelSize: 10
                                    font.family: Theme.fontFamily
                                }

                                MouseArea {
                                    id: warpMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.localHost = "127.0.0.1"
                                        root.localPort = 40000
                                    }
                                }
                            }

                            // Tor Preset
                            Rectangle {
                                height: 22
                                width: torTxt.implicitWidth + 14
                                radius: 4
                                color: torMouse.containsMouse ? Theme.bgCardHover : Theme.bgElevated
                                border.color: (root.localPort === 9050) ? Theme.accent : Theme.borderDim
                                border.width: 1

                                Text {
                                    id: torTxt
                                    anchors.centerIn: parent
                                    text: "Tor (9050)"
                                    color: (root.localPort === 9050) ? Theme.accent : Theme.textSecondary
                                    font.pixelSize: 10
                                    font.family: Theme.fontFamily
                                }

                                MouseArea {
                                    id: torMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.localHost = "127.0.0.1"
                                        root.localPort = 9050
                                    }
                                }
                            }

                            // Xray / v2ray Preset
                            Rectangle {
                                height: 22
                                width: xrayTxt.implicitWidth + 14
                                radius: 4
                                color: xrayMouse.containsMouse ? Theme.bgCardHover : Theme.bgElevated
                                border.color: (root.localPort === 10808) ? Theme.accent : Theme.borderDim
                                border.width: 1

                                Text {
                                    id: xrayTxt
                                    anchors.centerIn: parent
                                    text: "v2ray / Xray (10808)"
                                    color: (root.localPort === 10808) ? Theme.accent : Theme.textSecondary
                                    font.pixelSize: 10
                                    font.family: Theme.fontFamily
                                }

                                MouseArea {
                                    id: xrayMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.localHost = "127.0.0.1"
                                        root.localPort = 10808
                                    }
                                }
                            }
                        }
                    }

                    // Host & Port Row
                    Row {
                        width: parent.width
                        spacing: 12

                        // Host Input
                        Column {
                            width: (parent.width - 12) * 0.72
                            spacing: 5

                            Text {
                                text: I18n.t("proxyHost")
                                color: Theme.textSecondary
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                            }

                            Rectangle {
                                width: parent.width
                                height: 36
                                radius: Theme.radiusMd
                                color: Theme.bgElevated
                                border.color: hostInput.activeFocus ? Theme.accent : Theme.borderDim
                                border.width: 1

                                TextInput {
                                    id: hostInput
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    text: root.localHost
                                    color: Theme.textPrimary
                                    font.pixelSize: 12
                                    font.family: Theme.fontFamily
                                    verticalAlignment: TextInput.AlignVCenter
                                    selectByMouse: true
                                    onTextChanged: root.localHost = text
                                }
                            }
                        }

                        // Port Input
                        Column {
                            width: (parent.width - 12) * 0.28
                            spacing: 5

                            Text {
                                text: I18n.t("proxyPort")
                                color: Theme.textSecondary
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                            }

                            Rectangle {
                                width: parent.width
                                height: 36
                                radius: Theme.radiusMd
                                color: Theme.bgElevated
                                border.color: portInput.activeFocus ? Theme.accent : Theme.borderDim
                                border.width: 1

                                TextInput {
                                    id: portInput
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    text: root.localPort.toString()
                                    color: Theme.textPrimary
                                    font.pixelSize: 12
                                    font.family: Theme.fontFamily
                                    verticalAlignment: TextInput.AlignVCenter
                                    selectByMouse: true
                                    validator: IntValidator { bottom: 1; top: 65535 }
                                    onTextChanged: root.localPort = parseInt(text) || 40000
                                }
                            }
                        }
                    }

                    // Credentials Row (Optional)
                    Row {
                        width: parent.width
                        spacing: 12

                        // Username Input
                        Column {
                            width: (parent.width - 12) * 0.5
                            spacing: 5

                            Text {
                                text: I18n.t("proxyUser")
                                color: Theme.textSecondary
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                            }

                            Rectangle {
                                width: parent.width
                                height: 36
                                radius: Theme.radiusMd
                                color: Theme.bgElevated
                                border.color: userInput.activeFocus ? Theme.accent : Theme.borderDim
                                border.width: 1

                                TextInput {
                                    id: userInput
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    text: root.localUser
                                    color: Theme.textPrimary
                                    font.pixelSize: 12
                                    font.family: Theme.fontFamily
                                    verticalAlignment: TextInput.AlignVCenter
                                    selectByMouse: true
                                    onTextChanged: root.localUser = text
                                }
                            }
                        }

                        // Password Input
                        Column {
                            width: (parent.width - 12) * 0.5
                            spacing: 5

                            Text {
                                text: I18n.t("proxyPass")
                                color: Theme.textSecondary
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                            }

                            Rectangle {
                                width: parent.width
                                height: 36
                                radius: Theme.radiusMd
                                color: Theme.bgElevated
                                border.color: passInput.activeFocus ? Theme.accent : Theme.borderDim
                                border.width: 1

                                TextInput {
                                    id: passInput
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 52
                                    text: root.localPass
                                    echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
                                    color: Theme.textPrimary
                                    font.pixelSize: 12
                                    font.family: Theme.fontFamily
                                    verticalAlignment: TextInput.AlignVCenter
                                    selectByMouse: true
                                    onTextChanged: root.localPass = text
                                }

                                Text {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: root.showPassword ? "Hide" : "Show"
                                    color: Theme.accent
                                    font.pixelSize: 10
                                    font.family: Theme.fontFamily
                                    font.weight: Font.DemiBold
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.showPassword = !root.showPassword
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Card 4: Action Buttons (Only shown in Manual SOCKS5 or HTTP modes)
            Row {
                visible: root.selectedMode !== 0
                width: parent.width
                spacing: 12

                // Test Connection Button
                Rectangle {
                    width: (parent.width - 12) * 0.42
                    height: 42
                    radius: Theme.radiusMd
                    color: testMouse.containsMouse ? Theme.bgCardHover : Theme.bgElevated
                    border.color: (typeof proxyManager !== "undefined" && proxyManager.isTesting) ? Theme.accent : Theme.borderBright
                    border.width: 1

                    MouseArea {
                        id: testMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: typeof proxyManager !== "undefined" && !proxyManager.isTesting
                        onClicked: {
                            if (typeof proxyManager !== "undefined") {
                                proxyManager.setProxyMode(root.selectedMode)
                                proxyManager.setHost(root.localHost)
                                proxyManager.setPort(root.localPort)
                                proxyManager.setUsername(root.localUser)
                                proxyManager.setPassword(root.localPass)
                                proxyManager.testConnection()
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: (typeof proxyManager !== "undefined" && proxyManager.isTesting)
                              ? I18n.t("proxyStatusTesting")
                              : I18n.t("proxyTestBtn")
                        color: Theme.textPrimary
                        font.pixelSize: 12
                        font.family: Theme.fontFamily
                        font.weight: Font.DemiBold
                    }
                }

                // Save & Apply Button
                Rectangle {
                    width: (parent.width - 12) * 0.58
                    height: 42
                    radius: Theme.radiusMd
                    color: saveMouse.containsMouse ? "#00e5ab" : Theme.accent

                    MouseArea {
                        id: saveMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (typeof proxyManager !== "undefined") {
                                proxyManager.setProxyMode(root.selectedMode)
                                proxyManager.setHost(root.localHost)
                                proxyManager.setPort(root.localPort)
                                proxyManager.setUsername(root.localUser)
                                proxyManager.setPassword(root.localPass)
                                proxyManager.enabled = true
                                proxyManager.applyProxy()
                                proxyManager.saveSettings()
                                root.savedNotification = true
                                notificationTimer.restart()
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: I18n.t("proxySaveBtn")
                        color: "#07090e"
                        font.pixelSize: 13
                        font.family: Theme.fontFamily
                        font.weight: Font.Bold
                    }
                }
            }

            // Status message from test (Manual Mode)
            Rectangle {
                visible: (root.selectedMode !== 0 && typeof proxyManager !== "undefined" && proxyManager.testStatus !== 0)
                width: parent.width
                height: 34
                radius: Theme.radiusMd
                color: (typeof proxyManager !== "undefined" && proxyManager.testStatus === 1) ? "#112a22" : "#2a1515"
                border.color: (typeof proxyManager !== "undefined" && proxyManager.testStatus === 1) ? "#00d29d" : "#ef4444"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: (typeof proxyManager !== "undefined") ? proxyManager.testMessage : ""
                    color: (typeof proxyManager !== "undefined" && proxyManager.testStatus === 1) ? "#00d29d" : "#ef4444"
                    font.pixelSize: 11
                    font.family: Theme.fontFamily
                    font.weight: Font.DemiBold
                }
            }

            // Save Confirmation Notification Banner
            Rectangle {
                visible: root.savedNotification
                width: parent.width
                height: 34
                radius: Theme.radiusMd
                color: "#112a22"
                border.color: "#00d29d"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: I18n.t("proxyAppliedSuccess")
                    color: "#00d29d"
                    font.pixelSize: 11
                    font.family: Theme.fontFamily
                    font.weight: Font.DemiBold
                }
            }
        }
    }
}
