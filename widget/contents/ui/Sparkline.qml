// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick

Canvas {
    id: chart
    property var samples: []
    property int maxGapMs: 25000
    property string field: "cpu"
    property color lineColor: "#38bdf8"
    onSamplesChanged: requestPaint()
    onFieldChanged: requestPaint()
    onLineColorChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onAvailableChanged: if (available) requestPaint()
    onPaint: {
        const ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        const pad = 3
        const w = Math.max(1, width - 2 * pad)
        const h = Math.max(1, height - 2 * pad)
        ctx.lineWidth = 1
        ctx.strokeStyle = "#334155"
        ctx.beginPath()
        for (let j = 0; j <= 4; j++) {
            const y = pad + h * j / 4
            ctx.moveTo(pad, y)
            ctx.lineTo(width - pad, y)
        }
        ctx.stroke()
        if (!samples || !samples.length) return
        const end = samples[samples.length - 1].t
        const start = end - 300000
        ctx.strokeStyle = lineColor
        ctx.fillStyle = lineColor
        ctx.lineWidth = 2
        ctx.lineJoin = "round"
        ctx.beginPath()
        let previousTime = 0
        let connected = false
        let lastX = 0
        let lastY = 0
        let lastValid = false
        for (let i = 0; i < samples.length; i++) {
            const p = samples[i]
            const v = p[field]
            if (p.t < start || typeof v !== "number" || !isFinite(v)) {
                connected = false
                lastValid = false
                continue
            }
            const x = pad + w * Math.max(0, Math.min(1, (p.t - start) / 300000))
            const y = pad + h * (1 - Math.max(0, Math.min(100, v)) / 100)
            if (connected && p.t - previousTime <= maxGapMs) ctx.lineTo(x, y)
            else ctx.moveTo(x, y)
            connected = true
            previousTime = p.t
            lastX = x; lastY = y; lastValid = true
        }
        ctx.stroke()
        if (lastValid) {
            ctx.beginPath()
            ctx.arc(lastX, lastY, 2.5, 0, Math.PI * 2)
            ctx.fill()
        }
    }
}

