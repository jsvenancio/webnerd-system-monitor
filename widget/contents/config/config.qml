// SPDX-License-Identifier: GPL-3.0-or-later
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: "General / Geral"
        icon: "utilities-system-monitor"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: "Project / Projeto"
        icon: "help-about"
        source: "configProject.qml"
    }
}
