#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Set Ctrl+Alt+M on one existing widget, preserving custom assignments."""
import shutil
import subprocess
import sys

qdbus = next((shutil.which(name) for name in ("qdbus6", "qdbus-qt6", "qdbus")
              if shutil.which(name)), None)
if not qdbus:
    print("Define Ctrl+Alt+M na página Atalhos de teclado (qdbus indisponível).")
    sys.exit(0)

def call(*args):
    return subprocess.check_output([qdbus, *args], text=True, timeout=8).strip()

try:
    # Qt::ControlModifier | Qt::AltModifier | Qt::Key_M.
    available = call("org.kde.kglobalaccel", "/kglobalaccel",
                     "org.kde.KGlobalAccel.isGlobalShortcutAvailable", "201326669", "")
    if available.lower() != "true":
        print("Ctrl+Alt+M já está atribuído; nenhum atalho foi alterado.")
        sys.exit(0)
    script = r'''(function() {
        var candidates = [];
        var containers = desktops().concat(panels());
        for (var i = 0; i < containers.length; i++) {
            var items = containers[i].widgets();
            for (var j = 0; j < items.length; j++) {
                if (items[j].type === "pt.webnerd.systemmonitor" ||
                    items[j].type === "pt.webnerd.systemmonitor.preview") candidates.push(items[j]);
            }
        }
        if (candidates.length !== 1) { print("Adiciona apenas um widget e define o atalho nas configurações."); return; }
        if (candidates[0].globalShortcut) { print("Atalho personalizado preservado."); return; }
        candidates[0].globalShortcut = "Ctrl+Alt+M";
        print("Atalho Ctrl+Alt+M definido; podes alterá-lo nas configurações.");
    })();'''
    print(call("org.kde.plasmashell", "/PlasmaShell", "org.kde.PlasmaShell.evaluateScript", script))
except (OSError, subprocess.SubprocessError):
    print("Define Ctrl+Alt+M na página Atalhos de teclado; o acesso automático não está disponível.")
