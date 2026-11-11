#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
[[ $(id -u) -ne 0 ]] || { echo 'Run without sudo.' >&2; exit 1; }
[[ $# -le 1 ]] || exit 1
case "${1:---widget-only}" in
  --widget-only) ;;
  --with-collector)
    unit="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/webnerd-system-monitor.service"
    if [[ -f "$unit" ]]; then
      grep -q '^Description=Webnerd System Monitor local collector$' "$unit" || {
        echo 'Unexpected service contents. Review before removing.' >&2; exit 1;
      }
      systemctl --user disable --now webnerd-system-monitor.service
      rm -- "$unit"
      systemctl --user daemon-reload
      rm -f -- "$HOME/.local/lib/webnerd-system-monitor/monitor.py"
      rmdir -- "$HOME/.local/lib/webnerd-system-monitor" 2>/dev/null || true
    fi
    ;;
  *) echo 'Usage: bash uninstall.sh [--widget-only|--with-collector]' >&2; exit 1 ;;
esac
kpackagetool6 --type Plasma/Applet --remove pt.webnerd.systemmonitor
echo 'Widget removed. Backups and Plasma preferences were preserved.'
