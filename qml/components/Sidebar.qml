import QtQuick
import YuYuInstaller

Rectangle {
    id: root
    implicitWidth: 220
    color: Theme.bgSidebar
    border.width: 0

    // Extra dark overlay for stronger separation from the video background
    Rectangle {
        anchors.fill: parent
        color: "#59060912"
    }

    // Subtle right edge divider
    Rectangle {
        anchors.right: parent.right
        width: 1
        height: parent.height
        color: "#14ffffff"
    }

    property int activeTab: 0 // 0: Dashboard, 1: Queue, 2: Updates, 3: Proxy, 4: Settings

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 20

        // Logo & Branding
        Row {
            spacing: 12
            Item {
                width: 44
                height: 44

                Image {
                    anchors.fill: parent
                    source: "qrc:/qt/qml/YuYuInstaller/assets/logo.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Text {
                    text: I18n.t("appName")
                    color: Theme.textPrimary
                    font.pixelSize: 15
                    font.family: Theme.fontFamily
                    font.weight: Font.Bold
                }
                Text {
                    text: I18n.t("appVersion")
                    color: Theme.accent
                    font.pixelSize: 10
                    font.family: Theme.fontFamily
                    font.weight: Font.DemiBold
                }
            }
        }

        Item {
            width: parent.width
            height: 1
        }

        // Navigation Menu — Concept F: Morph & Tilt
        Column {
            width: parent.width
            spacing: 6

            // ═══════════════════════════════════════════════════════
            // Tab 0: Dashboard (Downloader)
            // ═══════════════════════════════════════════════════════
            Rectangle {
                width: parent.width
                height: 42
                readonly property bool isActive: root.activeTab === 0
                readonly property bool isHover: tab0Mouse.containsMouse

                radius: (isActive || isHover) ? 14 : 9
                color: isActive ? Qt.alpha(Theme.accent, 0.20) : (isHover ? "#12ffffff" : "transparent")
                border.color: isActive ? Qt.alpha(Theme.accent, 0.45) : (isHover ? "#1affffff" : "transparent")
                border.width: 1
                opacity: isActive ? 1.0 : (isHover ? 0.94 : 0.55)

                Behavior on radius { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on border.color { ColorAnimation { duration: 200 } }
                Behavior on opacity { NumberAnimation { duration: 180 } }

                MouseArea {
                    id: tab0Mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activeTab = 0
                }

                Item {
                    width: 18; height: 18
                    x: 14
                    anchors.verticalCenter: parent.verticalCenter
                    rotation: (parent.isActive || parent.isHover) ? -8 : 0
                    scale: parent.isHover ? 1.15 : (parent.isActive ? 1.10 : 1.0)

                    Behavior on rotation { NumberAnimation { duration: 230; easing.type: Easing.OutBack } }
                    Behavior on scale { NumberAnimation { duration: 230; easing.type: Easing.OutBack } }

                    Canvas {
                        id: tab0Canvas
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            ctx.strokeStyle = (root.activeTab === 0 || tab0Mouse.containsMouse) ? Theme.accent : Theme.textSecondary;
                            ctx.fillStyle = ctx.strokeStyle;
                            ctx.lineWidth = 1.75;
                            ctx.lineCap = "round";
                            ctx.lineJoin = "round";

                            ctx.beginPath();
                            ctx.moveTo(9, 2);
                            ctx.lineTo(9, 11);
                            ctx.moveTo(5.5, 7.5);
                            ctx.lineTo(9, 11);
                            ctx.lineTo(12.5, 7.5);
                            ctx.stroke();

                            ctx.beginPath();
                            ctx.moveTo(3, 11);
                            ctx.lineTo(3, 15);
                            ctx.lineTo(15, 15);
                            ctx.lineTo(15, 11);
                            ctx.stroke();
                        }
                        Connections {
                            target: root
                            function onActiveTabChanged() { tab0Canvas.requestPaint(); }
                        }
                        Connections {
                            target: tab0Mouse
                            function onContainsMouseChanged() { tab0Canvas.requestPaint(); }
                        }
                    }
                }

                Text {
                    text: I18n.t("navDownloader")
                    x: (parent.isActive || parent.isHover) ? 47 : 44
                    anchors.verticalCenter: parent.verticalCenter
                    color: parent.isActive ? Theme.activeTabText : (parent.isHover ? Theme.textPrimary : Theme.textSecondary)
                    font.pixelSize: 13
                    font.family: Theme.fontFamily
                    font.weight: parent.isActive ? Font.DemiBold : Font.Normal

                    Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 180 } }
                }
            }

            // ═══════════════════════════════════════════════════════
            // Tab 1: Queue
            // ═══════════════════════════════════════════════════════
            Rectangle {
                width: parent.width
                height: 42
                readonly property bool isActive: root.activeTab === 1
                readonly property bool isHover: tab1Mouse.containsMouse

                radius: (isActive || isHover) ? 14 : 9
                color: isActive ? Qt.alpha(Theme.accent, 0.20) : (isHover ? "#12ffffff" : "transparent")
                border.color: isActive ? Qt.alpha(Theme.accent, 0.45) : (isHover ? "#1affffff" : "transparent")
                border.width: 1
                opacity: isActive ? 1.0 : (isHover ? 0.94 : 0.55)

                Behavior on radius { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on border.color { ColorAnimation { duration: 200 } }
                Behavior on opacity { NumberAnimation { duration: 180 } }

                MouseArea {
                    id: tab1Mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activeTab = 1
                }

                Item {
                    width: 18; height: 18
                    x: 14
                    anchors.verticalCenter: parent.verticalCenter
                    rotation: (parent.isActive || parent.isHover) ? -8 : 0
                    scale: parent.isHover ? 1.15 : (parent.isActive ? 1.10 : 1.0)

                    Behavior on rotation { NumberAnimation { duration: 230; easing.type: Easing.OutBack } }
                    Behavior on scale { NumberAnimation { duration: 230; easing.type: Easing.OutBack } }

                    Canvas {
                        id: tab1Canvas
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            ctx.strokeStyle = (root.activeTab === 1 || tab1Mouse.containsMouse) ? Theme.accent : Theme.textSecondary;
                            ctx.fillStyle = ctx.strokeStyle;
                            ctx.lineWidth = 1.75;
                            ctx.lineCap = "round";

                            ctx.beginPath();
                            ctx.moveTo(7, 4);
                            ctx.lineTo(15, 4);
                            ctx.stroke();
                            ctx.beginPath();
                            ctx.arc(3.5, 4, 1.2, 0, Math.PI * 2);
                            ctx.fill();

                            ctx.beginPath();
                            ctx.moveTo(7, 9);
                            ctx.lineTo(15, 9);
                            ctx.stroke();
                            ctx.beginPath();
                            ctx.arc(3.5, 9, 1.2, 0, Math.PI * 2);
                            ctx.fill();

                            ctx.beginPath();
                            ctx.moveTo(7, 14);
                            ctx.lineTo(15, 14);
                            ctx.stroke();
                            ctx.beginPath();
                            ctx.arc(3.5, 14, 1.2, 0, Math.PI * 2);
                            ctx.fill();
                        }
                        Connections {
                            target: root
                            function onActiveTabChanged() { tab1Canvas.requestPaint(); }
                        }
                        Connections {
                            target: tab1Mouse
                            function onContainsMouseChanged() { tab1Canvas.requestPaint(); }
                        }
                    }
                }

                Text {
                    text: I18n.t("navQueue")
                    x: (parent.isActive || parent.isHover) ? 47 : 44
                    anchors.verticalCenter: parent.verticalCenter
                    color: parent.isActive ? Theme.activeTabText : (parent.isHover ? Theme.textPrimary : Theme.textSecondary)
                    font.pixelSize: 13
                    font.family: Theme.fontFamily
                    font.weight: parent.isActive ? Font.DemiBold : Font.Normal

                    Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 180 } }
                }

                // Badge for active downloads count (cleanly anchored inside the right edge)
                Rectangle {
                    visible: queueModel.activeDownloadCount > 0
                    height: 18
                    width: Math.max(18, queueBadgeTxt.implicitWidth + 10)
                    radius: 9
                    color: (root.activeTab === 1) ? Theme.accent : Qt.alpha(Theme.accent, 0.22)
                    border.color: (root.activeTab === 1) ? "transparent" : Qt.alpha(Theme.accent, 0.55)
                    border.width: (root.activeTab === 1) ? 0 : 1
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: queueBadgeTxt
                        anchors.centerIn: parent
                        text: queueModel.activeDownloadCount
                        color: (root.activeTab === 1) ? "#07090e" : Theme.accent
                        font.pixelSize: 10
                        font.family: Theme.fontFamily
                        font.weight: Font.Bold
                    }
                }
            }

            // ═══════════════════════════════════════════════════════
            // Tab 2: Updates
            // ═══════════════════════════════════════════════════════
            Rectangle {
                width: parent.width
                height: 42
                readonly property bool isActive: root.activeTab === 2
                readonly property bool isHover: tab2Mouse.containsMouse

                radius: (isActive || isHover) ? 14 : 9
                color: isActive ? Qt.alpha(Theme.accent, 0.20) : (isHover ? "#12ffffff" : "transparent")
                border.color: isActive ? Qt.alpha(Theme.accent, 0.45) : (isHover ? "#1affffff" : "transparent")
                border.width: 1
                opacity: isActive ? 1.0 : (isHover ? 0.94 : 0.55)

                Behavior on radius { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on border.color { ColorAnimation { duration: 200 } }
                Behavior on opacity { NumberAnimation { duration: 180 } }

                MouseArea {
                    id: tab2Mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activeTab = 2
                }

                Item {
                    width: 18; height: 18
                    x: 14
                    anchors.verticalCenter: parent.verticalCenter
                    rotation: (parent.isActive || parent.isHover) ? -8 : 0
                    scale: parent.isHover ? 1.15 : (parent.isActive ? 1.10 : 1.0)

                    Behavior on rotation { NumberAnimation { duration: 230; easing.type: Easing.OutBack } }
                    Behavior on scale { NumberAnimation { duration: 230; easing.type: Easing.OutBack } }

                    Canvas {
                        id: tab2Canvas
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            ctx.strokeStyle = (root.activeTab === 2 || tab2Mouse.containsMouse) ? Theme.accent : Theme.textSecondary;
                            ctx.fillStyle = ctx.strokeStyle;
                            ctx.lineWidth = 1.75;
                            ctx.lineCap = "round";
                            ctx.lineJoin = "round";

                            // Top sync arc (clear gap on both ends)
                            var r = 6.0;
                            var aTopStart = -135 * Math.PI / 180;
                            var aTopEnd   =  -15 * Math.PI / 180;
                            ctx.beginPath();
                            ctx.arc(9, 9, r, aTopStart, aTopEnd);
                            ctx.stroke();

                            // Top-right arrowhead at aTopEnd
                            var tx = 9 + r * Math.cos(aTopEnd);
                            var ty = 9 + r * Math.sin(aTopEnd);
                            ctx.beginPath();
                            ctx.moveTo(tx - 3.2, ty - 1.2);
                            ctx.lineTo(tx + 0.3, ty + 0.3);
                            ctx.lineTo(tx + 1.0, ty - 3.3);
                            ctx.stroke();

                            // Bottom sync arc (clear gap on both ends)
                            var aBotStart =  45 * Math.PI / 180;
                            var aBotEnd   = 165 * Math.PI / 180;
                            ctx.beginPath();
                            ctx.arc(9, 9, r, aBotStart, aBotEnd);
                            ctx.stroke();

                            // Bottom-left arrowhead at aBotEnd
                            var bx = 9 + r * Math.cos(aBotEnd);
                            var by = 9 + r * Math.sin(aBotEnd);
                            ctx.beginPath();
                            ctx.moveTo(bx + 3.2, by + 1.2);
                            ctx.lineTo(bx - 0.3, by - 0.3);
                            ctx.lineTo(bx - 1.0, by + 3.3);
                            ctx.stroke();
                        }
                        Connections {
                            target: root
                            function onActiveTabChanged() { tab2Canvas.requestPaint(); }
                        }
                        Connections {
                            target: tab2Mouse
                            function onContainsMouseChanged() { tab2Canvas.requestPaint(); }
                        }
                    }
                }

                Text {
                    text: I18n.t("navUpdates")
                    x: (parent.isActive || parent.isHover) ? 47 : 44
                    anchors.verticalCenter: parent.verticalCenter
                    color: parent.isActive ? Theme.activeTabText : (parent.isHover ? Theme.textPrimary : Theme.textSecondary)
                    font.pixelSize: 13
                    font.family: Theme.fontFamily
                    font.weight: parent.isActive ? Font.DemiBold : Font.Normal

                    Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 180 } }
                }

                // Neon update notification badge with gentle breathing pulse
                Item {
                    width: 14; height: 14
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    visible: (typeof updateManager !== "undefined" && updateManager.updateAvailable)

                    Rectangle {
                        anchors.centerIn: parent
                        width: 12; height: 12; radius: 6
                        color: Theme.accent
                        opacity: 0.35

                        SequentialAnimation on scale {
                            running: (typeof updateManager !== "undefined" && updateManager.updateAvailable)
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.8; to: 1.35; duration: 1100; easing.type: Easing.InOutQuad }
                            NumberAnimation { from: 1.35; to: 0.8; duration: 1100; easing.type: Easing.InOutQuad }
                        }
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 7; height: 7; radius: 3.5
                        color: Theme.accent
                    }
                }
            }

            // ═══════════════════════════════════════════════════════
            // Tab 3: Proxy & Privacy
            // ═══════════════════════════════════════════════════════
            Rectangle {
                width: parent.width
                height: 42
                readonly property bool isActive: root.activeTab === 3
                readonly property bool isHover: tabProxyMouse.containsMouse

                radius: (isActive || isHover) ? 14 : 9
                color: isActive ? Qt.alpha(Theme.accent, 0.20) : (isHover ? "#12ffffff" : "transparent")
                border.color: isActive ? Qt.alpha(Theme.accent, 0.45) : (isHover ? "#1affffff" : "transparent")
                border.width: 1
                opacity: isActive ? 1.0 : (isHover ? 0.94 : 0.55)

                Behavior on radius { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on border.color { ColorAnimation { duration: 200 } }
                Behavior on opacity { NumberAnimation { duration: 180 } }

                MouseArea {
                    id: tabProxyMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activeTab = 3
                }

                Item {
                    width: 18; height: 18
                    x: 14
                    anchors.verticalCenter: parent.verticalCenter
                    rotation: (parent.isActive || parent.isHover) ? -8 : 0
                    scale: parent.isHover ? 1.15 : (parent.isActive ? 1.10 : 1.0)

                    Behavior on rotation { NumberAnimation { duration: 230; easing.type: Easing.OutBack } }
                    Behavior on scale { NumberAnimation { duration: 230; easing.type: Easing.OutBack } }

                    Canvas {
                        id: tabProxyCanvas
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            ctx.strokeStyle = (root.activeTab === 3 || tabProxyMouse.containsMouse) ? Theme.accent : Theme.textSecondary;
                            ctx.fillStyle = ctx.strokeStyle;
                            ctx.lineWidth = 1.75;
                            ctx.lineCap = "round";
                            ctx.lineJoin = "round";

                            // Symmetrical cyber shield outline
                            ctx.beginPath();
                            ctx.moveTo(9, 2.5);
                            ctx.lineTo(15, 4.8);
                            ctx.lineTo(15, 9.5);
                            ctx.bezierCurveTo(15, 13.5, 12, 15.8, 9, 16.8);
                            ctx.bezierCurveTo(6, 15.8, 3, 13.5, 3, 9.5);
                            ctx.lineTo(3, 4.8);
                            ctx.closePath();
                            ctx.stroke();

                            // Crisp security checkmark
                            ctx.beginPath();
                            ctx.moveTo(6.5, 9.5);
                            ctx.lineTo(8.2, 11.3);
                            ctx.lineTo(11.8, 7.3);
                            ctx.stroke();
                        }
                        Connections {
                            target: root
                            function onActiveTabChanged() { tabProxyCanvas.requestPaint(); }
                        }
                        Connections {
                            target: tabProxyMouse
                            function onContainsMouseChanged() { tabProxyCanvas.requestPaint(); }
                        }
                    }
                }

                Text {
                    text: I18n.t("navProxy")
                    x: (parent.isActive || parent.isHover) ? 47 : 44
                    anchors.verticalCenter: parent.verticalCenter
                    color: parent.isActive ? Theme.activeTabText : (parent.isHover ? Theme.textPrimary : Theme.textSecondary)
                    font.pixelSize: 13
                    font.family: Theme.fontFamily
                    font.weight: parent.isActive ? Font.DemiBold : Font.Normal

                    Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 180 } }
                }

                // Glowing indicator when proxy is actively enabled
                Rectangle {
                    visible: (typeof proxyManager !== "undefined" && (proxyManager.warpRunning || proxyManager.enabled))
                    width: 7; height: 7; radius: 3.5
                    color: "#10b981"
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.centerIn: parent
                        width: 13; height: 13; radius: 6.5
                        color: "#10b981"
                        opacity: 0.30
                    }
                }
            }

            // ═══════════════════════════════════════════════════════
            // Tab 4: Settings
            // ═══════════════════════════════════════════════════════
            Rectangle {
                width: parent.width
                height: 42
                readonly property bool isActive: root.activeTab === 4
                readonly property bool isHover: tab3Mouse.containsMouse

                radius: (isActive || isHover) ? 14 : 9
                color: isActive ? Qt.alpha(Theme.accent, 0.20) : (isHover ? "#12ffffff" : "transparent")
                border.color: isActive ? Qt.alpha(Theme.accent, 0.45) : (isHover ? "#1affffff" : "transparent")
                border.width: 1
                opacity: isActive ? 1.0 : (isHover ? 0.94 : 0.55)

                Behavior on radius { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on border.color { ColorAnimation { duration: 200 } }
                Behavior on opacity { NumberAnimation { duration: 180 } }

                MouseArea {
                    id: tab3Mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activeTab = 4
                }

                Item {
                    width: 18; height: 18
                    x: 14
                    anchors.verticalCenter: parent.verticalCenter
                    rotation: (parent.isActive || parent.isHover) ? -8 : 0
                    scale: parent.isHover ? 1.15 : (parent.isActive ? 1.10 : 1.0)

                    Behavior on rotation { NumberAnimation { duration: 230; easing.type: Easing.OutBack } }
                    Behavior on scale { NumberAnimation { duration: 230; easing.type: Easing.OutBack } }

                    Canvas {
                        id: tab3Canvas
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            ctx.strokeStyle = (root.activeTab === 4 || tab3Mouse.containsMouse) ? Theme.accent : Theme.textSecondary;
                            ctx.lineWidth = 1.75;
                            ctx.lineCap = "round";
                            ctx.lineJoin = "round";

                            var cx = 9;
                            var cy = 9;
                            var rOuter = 7.3;
                            var rInner = 5.0;
                            var rHole = 2.3;
                            var degToRad = Math.PI / 180;

                            // Modern continuous 6-tooth gear contour
                            ctx.beginPath();
                            for (var i = 0; i < 6; i++) {
                                var mid = -90 + i * 60;
                                var a1 = (mid - 11) * degToRad;
                                var a2 = (mid + 11) * degToRad;
                                var a3 = (mid + 19) * degToRad;
                                var a4 = (mid + 41) * degToRad;

                                var x1 = cx + rOuter * Math.cos(a1);
                                var y1 = cy + rOuter * Math.sin(a1);
                                var x2 = cx + rOuter * Math.cos(a2);
                                var y2 = cy + rOuter * Math.sin(a2);
                                var x3 = cx + rInner * Math.cos(a3);
                                var y3 = cy + rInner * Math.sin(a3);
                                var x4 = cx + rInner * Math.cos(a4);
                                var y4 = cy + rInner * Math.sin(a4);

                                if (i === 0) {
                                    ctx.moveTo(x1, y1);
                                } else {
                                    ctx.lineTo(x1, y1);
                                }
                                ctx.lineTo(x2, y2);
                                ctx.lineTo(x3, y3);
                                ctx.lineTo(x4, y4);
                            }
                            ctx.closePath();
                            ctx.stroke();

                            // Center axle hole
                            ctx.beginPath();
                            ctx.arc(cx, cy, rHole, 0, Math.PI * 2);
                            ctx.stroke();
                        }
                        Connections {
                            target: root
                            function onActiveTabChanged() { tab3Canvas.requestPaint(); }
                        }
                        Connections {
                            target: tab3Mouse
                            function onContainsMouseChanged() { tab3Canvas.requestPaint(); }
                        }
                    }
                }

                Text {
                    text: I18n.t("navSettings")
                    x: (parent.isActive || parent.isHover) ? 47 : 44
                    anchors.verticalCenter: parent.verticalCenter
                    color: parent.isActive ? Theme.activeTabText : (parent.isHover ? Theme.textPrimary : Theme.textSecondary)
                    font.pixelSize: 13
                    font.family: Theme.fontFamily
                    font.weight: parent.isActive ? Font.DemiBold : Font.Normal

                    Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 180 } }
                }
            }
        }
    }
}
