// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root
    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    property bool componentReady: false
    readonly property string apiUrl: String(Plasmoid.configuration.apiUrl || "http://127.0.0.1:8765/status").trim()
    readonly property int refreshSeconds: Math.max(5, Math.min(300, Plasmoid.configuration.refreshSeconds || 15))
    readonly property bool portuguese: Plasmoid.configuration.language === 2 || (Plasmoid.configuration.language === 0 && Qt.locale().name.indexOf("pt") === 0)
    readonly property bool showGpu: Plasmoid.configuration.showGpu
    readonly property bool showAiServices: Plasmoid.configuration.showAiServices
    function t(en, pt) { return portuguese ? pt : en }
    onApiUrlChanged: {
        if (!componentReady) return
        const pending = request
        request = null
        watchdog.stop()
        if (pending) pending.abort()
        snapshot = null
        history = []
        online = false
        lastSuccess = "—"
        refresh()
    }
    property var history: []
    property var snapshot: null
    property var request: null
    property bool online: false
    property string message: root.t("Connecting to collector…", "A ligar ao coletor…")
    property string lastSuccess: "—"
    property double receivedAt: 0
    readonly property color accent: "#38bdf8"

    function number(value, digits, suffix) {
        if (!online || typeof value !== "number" || !isFinite(value)) return "—"
        return value.toFixed(digits) + suffix
    }
    function percent(value) {
        return online && typeof value === "number" && isFinite(value)
               ? Math.max(0, Math.min(100, value)) : 0
    }
    function cpuTemperature() {
        const temps = snapshot && snapshot.temperatures
        if (!temps) return null
        const amd = temps.k10temp || []
        for (let i = 0; i < amd.length; i++)
            if (amd[i].label === "Tctl") return amd[i].current_celsius
        const intel = temps.coretemp || []
        for (let i = 0; i < intel.length; i++)
            if (intel[i].label.indexOf("Package") === 0) return intel[i].current_celsius
        return null
    }
    function serviceText(name) {
        if (!online || !snapshot || !snapshot.services) return "—"
        const item = snapshot.services[name]
        if (!item) return root.t("No information", "Sem informação")
        if (item.status === "responding") return root.t("Available", "Disponível")
        if (item.status === "disabled") return t("Disabled", "Desativado")
        if (item.status === "checking") return root.t("Checking", "A verificar")
        if (item.status === "not_responding") return root.t("No response", "Sem resposta")
        return root.t("Unexpected response", "Resposta inesperada")
    }
    function sensor(group, label) {
        const entries = snapshot && snapshot.temperatures && snapshot.temperatures[group]
        if (!entries) return null
        for (let i = 0; i < entries.length; i++)
            if (entries[i].label === label) return entries[i].current_celsius
        return null
    }
    function remember(valid) {
        const now = Date.now()
        const s = snapshot || {}
        const next = history.filter(function(point) { return point.t >= now - 300000 })
        next.push({t: now,
                   cpu: valid && s.cpu ? s.cpu.usage_percent : null,
                   ram: valid && s.ram ? s.ram.usage_percent : null,
                   gpu: valid && s.gpu ? s.gpu.utilization_percent : null})
        history = next.slice(-64)
    }
    function fail(reason) {
        online = false
        message = reason
        remember(false)
    }
    function refresh() {
        if (request !== null) return
        if (!/^https?:\/\/[^@\s?#]+(?:\/[^\s?#]*)?$/.test(apiUrl)) {
            fail(t("Invalid API URL (HTTP/S only, no credentials or query)", "API inválida (HTTP/S, sem credenciais ou parâmetros)"))
            return
        }
        const xhr = new XMLHttpRequest()
        request = xhr
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE || root.request !== xhr) return
            root.request = null
            watchdog.stop()
            if (xhr.status !== 200) {
                root.fail(root.t("Collector unavailable", "Coletor indisponível") + (xhr.status ? " · HTTP " + xhr.status : ""))
                return
            }
            try {
                const data = JSON.parse(xhr.responseText)
                if (!data || !data.cpu || !data.ram || !data.timestamp || !data.hostname)
                    throw new Error("schema")
                const stamp = Date.parse(String(data.timestamp).replace(/(\.\d{3})\d+/, "$1"))
                if (!isFinite(stamp) || Math.abs(Date.now() - stamp) > 60000) {
                    root.fail(root.t("Stale data · check clock/collector", "Dados desatualizados · verificar relógio/coletor"))
                    return
                }
                root.snapshot = data
                root.receivedAt = Date.now()
                root.lastSuccess = Qt.formatTime(new Date(), "HH:mm:ss")
                root.online = true
                root.remember(true)
                root.message = t("Connected · every ", "Ligado · a cada ") + refreshSeconds + " s"
            } catch (error) {
                root.fail(root.t("Invalid or incomplete JSON response", "Resposta JSON inválida ou incompleta"))
            }
        }
        try {
            xhr.open("GET", apiUrl)
            watchdog.restart()
            xhr.send()
        } catch (error) {
            request = null
            watchdog.stop()
            fail(root.t("Could not query collector", "Não foi possível consultar o coletor"))
        }
    }
    Timer {
        id: polling
        interval: root.refreshSeconds * 1000
        repeat: true
        running: true
        onTriggered: {
            if (root.online && Date.now() - root.receivedAt > Math.max(45000, root.refreshSeconds * 2000))
                root.fail(root.t("Stale data", "Dados desatualizados"))
            root.refresh()
        }
    }
    Timer {
        id: watchdog
        interval: 10000
        onTriggered: {
            const pending = root.request
            root.request = null
            if (pending) pending.abort()
            root.fail(root.t("Collector timeout · retrying automatically", "Coletor sem resposta · nova tentativa automática"))
        }
    }
    Component.onCompleted: { componentReady = true; refresh() }
    Component.onDestruction: {
        const pending = request
        request = null
        if (pending) pending.abort()
    }

    fullRepresentation: Rectangle {
        Layout.minimumWidth: 300
        Layout.minimumHeight: 380
        Layout.preferredWidth: 350
        Layout.preferredHeight: 950
        implicitWidth: 350
        implicitHeight: 950
        radius: 16
        color: "#131a24"
        border.color: "#2c3b4e"

        ScrollView {
            id: scroll
            anchors.fill: parent
            anchors.margins: 16
            clip: true
            contentWidth: availableWidth
            contentHeight: column.implicitHeight
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ColumnLayout {
                id: column
                width: scroll.availableWidth
                spacing: 9
                Text {
                    text: "WEBNERD · SYSTEM MONITOR"
                    color: root.accent
                    font.pixelSize: 15
                    font.bold: true
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: root.snapshot ? root.snapshot.hostname : root.t("Local collector", "Coletor local")
                        color: "#edf4fc"
                        font.pixelSize: 20
                        font.bold: true
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    Text { text: "v0.3"; color: "#94a3b8"; font.pixelSize: 11 }
                }
                Text {
                    text: (root.online ? "● " : "○ ") + root.message
                    color: root.online ? "#4ade80" : "#fbbf24"
                    font.pixelSize: 11
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
                Text {
                    text: root.t("LOCAL HISTORY · 5-MINUTE WINDOW", "HISTÓRICO LOCAL · JANELA DE 5 MINUTOS")
                    color: "#94a3b8"; font.pixelSize: 10
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
                Repeater {
                    model: {
                        const s = root.snapshot || {}
                        const cpu = s.cpu || {}
                        const ram = s.ram || {}
                        const gpu = s.gpu || {}
                        return [
                            {title: root.t("PROCESSOR", "PROCESSADOR"), field: "cpu", value: root.number(cpu.usage_percent, 1, " %"),
                             detail: root.online && cpu.logical_cores ? cpu.logical_cores + root.t(" logical processors", " processadores lógicos") : "—",
                             usage: root.percent(cpu.usage_percent), tint: "#38bdf8"},
                            {title: root.t("RAM MEMORY", "MEMÓRIA RAM"), field: "ram", value: root.number(ram.usage_percent, 1, " %"),
                             detail: root.number(ram.used_gib, 2, "") + " / " + root.number(ram.total_gib, 2, " GiB"),
                             usage: root.percent(ram.usage_percent), tint: "#a78bfa"},
                            {title: "NVIDIA · GPU", field: "gpu", value: root.number(gpu.utilization_percent, 0, " %"),
                             detail: "VRAM · " + root.number(gpu.memory_used_mib, 0, "") + " / " + root.number(gpu.memory_total_mib, 0, " MiB"),
                             usage: root.percent(gpu.utilization_percent), tint: "#4ade80"}
                        ].filter(function(item) { return root.showGpu || item.field !== "gpu" })
                    }
                    delegate: Rectangle {
                        id: card
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 114
                        radius: 10
                        color: "#1c2735"
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 4
                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: card.modelData.title; color: "#cbd5e1"; font.pixelSize: 11; Layout.fillWidth: true }
                                Text { text: card.modelData.value; color: card.modelData.tint; font.pixelSize: 22; font.bold: true }
                            }
                            Sparkline {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                samples: root.history
                                field: card.modelData.field
                                lineColor: card.modelData.tint
                                maxGapMs: root.refreshSeconds * 1000 + 10000
                                opacity: root.online ? 1 : 0.35
                            }
                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 4
                                radius: 2; color: "#334155"
                                Rectangle { height: parent.height; width: parent.width * card.modelData.usage / 100; radius: 2; color: card.modelData.tint }
                            }
                            Text {
                                text: card.modelData.detail
                                color: "#94a3b8"; font.pixelSize: 11
                                Layout.fillWidth: true; elide: Text.ElideRight
                            }
                        }
                    }
                }
                Text {
                    text: root.t("Chart scale: 0–100 % · refresh ", "Escala: 0–100 % · atualização ") + root.refreshSeconds + " s"
                    color: "#94a3b8"; font.pixelSize: 10
                    Layout.fillWidth: true; wrapMode: Text.Wrap
                }
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: temperatureContent.implicitHeight + 28
                    radius: 10; color: "#1c2735"
                    ColumnLayout {
                        id: temperatureContent
                        anchors.fill: parent; anchors.margins: 10; spacing: 5
                        Text { text: root.t("TEMPERATURES", "TEMPERATURAS"); color: "#cbd5e1"; font.pixelSize: 11; font.bold: true }
                        Repeater {
                            model: [
                                {label: root.t("CPU · package/Tctl", "CPU · pacote/Tctl"), value: root.cpuTemperature()},
                                {label: root.t("AMD GPU · edge", "GPU AMD · edge"), value: root.sensor("amdgpu", "edge")},
                                {label: "SSD NVMe · Composite", value: root.sensor("nvme", "Composite")}
                            ]
                            delegate: RowLayout {
                                required property var modelData
                                Layout.fillWidth: true
                                Text { text: modelData.label; color: "#94a3b8"; font.pixelSize: 12; Layout.fillWidth: true }
                                Text { text: root.number(modelData.value, 1, " °C"); color: "#fbbf24"; font.pixelSize: 15; font.bold: true }
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 78
                    radius: 10; color: "#1c2735"
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 10; spacing: 5
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: root.t("STORAGE · ", "ARMAZENAMENTO · ") + (root.snapshot && root.snapshot.disk ? root.snapshot.disk.mountpoint : "/"); color: "#cbd5e1"; font.pixelSize: 11; Layout.fillWidth: true }
                            Text { text: root.number(root.snapshot && root.snapshot.disk ? root.snapshot.disk.usage_percent : null, 1, " %"); color: "#38bdf8"; font.pixelSize: 17; font.bold: true }
                        }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 5; radius: 2; color: "#334155"
                            Rectangle {
                                height: parent.height; radius: 2; color: "#38bdf8"
                                width: parent.width * root.percent(root.snapshot && root.snapshot.disk ? root.snapshot.disk.usage_percent : null) / 100
                            }
                        }
                        Text {
                            text: {
                                const d = root.snapshot && root.snapshot.disk ? root.snapshot.disk : {}
                                return root.number(d.free_gib, 1, root.t(" GiB free", " GiB livres")) + " / " + root.number(d.total_gib, 1, " GiB")
                            }
                            color: "#94a3b8"; font.pixelSize: 11
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 60
                    radius: 10; color: "#1c2735"
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 10; spacing: 5
                        Text { text: root.t("SYSTEM LOAD · 1 / 5 / 15 MIN", "CARGA DO SISTEMA · 1 / 5 / 15 MIN"); color: "#cbd5e1"; font.pixelSize: 10 }
                        Text {
                            text: {
                                const l = root.snapshot && root.snapshot.load_average ? root.snapshot.load_average : {}
                                return root.number(l["1_min"], 2, "") + "  /  " + root.number(l["5_min"], 2, "") + "  /  " + root.number(l["15_min"], 2, "")
                            }
                            color: "#edf4fc"; font.pixelSize: 17; font.bold: true
                        }
                    }
                }
                Rectangle {
                    visible: root.showAiServices
                    Layout.fillWidth: true; Layout.preferredHeight: 76
                    radius: 10; color: "#1c2735"
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 10; spacing: 5
                        Text { text: root.t("AI SERVICES", "SERVIÇOS DE INTELIGÊNCIA ARTIFICIAL"); color: "#cbd5e1"; font.pixelSize: 10 }
                        Repeater {
                            model: [{label: "Ollama", key: "ollama"}, {label: "Open WebUI", key: "open_webui"}]
                            delegate: RowLayout {
                                required property var modelData
                                Layout.fillWidth: true
                                Text { text: modelData.label; color: "#cbd5e1"; font.pixelSize: 12; Layout.fillWidth: true }
                                Text {
                                    text: root.serviceText(modelData.key)
                                    color: root.online && root.snapshot && root.snapshot.services && root.snapshot.services[modelData.key] && root.snapshot.services[modelData.key].status === "responding" ? "#4ade80" : "#fbbf24"
                                    font.pixelSize: 12
                                }
                            }
                        }
                    }
                }
                Text {
                    text: root.t("Last valid response · ", "Última resposta válida · ") + root.lastSuccess + root.t("\nHistory in memory · resets when reloaded\nWebnerd.pt · System Monitor · v0.3.0", "\nHistórico em memória · reinicia ao carregar\nWebnerd.pt · System Monitor · v0.3.0")
                    color: "#94a3b8"; font.pixelSize: 10
                    Layout.fillWidth: true; wrapMode: Text.Wrap
                }
            }
        }
    }
}

