// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page
    property alias cfg_apiUrl: apiUrl.text
    property alias cfg_refreshSeconds: refresh.value
    property alias cfg_language: language.currentIndex
    property alias cfg_showGpu: gpu.checked
    property alias cfg_showAiServices: ai.checked

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
    CheckBox { id: gpu; text: "Show NVIDIA GPU / Mostrar GPU NVIDIA" }
    CheckBox { id: ai; text: "Show AI services / Mostrar serviços de IA" }
    Label {
        text: "The collector stays local. Use HTTP(S) without passwords or tokens in the URL.\nO coletor permanece local. Usa HTTP(S) sem palavras-passe ou tokens no endereço."
        wrapMode: Text.Wrap
        Layout.fillWidth: true
    }
}
