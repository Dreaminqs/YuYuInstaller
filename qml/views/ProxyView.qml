import QtQuick
import QtQuick.Controls
import MediaGrab

Item {
    id: root

    // Local state for editing before saving
    property int selectedMode: (typeof proxyManager !== "undefined") ? proxyManager.proxyMode : 0
    property string localHost: (typeof proxyManager !== "undefined") ? proxyManager.host : "127.0.0.1"
    property int localPort: (typeof proxyManager !== "undefined") ? proxyManager.port : 10808
    property string localUser: (typeof proxyManager !== "undefined") ? proxyManager.username : ""
    property string localPass: (typeof proxyManager !== "undefined") ? proxyManager.password : ""
    property bool showPassword: false
    property bool savedNotification: false

    Timer {
        id: notificationTimer
        interval: 3000
        onTriggered: root.savedNotification = false
    }

    Flickable {
        anchors.fill: parent
        anchors.margins: 28
        contentHeight: contentCol.height + 60
        clip: true

        Column {
            id: contentCol
            width: Math.min(parent.width, 760)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 24

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
                implicitHeight: statusCol.implicitHeight + 36
                radius: Theme.radiusLg
                color: Theme.bgCard
                border.color: (typeof proxyManager !== "undefined" && proxyManager.enabled && proxyManager.proxyMode !== 0) ? Theme.accent : Theme.borderDim
                border.width: 1

                Behavior on border.color { ColorAnimation { duration: 250 } }

                Column {
                    id: statusCol
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    Item {
                        width: parent.width
                        height: 40

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 14

                            // Pulsing status LED
                            Item {
                                width: 38; height: 38
                                anchors.verticalCenter: parent.verticalCenter

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 34; height: 34; radius: 17
                                    color: (typeof proxyManager !== "undefined" && proxyManager.enabled && proxyManager.proxyMode !== 0) ? "#00d29d" : "#64748b"
                                    opacity: 0.15

                                    SequentialAnimation on scale {
                                        running: (typeof proxyManager !== "undefined" && proxyManager.enabled && proxyManager.proxyMode !== 0)
                                        loops: Animation.Infinite
                                        NumberAnimation { from: 0.9; to: 1.25; duration: 1200; easing.type: Easing.InOutQuad }
                                        NumberAnimation { from: 1.25; to: 0.9; duration: 1200; easing.type: Easing.InOutQuad }
                                    }
                                }

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 14; height: 14; radius: 7
                                    color: (typeof proxyManager !== "undefined" && proxyManager.enabled && proxyManager.proxyMode !== 0) ? "#00d29d" : "#64748b"
                                }
                            }

                            // Status Info
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 3

                                Text {
                                    text: I18n.t("proxyStatusCardTitle")
                                    color: Theme.textSecondary
                                    font.pixelSize: 11
                                    font.family: Theme.fontFamily
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    text: (typeof proxyManager !== "undefined" && proxyManager.enabled && proxyManager.proxyMode !== 0)
                                          ? I18n.t("proxyStatusActive")
                                          : I18n.t("proxyStatusInactive")
                                    color: (typeof proxyManager !== "undefined" && proxyManager.enabled && proxyManager.proxyMode !== 0)
                                           ? "#00d29d"
                                           : Theme.textPrimary
                                    font.pixelSize: 14
                                    font.family: Theme.fontFamily
                                    font.weight: Font.Bold
                                }
                            }
                        }

                        // Animated Master Toggle Switch
                        Item {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            width: 52; height: 28

                            Rectangle {
                                anchors.fill: parent
                                radius: 14
                                color: (typeof proxyManager !== "undefined" && proxyManager.enabled) ? Theme.accent : "#222c3c"
                                border.color: (typeof proxyManager !== "undefined" && proxyManager.enabled) ? Theme.accent : Theme.borderDim
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 200 } }

                                Rectangle {
                                    width: 22; height: 22; radius: 11
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
                        height: 32
                        radius: Theme.radiusMd
                        color: Theme.bgElevated
                        border.color: Theme.borderDim
                        border.width: 1

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12

                            Text {
                                text: {
                                    if (typeof proxyManager === "undefined" || !proxyManager.enabled || proxyManager.proxyMode === 0)
                                        return "• " + I18n.t("proxyModeDirect")
                                    if (proxyManager.proxyMode === 1)
                                        return "• " + I18n.t("proxyModeCloudflare") + " (DoH DNS / TLS Masking)"
                                    if (proxyManager.proxyMode === 2)
                                        return "• SOCKS5: " + proxyManager.host + ":" + proxyManager.port
                                    if (proxyManager.proxyMode === 3)
                                        return "• HTTP: " + proxyManager.host + ":" + proxyManager.port
                                    return ""
                                }
                                color: Theme.textSecondary
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Item { width: 10; height: 1 }

                            // Latency Badge if test passed
                            Rectangle {
                                visible: (typeof proxyManager !== "undefined" && proxyManager.testStatus === 1)
                                height: 20
                                width: latencyTxt.implicitWidth + 14
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

            // Card 2: Tunnel Modes
            Rectangle {
                width: parent.width
                implicitHeight: modeCol.implicitHeight + 36
                radius: Theme.radiusLg
                color: Theme.bgCard
                border.color: Theme.borderDim
                border.width: 1

                Column {
                    id: modeCol
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14

                    Text {
                        text: I18n.t("proxyModeTitle")
                        color: Theme.textPrimary
                        font.pixelSize: 14
                        font.family: Theme.fontFamily
                        font.weight: Font.Bold
                    }

                    // Mode 0: Direct
                    Rectangle {
                        width: parent.width
                        implicitHeight: 62
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
                            spacing: 14

                            Text {
                                text: "⚡"
                                font.pixelSize: 18
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                width: parent.width - 70

                                Text {
                                    text: I18n.t("proxyModeDirect")
                                    color: (root.selectedMode === 0) ? Theme.accent : Theme.textPrimary
                                    font.pixelSize: 13
                                    font.family: Theme.fontFamily
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: I18n.t("proxyModeDirectDesc")
                                    color: Theme.textSecondary
                                    font.pixelSize: 11
                                    font.family: Theme.fontFamily
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }

                            Rectangle {
                                width: 18; height: 18; radius: 9
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

                    // Mode 1: Cloudflare Stealth (DoH & Fast Tunnel)
                    Rectangle {
                        width: parent.width
                        implicitHeight: 62
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
                                    proxyManager.enabled = true
                                }
                            }
                        }

                        Row {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 14

                            Text {
                                text: "🛡️"
                                font.pixelSize: 18
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                width: parent.width - 70

                                Text {
                                    text: I18n.t("proxyModeCloudflare")
                                    color: (root.selectedMode === 1) ? Theme.accent : Theme.textPrimary
                                    font.pixelSize: 13
                                    font.family: Theme.fontFamily
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: I18n.t("proxyModeCloudflareDesc")
                                    color: Theme.textSecondary
                                    font.pixelSize: 11
                                    font.family: Theme.fontFamily
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }

                            Rectangle {
                                width: 18; height: 18; radius: 9
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

                    // Mode 2: Custom SOCKS5
                    Rectangle {
                        width: parent.width
                        implicitHeight: 62
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
                            spacing: 14

                            Text {
                                text: "🧦"
                                font.pixelSize: 18
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                width: parent.width - 70

                                Text {
                                    text: I18n.t("proxyModeSocks5")
                                    color: (root.selectedMode === 2) ? Theme.accent : Theme.textPrimary
                                    font.pixelSize: 13
                                    font.family: Theme.fontFamily
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: I18n.t("proxyModeSocks5Desc")
                                    color: Theme.textSecondary
                                    font.pixelSize: 11
                                    font.family: Theme.fontFamily
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }

                            Rectangle {
                                width: 18; height: 18; radius: 9
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

                    // Mode 3: Custom HTTP
                    Rectangle {
                        width: parent.width
                        implicitHeight: 62
                        radius: Theme.radiusMd
                        color: (root.selectedMode === 3) ? Theme.activeTabBg : (m3Mouse.containsMouse ? Theme.bgCardHover : Theme.bgElevated)
                        border.color: (root.selectedMode === 3) ? Theme.accent : Theme.borderDim
                        border.width: 1

                        MouseArea {
                            id: m3Mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.selectedMode = 3
                                if (typeof proxyManager !== "undefined") {
                                    proxyManager.proxyMode = 3
                                }
                            }
                        }

                        Row {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 14

                            Text {
                                text: "🌐"
                                font.pixelSize: 18
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                width: parent.width - 70

                                Text {
                                    text: I18n.t("proxyModeHttp")
                                    color: (root.selectedMode === 3) ? Theme.accent : Theme.textPrimary
                                    font.pixelSize: 13
                                    font.family: Theme.fontFamily
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: I18n.t("proxyModeHttpDesc")
                                    color: Theme.textSecondary
                                    font.pixelSize: 11
                                    font.family: Theme.fontFamily
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }

                            Rectangle {
                                width: 18; height: 18; radius: 9
                                anchors.verticalCenter: parent.verticalCenter
                                color: (root.selectedMode === 3) ? Theme.accent : "transparent"
                                border.color: (root.selectedMode === 3) ? Theme.accent : Theme.borderBright
                                border.width: 2

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 6; height: 6; radius: 3
                                    color: "#07090e"
                                    visible: root.selectedMode === 3
                                }
                            }
                        }
                    }
                }
            }

            // Card 3: Custom Proxy Configuration (Only visible for SOCKS5 or HTTP)
            Rectangle {
                visible: root.selectedMode === 2 || root.selectedMode === 3
                width: parent.width
                implicitHeight: configCol.implicitHeight + 36
                radius: Theme.radiusLg
                color: Theme.bgCard
                border.color: Theme.borderDim
                border.width: 1

                Column {
                    id: configCol
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 16

                    Text {
                        text: I18n.t("proxyConfigTitle")
                        color: Theme.textPrimary
                        font.pixelSize: 14
                        font.family: Theme.fontFamily
                        font.weight: Font.Bold
                    }

                    // Host & Port Row
                    Row {
                        width: parent.width
                        spacing: 14

                        // Host Input
                        Column {
                            width: (parent.width - 14) * 0.7
                            spacing: 6

                            Text {
                                text: I18n.t("proxyHost")
                                color: Theme.textSecondary
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                                font.weight: Font.DemiBold
                            }

                            Rectangle {
                                width: parent.width
                                height: 38
                                radius: Theme.radiusMd
                                color: Theme.bgElevated
                                border.color: hostInput.activeFocus ? Theme.accent : Theme.borderDim
                                border.width: 1

                                TextInput {
                                    id: hostInput
                                    anchors.fill: parent
                                    anchors.margins: 10
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
                            width: (parent.width - 14) * 0.3
                            spacing: 6

                            Text {
                                text: I18n.t("proxyPort")
                                color: Theme.textSecondary
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                                font.weight: Font.DemiBold
                            }

                            Rectangle {
                                width: parent.width
                                height: 38
                                radius: Theme.radiusMd
                                color: Theme.bgElevated
                                border.color: portInput.activeFocus ? Theme.accent : Theme.borderDim
                                border.width: 1

                                TextInput {
                                    id: portInput
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    text: root.localPort.toString()
                                    color: Theme.textPrimary
                                    font.pixelSize: 12
                                    font.family: Theme.fontFamily
                                    verticalAlignment: TextInput.AlignVCenter
                                    selectByMouse: true
                                    validator: IntValidator { bottom: 1; top: 65535 }
                                    onTextChanged: root.localPort = parseInt(text) || 10808
                                }
                            }
                        }
                    }

                    // Credentials Row (Optional)
                    Row {
                        width: parent.width
                        spacing: 14

                        // Username Input
                        Column {
                            width: (parent.width - 14) * 0.5
                            spacing: 6

                            Text {
                                text: I18n.t("proxyUser")
                                color: Theme.textSecondary
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                                font.weight: Font.DemiBold
                            }

                            Rectangle {
                                width: parent.width
                                height: 38
                                radius: Theme.radiusMd
                                color: Theme.bgElevated
                                border.color: userInput.activeFocus ? Theme.accent : Theme.borderDim
                                border.width: 1

                                TextInput {
                                    id: userInput
                                    anchors.fill: parent
                                    anchors.margins: 10
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
                            width: (parent.width - 14) * 0.5
                            spacing: 6

                            Text {
                                text: I18n.t("proxyPass")
                                color: Theme.textSecondary
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                                font.weight: Font.DemiBold
                            }

                            Rectangle {
                                width: parent.width
                                height: 38
                                radius: Theme.radiusMd
                                color: Theme.bgElevated
                                border.color: passInput.activeFocus ? Theme.accent : Theme.borderDim
                                border.width: 1

                                TextInput {
                                    id: passInput
                                    anchors.fill: parent
                                    anchors.margins: 10
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
                                    text: root.showPassword ? "👁️" : "🔒"
                                    font.pixelSize: 13
                                    opacity: 0.6
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

            // Card 4: Action Buttons (Test & Save)
            Row {
                width: parent.width
                spacing: 14

                // Test Connection Button
                Rectangle {
                    width: (parent.width - 14) * 0.45
                    height: 44
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
                                proxyManager.setHost(root.localHost)
                                proxyManager.setPort(root.localPort)
                                proxyManager.setUsername(root.localUser)
                                proxyManager.setPassword(root.localPass)
                                proxyManager.testConnection()
                            }
                        }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: (typeof proxyManager !== "undefined" && proxyManager.isTesting) ? "⏳" : "📡"
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: (typeof proxyManager !== "undefined" && proxyManager.isTesting)
                                  ? I18n.t("proxyStatusTesting")
                                  : I18n.t("proxyTestBtn")
                            color: Theme.textPrimary
                            font.pixelSize: 12
                            font.family: Theme.fontFamily
                            font.weight: Font.DemiBold
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // Save & Apply Button
                Rectangle {
                    width: (parent.width - 14) * 0.55
                    height: 44
                    radius: Theme.radiusMd
                    color: saveMouse.containsMouse ? "#00e5ab" : Theme.accent
                    border.color: "#00d29d"
                    border.width: 1

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
                                if (root.selectedMode !== 0) {
                                    proxyManager.enabled = true
                                }
                                proxyManager.applyProxy()
                                proxyManager.saveSettings()
                                root.savedNotification = true
                                notificationTimer.restart()
                            }
                        }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "✓"
                            color: "#07090e"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: I18n.t("proxySaveBtn")
                            color: "#07090e"
                            font.pixelSize: 13
                            font.family: Theme.fontFamily
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            // Save Confirmation Notification Banner
            Rectangle {
                visible: root.savedNotification
                width: parent.width
                height: 38
                radius: Theme.radiusMd
                color: "#112a22"
                border.color: "#00d29d"
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "✓"
                        color: "#00d29d"
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: I18n.t("proxyAppliedSuccess")
                        color: "#00d29d"
                        font.pixelSize: 12
                        font.family: Theme.fontFamily
                        font.weight: Font.DemiBold
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
