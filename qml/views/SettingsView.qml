import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import YuYuInstaller

Item {
    id: root

    FolderDialog {
        id: folderDialog
        title: I18n.t("storageSection")
        currentFolder: "file:///" + downloadManager.defaultDownloadPath
        onAccepted: {
            var path = selectedFolder.toString().replace("file:///", "")
            downloadManager.setDefaultDownloadPath(path)
        }
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
            spacing: 22

            // Page Header
            Column {
                spacing: 4
                Text {
                    text: I18n.t("settingsTitle")
                    color: Theme.textPrimary
                    font.pixelSize: 22
                    font.family: Theme.fontFamily
                    font.weight: Font.Bold
                }
                Text {
                    text: I18n.t("settingsSubtitle")
                    color: Theme.textSecondary
                    font.pixelSize: 13
                    font.family: Theme.fontFamily
                }
            }

            // ═══════════════════════════════════════════════════════════
            // GROUP 1: GENERAL (Language + Video Background)
            // ═══════════════════════════════════════════════════════════
            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: I18n.language === "tr" ? "GENEL GÖRÜNÜM" : (I18n.language === "uk" ? "ЗАГАЛЬНІ" : "GENERAL & APPEARANCE")
                    color: Theme.textSecondary
                    font.pixelSize: 11
                    font.family: Theme.fontFamily
                    font.weight: Font.Bold
                    font.letterSpacing: 0.8
                }

                Rectangle {
                    width: parent.width
                    implicitHeight: generalCol.implicitHeight
                    radius: Theme.radiusLg
                    color: Theme.bgCard
                    border.color: Theme.borderDim
                    border.width: 1

                    Column {
                        id: generalCol
                        width: parent.width

                        // Row 1: Display Language
                        Item {
                            width: parent.width
                            height: 108

                            Column {
                                anchors.fill: parent
                                anchors.margins: 18
                                spacing: 12

                                Row {
                                    spacing: 8
                                    Text {
                                        text: I18n.t("langSection")
                                        color: Theme.textPrimary
                                        font.pixelSize: 13
                                        font.family: Theme.fontFamily
                                        font.weight: Font.DemiBold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "• " + I18n.t("langSubtitle")
                                        color: Theme.textMuted
                                        font.pixelSize: 11
                                        font.family: Theme.fontFamily
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Row {
                                    width: parent.width
                                    spacing: 10

                                    // English
                                    Rectangle {
                                        width: (parent.width - 20) / 3
                                        height: 38
                                        radius: Theme.radiusMd
                                        color: (I18n.language === "en") ? Theme.activeTabBg : (enMouse.containsMouse ? "#1affffff" : Theme.bgElevated)
                                        border.color: (I18n.language === "en") ? Theme.accent : Theme.borderDim
                                        border.width: 1

                                        Behavior on color { ColorAnimation { duration: 150 } }
                                        Behavior on border.color { ColorAnimation { duration: 150 } }

                                        MouseArea {
                                            id: enMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: I18n.setLanguage("en")
                                        }

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 8
                                            Rectangle {
                                                width: 24; height: 18; radius: 5
                                                color: (I18n.language === "en") ? Theme.accent : "#1fffffff"
                                                anchors.verticalCenter: parent.verticalCenter
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "EN"
                                                    color: (I18n.language === "en") ? "#07090e" : Theme.textSecondary
                                                    font.pixelSize: 10
                                                    font.family: Theme.fontFamily
                                                    font.weight: Font.Bold
                                                }
                                            }
                                            Text {
                                                text: I18n.t("langEn")
                                                color: (I18n.language === "en") ? Theme.textPrimary : Theme.textSecondary
                                                font.pixelSize: 12
                                                font.family: Theme.fontFamily
                                                font.weight: (I18n.language === "en") ? Font.DemiBold : Font.Normal
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                    }

                                    // Türkçe
                                    Rectangle {
                                        width: (parent.width - 20) / 3
                                        height: 38
                                        radius: Theme.radiusMd
                                        color: (I18n.language === "tr") ? Theme.activeTabBg : (trMouse.containsMouse ? "#1affffff" : Theme.bgElevated)
                                        border.color: (I18n.language === "tr") ? Theme.accent : Theme.borderDim
                                        border.width: 1

                                        Behavior on color { ColorAnimation { duration: 150 } }
                                        Behavior on border.color { ColorAnimation { duration: 150 } }

                                        MouseArea {
                                            id: trMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: I18n.setLanguage("tr")
                                        }

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 8
                                            Rectangle {
                                                width: 24; height: 18; radius: 5
                                                color: (I18n.language === "tr") ? Theme.accent : "#1fffffff"
                                                anchors.verticalCenter: parent.verticalCenter
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "TR"
                                                    color: (I18n.language === "tr") ? "#07090e" : Theme.textSecondary
                                                    font.pixelSize: 10
                                                    font.family: Theme.fontFamily
                                                    font.weight: Font.Bold
                                                }
                                            }
                                            Text {
                                                text: I18n.t("langTr")
                                                color: (I18n.language === "tr") ? Theme.textPrimary : Theme.textSecondary
                                                font.pixelSize: 12
                                                font.family: Theme.fontFamily
                                                font.weight: (I18n.language === "tr") ? Font.DemiBold : Font.Normal
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                    }

                                    // Українська
                                    Rectangle {
                                        width: (parent.width - 20) / 3
                                        height: 38
                                        radius: Theme.radiusMd
                                        color: (I18n.language === "uk") ? Theme.activeTabBg : (ukMouse.containsMouse ? "#1affffff" : Theme.bgElevated)
                                        border.color: (I18n.language === "uk") ? Theme.accent : Theme.borderDim
                                        border.width: 1

                                        Behavior on color { ColorAnimation { duration: 150 } }
                                        Behavior on border.color { ColorAnimation { duration: 150 } }

                                        MouseArea {
                                            id: ukMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: I18n.setLanguage("uk")
                                        }

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 8
                                            Rectangle {
                                                width: 24; height: 18; radius: 5
                                                color: (I18n.language === "uk") ? Theme.accent : "#1fffffff"
                                                anchors.verticalCenter: parent.verticalCenter
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "UA"
                                                    color: (I18n.language === "uk") ? "#07090e" : Theme.textSecondary
                                                    font.pixelSize: 10
                                                    font.family: Theme.fontFamily
                                                    font.weight: Font.Bold
                                                }
                                            }
                                            Text {
                                                text: I18n.t("langUk")
                                                color: (I18n.language === "uk") ? Theme.textPrimary : Theme.textSecondary
                                                font.pixelSize: 12
                                                font.family: Theme.fontFamily
                                                font.weight: (I18n.language === "uk") ? Font.DemiBold : Font.Normal
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Thin divider
                        Rectangle {
                            width: parent.width - 36
                            height: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Theme.borderDim
                        }

                        // Row 2: Video Background Toggle
                        Item {
                            width: parent.width
                            height: 62

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 18
                                anchors.rightMargin: 18
                                spacing: 16

                                Row {
                                    width: parent.width - toggleSwitch.width - 16
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 8

                                    Text {
                                        text: I18n.t("videoBgSection")
                                        color: Theme.textPrimary
                                        font.pixelSize: 13
                                        font.family: Theme.fontFamily
                                        font.weight: Font.DemiBold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "• " + (downloadManager.videoBackgroundEnabled ? I18n.t("videoBgEnabled") : I18n.t("videoBgDisabled"))
                                        color: downloadManager.videoBackgroundEnabled ? Theme.textSecondary : Theme.textMuted
                                        font.pixelSize: 11
                                        font.family: Theme.fontFamily
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Rectangle {
                                    id: toggleSwitch
                                    width: 48
                                    height: 26
                                    radius: 13
                                    color: downloadManager.videoBackgroundEnabled ? Theme.accent : Theme.bgElevated
                                    border.color: downloadManager.videoBackgroundEnabled ? Theme.accent : Theme.borderDim
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter

                                    Behavior on color { ColorAnimation { duration: 180 } }

                                    Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: downloadManager.videoBackgroundEnabled ? "#07090e" : Theme.textSecondary
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: downloadManager.videoBackgroundEnabled ? (parent.width - width - 3) : 3

                                        Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: downloadManager.setVideoBackgroundEnabled(!downloadManager.videoBackgroundEnabled)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ═══════════════════════════════════════════════════════════
            // GROUP 2: STORAGE (Download Folder)
            // ═══════════════════════════════════════════════════════════
            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: I18n.language === "tr" ? "DEPOLAMA" : (I18n.language === "uk" ? "СХОВИЩЕ" : "STORAGE")
                    color: Theme.textSecondary
                    font.pixelSize: 11
                    font.family: Theme.fontFamily
                    font.weight: Font.Bold
                    font.letterSpacing: 0.8
                }

                Rectangle {
                    width: parent.width
                    implicitHeight: 104
                    radius: Theme.radiusLg
                    color: Theme.bgCard
                    border.color: Theme.borderDim
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 10

                        Text {
                            text: I18n.t("storageSection")
                            color: Theme.textPrimary
                            font.pixelSize: 13
                            font.family: Theme.fontFamily
                            font.weight: Font.DemiBold
                        }

                        Row {
                            width: parent.width
                            spacing: 10

                            Rectangle {
                                width: parent.width - 110
                                height: 38
                                radius: Theme.radiusMd
                                color: Theme.bgInput
                                border.color: Theme.borderDim
                                border.width: 1

                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    text: downloadManager.defaultDownloadPath
                                    color: Theme.textSecondary
                                    font.pixelSize: 12
                                    font.family: Theme.fontFamily
                                    elide: Text.ElideMiddle
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Rectangle {
                                width: 100
                                height: 38
                                radius: Theme.radiusMd
                                color: dirMouse.containsMouse ? "#22ffffff" : Theme.bgElevated
                                border.color: dirMouse.containsMouse ? Theme.borderBright : Theme.borderDim
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 150 } }
                                Behavior on border.color { ColorAnimation { duration: 150 } }

                                MouseArea {
                                    id: dirMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: folderDialog.open()
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: I18n.t("browse")
                                    color: Theme.textPrimary
                                    font.pixelSize: 12
                                    font.family: Theme.fontFamily
                                    font.weight: Font.Medium
                                }
                            }
                        }
                    }
                }
            }

            // ═══════════════════════════════════════════════════════════
            // GROUP 3: CORE ENGINES (FFmpeg + yt-dlp + C++20 in one grouped card)
            // ═══════════════════════════════════════════════════════════
            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: I18n.language === "tr" ? "MEDYA MOTORLARI" : (I18n.language === "uk" ? "МЕДІА РУШІЇ" : "MEDIA ENGINES")
                    color: Theme.textSecondary
                    font.pixelSize: 11
                    font.family: Theme.fontFamily
                    font.weight: Font.Bold
                    font.letterSpacing: 0.8
                }

                Rectangle {
                    width: parent.width
                    implicitHeight: enginesCol.implicitHeight
                    radius: Theme.radiusLg
                    color: Theme.bgCard
                    border.color: Theme.borderDim
                    border.width: 1

                    Column {
                        id: enginesCol
                        width: parent.width

                        // Engine Row 1: FFmpeg
                        Item {
                            width: parent.width
                            height: 68

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 18
                                anchors.rightMargin: 18
                                spacing: 14

                                Rectangle {
                                    width: 38; height: 38
                                    radius: Theme.radiusMd
                                    color: Theme.bgElevated
                                    border.color: Theme.borderDim
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Image {
                                        anchors.centerIn: parent
                                        width: 22; height: 22
                                        source: "qrc:/qt/qml/YuYuInstaller/assets/ffmpeg.png"
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                        mipmap: true
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2
                                    width: parent.width - 140

                                    Text {
                                        text: I18n.t("ffmpegTitle")
                                        color: Theme.textPrimary
                                        font.pixelSize: 13
                                        font.family: Theme.fontFamily
                                        font.weight: Font.DemiBold
                                    }
                                    Text {
                                        text: ffmpegProcessor.isFFmpegAvailable ? I18n.t("ffmpegAvailable") : I18n.t("ffmpegNotFound")
                                        color: Theme.textMuted
                                        font.pixelSize: 11
                                        font.family: Theme.fontFamily
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                }

                                Row {
                                    spacing: 6
                                    anchors.verticalCenter: parent.verticalCenter
                                    Rectangle {
                                        width: 7; height: 7; radius: 3.5
                                        color: ffmpegProcessor.isFFmpegAvailable ? "#10b981" : Theme.error
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: ffmpegProcessor.isFFmpegAvailable ? I18n.t("readyStatus") : I18n.t("missingStatus")
                                        color: ffmpegProcessor.isFFmpegAvailable ? "#10b981" : Theme.error
                                        font.pixelSize: 11
                                        font.family: Theme.fontFamily
                                        font.weight: Font.DemiBold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width - 36
                            height: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Theme.borderDim
                        }

                        // Engine Row 2: yt-dlp
                        Item {
                            width: parent.width
                            height: 68

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 18
                                anchors.rightMargin: 18
                                spacing: 14

                                Rectangle {
                                    width: 38; height: 38
                                    radius: Theme.radiusMd
                                    color: Theme.bgElevated
                                    border.color: Theme.borderDim
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Image {
                                        anchors.centerIn: parent
                                        width: 22; height: 22
                                        source: "qrc:/qt/qml/YuYuInstaller/assets/ytdlp.png"
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                        mipmap: true
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2
                                    width: parent.width - 140

                                    Text {
                                        text: I18n.t("ytdlpTitle")
                                        color: Theme.textPrimary
                                        font.pixelSize: 13
                                        font.family: Theme.fontFamily
                                        font.weight: Font.DemiBold
                                    }
                                    Text {
                                        text: ffmpegProcessor.isYtDlpAvailable ? I18n.t("ytdlpAvailable") : I18n.t("ytdlpNotFound")
                                        color: Theme.textMuted
                                        font.pixelSize: 11
                                        font.family: Theme.fontFamily
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                }

                                Row {
                                    spacing: 6
                                    anchors.verticalCenter: parent.verticalCenter
                                    Rectangle {
                                        width: 7; height: 7; radius: 3.5
                                        color: ffmpegProcessor.isYtDlpAvailable ? "#10b981" : Theme.error
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: ffmpegProcessor.isYtDlpAvailable ? I18n.t("readyStatus") : I18n.t("missingStatus")
                                        color: ffmpegProcessor.isYtDlpAvailable ? "#10b981" : Theme.error
                                        font.pixelSize: 11
                                        font.family: Theme.fontFamily
                                        font.weight: Font.DemiBold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width - 36
                            height: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Theme.borderDim
                        }

                        // Engine Row 3: C++20 Turbo Stream
                        Item {
                            width: parent.width
                            height: 68

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 18
                                anchors.rightMargin: 18
                                spacing: 14

                                Rectangle {
                                    width: 38; height: 38
                                    radius: Theme.radiusMd
                                    color: Theme.bgElevated
                                    border.color: Theme.borderDim
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter

                                    Item {
                                        anchors.centerIn: parent
                                        width: 20; height: 20
                                        Canvas {
                                            anchors.fill: parent
                                            onPaint: {
                                                var ctx = getContext("2d");
                                                ctx.reset();
                                                ctx.strokeStyle = Theme.textSecondary;
                                                ctx.lineWidth = 1.6;
                                                ctx.strokeRect(4, 4, 12, 12);
                                                ctx.beginPath();
                                                ctx.moveTo(7, 1.5); ctx.lineTo(7, 4);
                                                ctx.moveTo(13, 1.5); ctx.lineTo(13, 4);
                                                ctx.moveTo(7, 16); ctx.lineTo(7, 18.5);
                                                ctx.moveTo(13, 16); ctx.lineTo(13, 18.5);
                                                ctx.moveTo(1.5, 7); ctx.lineTo(4, 7);
                                                ctx.moveTo(1.5, 13); ctx.lineTo(4, 13);
                                                ctx.moveTo(16, 7); ctx.lineTo(18.5, 7);
                                                ctx.moveTo(16, 13); ctx.lineTo(18.5, 13);
                                                ctx.stroke();
                                            }
                                        }
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2
                                    width: parent.width - 140

                                    Text {
                                        text: I18n.t("coreEngineTitle")
                                        color: Theme.textPrimary
                                        font.pixelSize: 13
                                        font.family: Theme.fontFamily
                                        font.weight: Font.DemiBold
                                    }
                                    Text {
                                        text: I18n.t("coreEngineDesc")
                                        color: Theme.textMuted
                                        font.pixelSize: 11
                                        font.family: Theme.fontFamily
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                }

                                Row {
                                    spacing: 6
                                    anchors.verticalCenter: parent.verticalCenter
                                    Rectangle {
                                        width: 7; height: 7; radius: 3.5
                                        color: "#10b981"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: I18n.t("readyStatus")
                                        color: "#10b981"
                                        font.pixelSize: 11
                                        font.family: Theme.fontFamily
                                        font.weight: Font.DemiBold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ═══════════════════════════════════════════════════════════
            // GROUP 4: SYSTEM & ABOUT (Diagnostics + Architecture Info)
            // ═══════════════════════════════════════════════════════════
            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: I18n.language === "tr" ? "TANILAMA & HAKKINDA" : (I18n.language === "uk" ? "ДІАГНОСТИКА ТА ПРО ПРОГРАМУ" : "DIAGNOSTICS & ABOUT")
                    color: Theme.textSecondary
                    font.pixelSize: 11
                    font.family: Theme.fontFamily
                    font.weight: Font.Bold
                    font.letterSpacing: 0.8
                }

                Rectangle {
                    width: parent.width
                    implicitHeight: sysCol.implicitHeight
                    radius: Theme.radiusLg
                    color: Theme.bgCard
                    border.color: Theme.borderDim
                    border.width: 1

                    Column {
                        id: sysCol
                        width: parent.width

                        // Row 1: Diagnostics
                        Item {
                            width: parent.width
                            height: 68

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 18
                                anchors.rightMargin: 18
                                spacing: 14

                                Rectangle {
                                    width: 38; height: 38
                                    radius: Theme.radiusMd
                                    color: Theme.bgElevated
                                    border.color: Theme.borderDim
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter

                                    Item {
                                        anchors.centerIn: parent
                                        width: 20; height: 20
                                        Canvas {
                                            anchors.fill: parent
                                            onPaint: {
                                                var ctx = getContext("2d");
                                                ctx.reset();
                                                ctx.strokeStyle = Theme.textSecondary;
                                                ctx.lineWidth = 1.6;
                                                ctx.strokeRect(3, 2, 14, 16);
                                                ctx.beginPath();
                                                ctx.moveTo(6, 6.5); ctx.lineTo(14, 6.5);
                                                ctx.moveTo(6, 10); ctx.lineTo(14, 10);
                                                ctx.moveTo(6, 13.5); ctx.lineTo(11, 13.5);
                                                ctx.stroke();
                                            }
                                        }
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2
                                    width: parent.width - 38 - 14 - 210

                                    Text {
                                        text: I18n.t("diagnosticsSection")
                                        color: Theme.textPrimary
                                        font.pixelSize: 13
                                        font.family: Theme.fontFamily
                                        font.weight: Font.DemiBold
                                    }
                                    Text {
                                        text: I18n.t("diagnosticsSubtitle")
                                        color: Theme.textMuted
                                        font.pixelSize: 11
                                        font.family: Theme.fontFamily
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                }

                                Row {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 8

                                    Rectangle {
                                        width: 102
                                        height: 32
                                        radius: Theme.radiusMd
                                        color: openLogBtnMouse.containsMouse ? "#22ffffff" : Theme.bgElevated
                                        border.color: openLogBtnMouse.containsMouse ? Theme.borderBright : Theme.borderDim
                                        border.width: 1

                                        Behavior on color { ColorAnimation { duration: 150 } }
                                        Behavior on border.color { ColorAnimation { duration: 150 } }

                                        MouseArea {
                                            id: openLogBtnMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (typeof downloadManager !== "undefined" && downloadManager) {
                                                    downloadManager.openLogFile()
                                                }
                                            }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: I18n.t("openLogBtn")
                                            color: openLogBtnMouse.containsMouse ? Theme.textPrimary : Theme.textSecondary
                                            font.pixelSize: 11
                                            font.family: Theme.fontFamily
                                            font.weight: Font.Medium
                                        }
                                    }

                                    Rectangle {
                                        width: 84
                                        height: 32
                                        radius: Theme.radiusMd
                                        color: clearLogBtnMouse.containsMouse ? Qt.alpha(Theme.error, 0.14) : "transparent"
                                        border.color: clearLogBtnMouse.containsMouse ? Qt.alpha(Theme.error, 0.45) : Theme.borderDim
                                        border.width: 1

                                        Behavior on color { ColorAnimation { duration: 150 } }
                                        Behavior on border.color { ColorAnimation { duration: 150 } }

                                        MouseArea {
                                            id: clearLogBtnMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (typeof downloadManager !== "undefined" && downloadManager) {
                                                    downloadManager.clearLogFile()
                                                }
                                            }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: I18n.t("clearLogBtn")
                                            color: clearLogBtnMouse.containsMouse ? Theme.error : Theme.textSecondary
                                            font.pixelSize: 11
                                            font.family: Theme.fontFamily
                                            font.weight: Font.Medium
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width - 36
                            height: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Theme.borderDim
                        }

                        // Row 2: About
                        Item {
                            width: parent.width
                            implicitHeight: aboutCol.implicitHeight + 28

                            Column {
                                id: aboutCol
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 18
                                anchors.rightMargin: 18
                                spacing: 6

                                Row {
                                    spacing: 10
                                    Text {
                                        text: I18n.t("aboutTitle")
                                        color: Theme.textPrimary
                                        font.pixelSize: 13
                                        font.family: Theme.fontFamily
                                        font.weight: Font.DemiBold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "• " + I18n.t("aboutVersion")
                                        color: Theme.textMuted
                                        font.pixelSize: 11
                                        font.family: Theme.fontFamily
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Text {
                                    text: I18n.t("aboutDesc")
                                    color: Theme.textSecondary
                                    font.pixelSize: 12
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
}
