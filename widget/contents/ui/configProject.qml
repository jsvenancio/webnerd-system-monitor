// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ScrollView {
    id: page
    contentWidth: availableWidth
    ColumnLayout {
        width: page.availableWidth; spacing: 14
        Label { text: "Webnerd System Monitor 0.4.1"; font.bold: true; font.pixelSize: 20; Layout.fillWidth: true; wrapMode: Text.Wrap }
        Label { text: "Linux · KDE Plasma 6 · GPL-3.0-or-later"; Layout.fillWidth: true; wrapMode: Text.Wrap }
        Label { text: "Links / Ligações"; font.bold: true }
        Repeater {
            model: [
                {label: "Blog", url: "https://webnerdept.wordpress.com/"},
                {label: "Repository / Repositório", url: "https://github.com/jsvenancio/webnerd-system-monitor"},
                {label: "Official website / Site oficial", url: "https://webnerd.pt/"},
                {label: "Help and suggestions / Ajuda e sugestões", url: "https://webnerdept.wordpress.com/contacte-nos/"}
            ]
            delegate: Button {
                required property var modelData
                text: modelData.label + " ↗"
                onClicked: Qt.openUrlExternally(modelData.url)
            }
        }
        Label { text: "Authors / Autores"; font.bold: true }
        Label { text: "Joaquim Venâncio — Conceção e direção do projeto\nWebnerd.pt — Desenvolvimento e manutenção"; Layout.fillWidth: true; wrapMode: Text.Wrap }
        Button { text: "Portfolio / Portefólio ↗"; onClicked: Qt.openUrlExternally("https://portfolio.jsvenancio.com/") }
        Label { text: "© 2026 Webnerd.pt" }
        Label { text: "Keyboard shortcut / Atalho de teclado"; font.bold: true }
        Label {
            text: "Default proposal: Ctrl+Alt+M. Use scripts/set-default-shortcut.py after adding the widget. Change it in Keyboard Shortcuts.\nPredefinido proposto: Ctrl+Alt+M. Define ou altera na página Atalhos de teclado."
            Layout.fillWidth: true; wrapMode: Text.Wrap
        }
    }
}
