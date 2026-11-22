# Operations

The optional service is a systemd **user** service named `webnerd-system-monitor.service`. It does not enable user lingering or start an extra system service.

```bash
systemctl --user status webnerd-system-monitor.service
journalctl --user -u webnerd-system-monitor.service -n 20 --no-pager
```

For collector options, run:

```bash
systemctl --user edit webnerd-system-monitor.service
```

Example override (choose your port and disk path):

```ini
[Service]
ExecStart=
ExecStart=/usr/bin/python3 -B %h/.local/lib/webnerd-system-monitor/monitor.py --port 8766 --disk / --no-ai-checks
```

Then restart this collector and update the widget API URL to match:

```bash
systemctl --user daemon-reload
systemctl --user restart webnerd-system-monitor.service
```

Existing installations with a different collector should use widget-only installation and their existing collector's own configuration. This project never edits those services.

Backups made during widget upgrades are retained under the user's XDG state directory. To restore, copy the desired backup to a working directory, inspect its metadata and install/upgrade it with `kpackagetool6 --type Plasma/Applet --upgrade PATH_TO_REVIEWED_BACKUP`. Save your work and restart the desktop session if old QML remains cached.

## Updating the bundled collector

Only for an existing collector installed by this project's `--with-collector` option. Do not use these commands for an external AI Lab collector. Close the widget configuration window, then run from the reviewed new source directory:

```bash
bash install.sh --widget-only
bash <<'UPDATE_COLLECTOR'
set -euo pipefail
collector_dir="$HOME/.local/lib/webnerd-system-monitor"
test -f "$collector_dir/monitor.py"
systemctl --user is-active --quiet webnerd-system-monitor.service
backup_root="${XDG_STATE_HOME:-$HOME/.local/state}/webnerd-system-monitor/backups"
mkdir -p "$backup_root"
backup="$(mktemp -d "$backup_root/collector-XXXXXXXX")"
cp -a "$collector_dir/." "$backup/"
install -m 644 collector/network.py "$collector_dir/network.py"
install -m 644 collector/monitor.py "$collector_dir/monitor.py"
if ! systemctl --user restart webnerd-system-monitor.service; then
    cp -a "$backup/." "$collector_dir/"
    systemctl --user restart webnerd-system-monitor.service
    exit 1
fi
printf 'Previous collector preserved: %s\n' "$backup"
UPDATE_COLLECTOR
```

Save your work and log out/in if Plasma still displays the old widget code. The source installer deliberately refuses to create a second collector over an existing installation.
