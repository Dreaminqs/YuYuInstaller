pragma Singleton
import QtQuick

QtObject {
    // Backgrounds - Translucent frosted obsidian glass HUD (Saydam cam estetiği)
    readonly property color bgApp: "transparent"
    readonly property color bgSidebar: "#66080b12"      // ~40% opacity glass
    readonly property color bgCard: "#730f1420"         // ~45% opacity glass card
    readonly property color bgCardHover: "#99161f2e"    // ~60% opacity hover
    readonly property color bgInput: "#800c1018"        // ~50% opacity input
    readonly property color bgElevated: "#8c131826"     // ~55% opacity elevated

    // Signature Accents & Gradients (Electric Ice Cyan to Azure Blue - No More Green)
    readonly property color accent: "#38bdf8"          // Electric Sky / Ice Cyan
    readonly property color accentHover: "#7dd3fc"     // Lighter glowing cyan
    readonly property color accentBlue: "#2563eb"      // Electric Blue
    readonly property color accentBlueHover: "#3b82f6" // Brighter Blue
    readonly property color accentPurple: "#8b5cf6"
    readonly property color accentSecondary: "#0284c7"
    readonly property color accentCyan: "#38bdf8"

    // Active Sidebar Tab styling
    readonly property color activeTabBg: "#260284c7"
    readonly property color activeTabBorder: "#38bdf8"
    readonly property color activeTabIndicator: "#38bdf8"
    readonly property color activeTabText: "#38bdf8"

    readonly property color success: "#38bdf8"
    readonly property color warning: "#f59e0b"
    readonly property color error: "#ef4444"

    // Text hierarchy
    readonly property color textPrimary: "#f3f4f6"
    readonly property color textSecondary: "#94a3b8"
    readonly property color textMuted: "#5e6a7c"

    // Borders
    readonly property color borderDim: "#1affffff"      // 10% translucent white frosted glass border
    readonly property color borderBright: "#40ffffff"
    readonly property color borderHighlight: "#38bdf8"

    // Radii
    readonly property int radiusSm: 6
    readonly property int radiusMd: 10
    readonly property int radiusLg: 14
    readonly property int radiusXl: 20

    // Font Family (Universal Windows typography supporting all Latin, Turkish, and Cyrillic glyphs)
    readonly property string fontFamily: "Segoe UI, Segoe UI Variable Text, Arial, Roboto, sans-serif"
}
