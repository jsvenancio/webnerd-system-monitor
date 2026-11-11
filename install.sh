#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
[[ $(id -u) -ne 0 ]] || { echo 'Run as your desktop user, without sudo.' >&2; exit 1; }
with_collector=false
case "${1:---widget-only}" in
  --widget-only) ;;
  --with-collector) with_collector=true ;;
  *) echo 'Usage: bash install.sh [--widget-only|--with-collector]' >&2; exit 1 ;;
esac
[[ $# -le 1 ]] || exit 1
command -v kpackagetool6 >/dev/null
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
widget_id='pt.webnerd.systemmonitor'
data_dir="${XDG_DATA_HOME:-$HOME/.local/share}"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/webnerd-system-monitor"
unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
collector_dir="$HOME/.local/lib/webnerd-system-monitor"
unit="$unit_dir/webnerd-system-monitor.service"
if $with_collector; then
  [[ ! -e "$unit" && ! -e "$collector_dir" ]] || {
    echo 'A collector installation already exists. Review it before proceeding.' >&2; exit 1;
  }
  /usr/bin/python3 -c 'import psutil' || {
    echo 'Install python3-psutil through your distribution first. See README.' >&2; exit 1;
  }
  # Refuse to compete with another collector, including an existing Lab service.
  /usr/bin/python3 - <<'PY'
import socket
with socket.socket() as sock:
    try:
        sock.bind(('127.0.0.1', 8765))
    except OSError:
        raise SystemExit('Port 8765 is occupied. Use --widget-only to reuse your existing API.')
PY
fi
target="$data_dir/plasma/plasmoids/$widget_id"
if [[ -e "$target" || -L "$target" ]]; then
  mkdir -p "$state_dir/backups"
  backup="$(mktemp -d "$state_dir/backups/widget-XXXXXXXX")"
  cp -a -- "$target" "$backup/widget"
  echo "Previous widget preserved: $backup/widget"
  kpackagetool6 --type Plasma/Applet --upgrade "$here/widget"
else
  kpackagetool6 --type Plasma/Applet --install "$here/widget"
fi
if $with_collector; then
  mkdir -p "$collector_dir" "$unit_dir"
  install -m 644 "$here/collector/monitor.py" "$collector_dir/monitor.py"
  cat > "$unit" <<'UNIT'
[Unit]
Description=Webnerd System Monitor local collector

[Service]
Type=simple
ExecStart=/usr/bin/python3 -B %h/.local/lib/webnerd-system-monitor/monitor.py
Restart=on-failure
RestartSec=5
NoNewPrivileges=true
UMask=0077

[Install]
WantedBy=default.target
UNIT
  systemctl --user daemon-reload
  systemctl --user enable --now webnerd-system-monitor.service
  echo 'Local collector enabled. Check its status with systemctl --user status webnerd-system-monitor.service'
fi
echo 'Widget installed. Add Webnerd System Monitor from the Plasma widget browser.'
echo 'If the previous QML remains visible, log out and log in after saving your work.'
echo 'No Lab telemetry configuration or firewall rules were changed.'
