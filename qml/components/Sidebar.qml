import QtQuick
import YuYuInstaller

Rectangle {
    id: root
    implicitWidth: 220
    color: Theme.bgSidebar
    border.color: Theme.borderDim
    border.width: 1

    property int activeTab: 0 // 0: Dashboard, 1: Queue, 2: Updates, 3: Proxy, 4: Settings

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 24

        // Logo & Branding
        Row {
            spacing: 12
            Rectangle {
                width: 42
                height: 42
                radius: 12
                color: Theme.bgElevated
                border.color: Theme.borderBright
                border.width: 1
                clip: true

                Image {
                    anchors.fill: parent
                    anchors.margins: 2
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

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.borderDim
        }

        // Navigation Menu
        Column {
            width: parent.width
            spacing: 6

            // Tab 0: Dashboard (Downloader)
            Rectangle {
                width: parent.width
                height: 42
                radius: Theme.radiusMd
                color: (root.activeTab === 0) ? Theme.activeTabBg : (tab0Mouse.containsMouse ? Theme.bgCardHover : "transparent")
                border.color: (root.activeTab === 0) ? Theme.activeTabBorder : "transparent"
                border.width: 1

                // Left vertical neon indicator line (like the screenshot)
                Rectangle {
                    width: 3
                    height: 18
                    radius: 2
                    color: Theme.activeTabIndicator
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.activeTab === 0
                }

                MouseArea {
                    id: tab0Mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activeTab = 0
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 12
                    spacing: 12

                    Item {
                        width: 18; height: 18
                        anchors.verticalCenter: parent.verticalCenter
                        Canvas {
                            id: tab0Canvas
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                ctx.strokeStyle = (root.activeTab === 0) ? Theme.accent : (tab0Mouse.containsMouse ? Theme.textPrimary : Theme.textSecondary);
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
                        color: (root.activeTab === 0) ? Theme.activeTabText : (tab0Mouse.containsMouse ? Theme.textPrimary : Theme.textSecondary)
                        font.pixelSize: 13
                        font.family: Theme.fontFamily
                        font.weight: (root.activeTab === 0) ? Font.DemiBold : Font.Normal
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Tab 1: Queue
            Rectangle {
                width: parent.width
                height: 42
                radius: Theme.radiusMd
                color: (root.activeTab === 1) ? Theme.activeTabBg : (tab1Mouse.containsMouse ? Theme.bgCardHover : "transparent")
                border.color: (root.activeTab === 1) ? Theme.activeTabBorder : "transparent"
                border.width: 1

                // Left vertical neon indicator line
                Rectangle {
                    width: 3
                    height: 18
                    radius: 2
                    color: Theme.activeTabIndicator
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.activeTab === 1
                }

                MouseArea {
                    id: tab1Mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activeTab = 1
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 12
                    spacing: 12

                    Item {
                        width: 18; height: 18
                        anchors.verticalCenter: parent.verticalCenter
                        Canvas {
                            id: tab1Canvas
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                ctx.strokeStyle = (root.activeTab === 1) ? Theme.accent : (tab1Mouse.containsMouse ? Theme.textPrimary : Theme.textSecondary);
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
                        color: (root.activeTab === 1) ? Theme.activeTabText : (tab1Mouse.containsMouse ? Theme.textPrimary : Theme.textSecondary)
                        font.pixelSize: 13
                        font.family: Theme.fontFamily
                        font.weight: (root.activeTab === 1) ? Font.DemiBold : Font.Normal
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Item { width: 10; height: 1 }

                    // Badge for active downloads count
                    Rectangle {
                        visible: queueModel.activeDownloadCount > 0
                        width: 20
                        height: 20
                        radius: 10
                        color: Theme.accent
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: queueModel.activeDownloadCount
                            color: "#07090e"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }
                }
            }

            // Tab 2: Updates
            Rectangle {
                width: parent.width
                height: 42
                radius: Theme.radiusMd
                color: (root.activeTab === 2) ? Theme.activeTabBg : (tab2Mouse.containsMouse ? Theme.bgCardHover : "transparent")
                border.color: (root.activeTab === 2) ? Theme.activeTabBorder : "transparent"
                border.width: 1

                // Left vertical neon indicator line
                Rectangle {
                    width: 3
                    height: 18
                    radius: 2
                    color: Theme.activeTabIndicator
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.activeTab === 2
                }

                MouseArea {
                    id: tab2Mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activeTab = 2
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 12
                    spacing: 12

                    Item {
                        width: 18; height: 18
                        anchors.verticalCenter: parent.verticalCenter
                        Canvas {
                            id: tab2Canvas
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                ctx.strokeStyle = (root.activeTab === 2) ? Theme.accent : (tab2Mouse.containsMouse ? Theme.textPrimary : Theme.textSecondary);
                                ctx.fillStyle = ctx.strokeStyle;
                                ctx.lineWidth = 1.75;
                                ctx.lineCap = "round";
                                ctx.lineJoin = "round";

                                // Top arc
                                ctx.beginPath();
                                ctx.arc(9, 9, 5.5, -Math.PI * 0.25, Math.PI * 0.65);
                                ctx.stroke();

                                // Top-right arrow head
                                ctx.beginPath();
                                ctx.moveTo(11, 3);
                                ctx.lineTo(14.2, 4.5);
                                ctx.lineTo(13.2, 7.8);
                                ctx.stroke();

                                // Bottom arc
                                ctx.beginPath();
                                ctx.arc(9, 9, 5.5, Math.PI * 0.75, Math.PI * 1.65);
                                ctx.stroke();

                                // Bottom-left arrow head
                                ctx.beginPath();
                                ctx.moveTo(7, 15);
                                ctx.lineTo(3.8, 13.5);
                                ctx.lineTo(4.8, 10.2);
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
                        color: (root.activeTab === 2) ? Theme.activeTabText : (tab2Mouse.containsMouse ? Theme.textPrimary : Theme.textSecondary)
                        font.pixelSize: 13
                        font.family: Theme.fontFamily
                        font.weight: (root.activeTab === 2) ? Font.DemiBold : Font.Normal
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Neon update notification badge with gentle breathing pulse
                    Item {
                        width: 14; height: 14
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
            }

            // Tab 3: Proxy & Privacy
            Rectangle {
                width: parent.width
                height: 42
                radius: Theme.radiusMd
                color: (root.activeTab === 3) ? Theme.activeTabBg : (tabProxyMouse.containsMouse ? Theme.bgCardHover : "transparent")
                border.color: (root.activeTab === 3) ? Theme.activeTabBorder : "transparent"
                border.width: 1

                // Left vertical neon indicator line
                Rectangle {
                    width: 3
                    height: 18
                    radius: 2
                    color: Theme.activeTabIndicator
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.activeTab === 3
                }

                MouseArea {
                    id: tabProxyMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activeTab = 3
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 12
                    spacing: 12

                    Item {
                        width: 18; height: 18
                        anchors.verticalCenter: parent.verticalCenter
                        Canvas {
                            id: tabProxyCanvas
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                ctx.strokeStyle = (root.activeTab === 3) ? Theme.accent : (tabProxyMouse.containsMouse ? Theme.textPrimary : Theme.textSecondary);
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
                        color: (root.activeTab === 3) ? Theme.activeTabText : (tabProxyMouse.containsMouse ? Theme.textPrimary : Theme.textSecondary)
                        font.pixelSize: 13
                        font.family: Theme.fontFamily
                        font.weight: (root.activeTab === 3) ? Font.DemiBold : Font.Normal
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Item { width: 4; height: 1 }

                    // Glowing green indicator when proxy is actively enabled
                    Rectangle {
                        visible: (typeof proxyManager !== "undefined" && proxyManager.enabled && proxyManager.proxyMode !== 0)
                        width: 7; height: 7; radius: 3.5
                        color: "#00d29d"
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            anchors.centerIn: parent
                            width: 12; height: 12; radius: 6
                            color: "#00d29d"
                            opacity: 0.35
                        }
                    }
                }
            }

            // Tab 4: Settings
            Rectangle {
                width: parent.width
                height: 42
                radius: Theme.radiusMd
                color: (root.activeTab === 4) ? Theme.activeTabBg : (tab3Mouse.containsMouse ? Theme.bgCardHover : "transparent")
                border.color: (root.activeTab === 4) ? Theme.activeTabBorder : "transparent"
                border.width: 1

                // Left vertical neon indicator line
                Rectangle {
                    width: 3
                    height: 18
                    radius: 2
                    color: Theme.activeTabIndicator
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.activeTab === 4
                }

                MouseArea {
                    id: tab3Mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activeTab = 4
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 12
                    spacing: 12

                    Item {
                        width: 18; height: 18
                        anchors.verticalCenter: parent.verticalCenter
                        Canvas {
                            id: tab3Canvas
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                ctx.strokeStyle = (root.activeTab === 4) ? Theme.accent : (tab3Mouse.containsMouse ? Theme.textPrimary : Theme.textSecondary);
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
                        color: (root.activeTab === 4) ? Theme.activeTabText : (tab3Mouse.containsMouse ? Theme.textPrimary : Theme.textSecondary)
                        font.pixelSize: 13
                        font.family: Theme.fontFamily
                        font.weight: (root.activeTab === 4) ? Font.DemiBold : Font.Normal
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }


    }
}
