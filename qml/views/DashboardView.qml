import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import YuYuInstaller

Item {
    id: root

    property string currentErrorMessage: ""

    signal navigateToQueue()

    Connections {
        target: urlAnalyzer
        function onAnalysisError(msg) {
            root.currentErrorMessage = msg
        }
        function onAnalysisSuccess(info) {
            root.currentErrorMessage = ""
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
            spacing: 24

            // Welcome & Title (Ortalanmış ve Ferah)
            Column {
                width: parent.width
                spacing: 8
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: I18n.t("dashTitle")
                    color: Theme.textPrimary
                    font.pixelSize: 28
                    font.family: Theme.fontFamily
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: I18n.t("dashSubtitle")
                    color: Theme.textSecondary
                    font.pixelSize: 13
                    font.family: Theme.fontFamily
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // URL Input Area
            UrlInputField {
                id: urlInputField
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                onAnalyzeRequested: function(rawUrl) {
                    root.currentErrorMessage = ""
                    urlAnalyzer.analyzeUrl(rawUrl)
                }
            }

            // Error banner (if any)
            Rectangle {
                id: errorBanner
                visible: root.currentErrorMessage.length > 0
                width: parent.width
                implicitHeight: visible ? (errorRow.implicitHeight + 28) : 0
                height: implicitHeight
                radius: Theme.radiusMd
                color: Theme.error + "18"
                border.color: Theme.error + "55"
                border.width: 1

                RowLayout {
                    id: errorRow
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 14
                    spacing: 12

                    Rectangle {
                        width: 22
                        height: 22
                        radius: 11
                        color: Theme.error
                        Layout.alignment: Qt.AlignTop

                        Text {
                            anchors.centerIn: parent
                            text: "!"
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.currentErrorMessage
                        color: Theme.error
                        font.pixelSize: 12
                        font.family: Theme.fontFamily
                        font.weight: Font.Medium
                        wrapMode: Text.WordWrap
                        lineHeight: 1.25
                    }
                }
            }

            // Quality & Format Selector (visible when url is analyzed)
            QualitySelector {
                id: qualityBox
                width: parent.width
                visible: urlAnalyzer.currentMediaInfo !== null
                mediaInfo: urlAnalyzer.currentMediaInfo

                onDownloadTriggered: function(url, title, formatId, folder) {
                    downloadManager.addDownload(url, title, formatId, folder)
                    urlInputField.clear()
                    urlAnalyzer.clear()
                    root.navigateToQueue()
                }
            }
        }
    }
}
