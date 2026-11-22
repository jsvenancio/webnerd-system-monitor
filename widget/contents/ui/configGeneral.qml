// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

Kirigami.FormLayout {
    id: page
    // Keep the last applied value separate from the live preview.
    property int appliedOpacity: 100
    property bool previewReady: false
    property bool unsavedChanges: previewReady && Math.round(cfg_backgroundOpacity) !== appliedOpacity
    Component.onCompleted: {
        appliedOpacity = Plasmoid.configuration.backgroundOpacity
        previewReady = true
    }
    function saveConfig() {
        appliedOpacity = Math.round(cfg_backgroundOpacity)
    }
    Component.onDestruction: {
        if (previewReady) Plasmoid.configuration.backgroundOpacity = appliedOpacity
    }
    property alias cfg_apiUrl: apiUrl.text
    property alias cfg_refreshSeconds: refresh.value
    property alias cfg_language: language.currentIndex
    property alias cfg_showGpu: gpu.checked
    property alias cfg_showAiServices: ai.checked

    property alias cfg_backgroundOpacity: backgroundOpacity.value
    property alias cfg_showNetwork: network.checked
    property alias cfg_networkInterface: networkInterface.text

    TextField {
        id: apiUrl
        Kirigami.FormData.label: "API URL / Endereço da API:"
        Layout.fillWidth: true
        placeholderText: "http://127.0.0.1:8765/status"
    }
    SpinBox {
        id: refresh
        Kirigami.FormData.label: "Refresh (seconds) / Atualização (segundos):"
        from: 5
        to: 300
        editable: true
    }
    ComboBox {
        id: language
        Kirigami.FormData.label: "Language / Idioma:"
        model: ["Automatic / Automático", "English", "Português"]
    }
    RowLayout {
        Kirigami.FormData.label: "Background opacity / Opacidade do fundo:"
        Slider {
            id: backgroundOpacity
            from: 20; to: 100; stepSize: 1; Layout.fillWidth: true
            onMoved: {
                if (page.previewReady)
                    Plasmoid.configuration.backgroundOpacity = Math.round(value)
            }
        }
        Label { text: Math.round(backgroundOpacity.value) + " %"; Layout.minimumWidth: 45 }
    }
    CheckBox { id: network; text: "Show network traffic / Mostrar tráfego de rede" }
    TextField {
        id: networkInterface
        Kirigami.FormData.label: "Network interface / Interface de rede:"
        Layout.fillWidth: true
        placeholderText: "Automatic / Automática (e.g. / ex.: wlp3s0)"
    }
    Label {
        text: "Empty: default route. Traffic includes local transfers; this is not a speed test.\nVazio: rota predefinida. Inclui transferências locais; não é um teste de velocidade."
        wrapMode: Text.Wrap; Layout.fillWidth: true
    }
    CheckBox { id: gpu; text: "Show NVIDIA GPU / Mostrar GPU NVIDIA" }
    CheckBox { id: ai; text: "Show AI services / Mostrar serviços de IA" }
    Label {
        text: "The collector stays local. Use HTTP(S) without passwords or tokens in the URL.\nO coletor permanece local. Usa HTTP(S) sem palavras-passe ou tokens no endereço."
        wrapMode: Text.Wrap
        Layout.fillWidth: true
    }
}
