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
