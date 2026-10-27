import QtQuick
import QtQuick.Controls
import YuYuInstaller

Item {
    id: root
    implicitHeight: 64
    implicitWidth: 600

    property alias text: textInput.text
    signal analyzeRequested(string url)

    function clear() {
        textInput.text = ""
    }

    Rectangle {
        id: container
        anchors.fill: parent
        radius: 20
        color: Theme.bgInput
        border.color: textInput.activeFocus ? Theme.borderHighlight : (containerHover.hovered ? Theme.borderBright : Theme.borderDim)
        border.width: textInput.activeFocus ? 2 : 1

        Behavior on border.color {
            ColorAnimation { duration: 150 }
        }

        HoverHandler { id: containerHover }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 10
            anchors.topMargin: 8
            anchors.bottomMargin: 8
            spacing: 12

            // Link Vector Icon
            Item {
                width: 20; height: 20
                anchors.verticalCenter: parent.verticalCenter
                Canvas {
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        ctx.strokeStyle = Theme.accent;
                        ctx.lineWidth = 1.8;
                        ctx.lineCap = "round";

                        // Left link loop
                        ctx.beginPath();
                        ctx.arc(7.5, 10, 3.8, Math.PI * 0.5, Math.PI * 1.5);
                        ctx.stroke();

                        // Right link loop
                        ctx.beginPath();
                        ctx.arc(12.5, 10, 3.8, -Math.PI * 0.5, Math.PI * 0.5);
                        ctx.stroke();

                        // Center connecting bar
                        ctx.beginPath();
                        ctx.moveTo(7, 10);
                        ctx.lineTo(13, 10);
                        ctx.stroke();
                    }
                }
            }

            // Input Field
            TextInput {
                id: textInput
                width: parent.width - 248
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.textPrimary
                font.pixelSize: 14
                font.family: Theme.fontFamily
                selectByMouse: true
                selectionColor: Theme.accent
                selectedTextColor: "#FFFFFF"
                clip: true

                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    text: I18n.t("urlPlaceholder")
                    color: Theme.textMuted
                    font.pixelSize: 13
                    font.family: Theme.fontFamily
                    elide: Text.ElideRight
                    visible: !textInput.text && !textInput.activeFocus
                }

                Keys.onReturnPressed: {
                    if (textInput.text.trim().length > 0 && !urlAnalyzer.isAnalyzing) {
                        root.analyzeRequested(textInput.text.trim())
                    }
                }
            }

            // Paste Button (Tatlı Frosted Glass Pill)
            Rectangle {
                id: pasteBtn
                width: 76
                height: 38
                anchors.verticalCenter: parent.verticalCenter
                radius: 19
                color: pasteHover.hovered ? "#35ffffff" : "#18ffffff"
                border.color: pasteHover.hovered ? Theme.accent : "#25ffffff"
                border.width: 1
                scale: pasteTap.pressed ? 0.94 : (pasteHover.hovered ? 1.05 : 1.0)

                Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutQuad } }
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                HoverHandler {
                    id: pasteHover
                    cursorShape: Qt.PointingHandCursor
                }

                Text {
                    anchors.centerIn: parent
                    text: I18n.t("pasteBtn")
                    color: pasteHover.hovered ? "#ffffff" : Theme.textSecondary
                    font.pixelSize: 12
                    font.family: Theme.fontFamily
                    font.weight: Font.DemiBold
                }

                TapHandler {
                    id: pasteTap
                    onTapped: {
                        textInput.paste()
                        if (textInput.text.trim().length > 0) {
                            root.analyzeRequested(textInput.text.trim())
                        }
                    }
                }
            }

            // Analyze Button (Tatlı Glowing Neon Pill)
            Item {
                width: 114
                height: 42
                anchors.verticalCenter: parent.verticalCenter

                // Soft neon aura glow behind the button
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 6
                    height: parent.height + 6
                    radius: 24
                    color: Theme.accent
                    opacity: (analyzeHover.hovered && analyzeBtn.enabled) ? 0.40 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 180 } }
                }

                Rectangle {
                    id: analyzeBtn
                    anchors.fill: parent
                    radius: 21
                    enabled: !urlAnalyzer.isAnalyzing && textInput.text.trim().length > 0
                    opacity: enabled ? 1.0 : 0.55
                    scale: analyzeTap.pressed ? 0.94 : (analyzeHover.hovered && enabled ? 1.04 : 1.0)

                    Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutQuad } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: analyzeHover.hovered ? Theme.accentHover : Theme.accent }
                        GradientStop { position: 1.0; color: analyzeHover.hovered ? Theme.accentCyan : Theme.accentBlue }
                    }

                    HoverHandler {
                        id: analyzeHover
                        cursorShape: analyzeBtn.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            id: spinner
                            text: "⟳"
                            color: "#070a12"
                            font.pixelSize: 15
                            font.bold: true
                            visible: urlAnalyzer.isAnalyzing

                            NumberAnimation on rotation {
                                from: 0; to: 360
                                duration: 900
                                loops: Animation.Infinite
                                running: urlAnalyzer.isAnalyzing
                            }
                        }

                        Text {
                            text: urlAnalyzer.isAnalyzing ? "..." : I18n.t("analyzeBtn")
                            color: "#070a12"
                            font.pixelSize: 13
                            font.family: Theme.fontFamily
                            font.weight: Font.Bold
                        }
                    }

                    TapHandler {
                        id: analyzeTap
                        onTapped: {
                            if (textInput.text.trim().length > 0 && !urlAnalyzer.isAnalyzing) {
                                root.analyzeRequested(textInput.text.trim())
                            }
                        }
                    }
                }
            }
        }
    }
}
