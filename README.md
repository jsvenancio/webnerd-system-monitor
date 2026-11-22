# Webnerd System Monitor

**A private desktop sidebar for KDE Plasma 6, by Webnerd.pt.**

[Português](README.pt-PT.md) · GPL-3.0-or-later · Experimental **0.4.1**

CPU, RAM and NVIDIA GPU charts, temperatures, disk space, system load and optional local AI service status — in a resizable desktop widget.

## Status

Experimental 0.4.1 has been validated on Nobara Linux 44 with KDE Plasma 6: network charts, compact full-content layout, live background-opacity preview, Apply/OK persistence and discard restoration were confirmed on the maintainer's desktop. The original setup was exercised with Plasma 6.7.5. The bundled standalone collector has automated tests and an isolated HTTP startup check; its complete desktop-service install/removal flow and other hardware/distributions remain unverified.

No private Lab server is required. Nothing sends metrics to a remote server automatically. The collector listens only on `127.0.0.1`.

## Features

- CPU, RAM and NVIDIA usage charts: a rolling five-minute window held in memory.
- NVIDIA VRAM usage via `nvidia-smi` (first GPU only).
- CPU temperature from AMD k10temp/Tctl or Intel coretemp package sensors, when exposed by the kernel.
- AMD GPU edge and NVMe composite temperature when available; missing sensors display **—**.
- Disk usage/free space and 1/5/15-minute load averages.
- Optional checks for Ollama and Open WebUI. Neither is installed by this project.
- Download/upload charts in decimal kbit/s, Mbit/s or Gbit/s, with automatic or explicit interface selection.
- Compact layout without hidden cards or scrolling; scales to fit the available widget height.
- Background opacity from 20–100%, with live preview; Apply/OK retain the value and discarding restores the last applied value.
- Native author links and a Project settings page with Blog, Repository, Official website and help links.
- Configurable API URL, refresh interval (5–300 seconds), language and card visibility.
- Automatic UI language for Portuguese locales, otherwise English; manual English/Portuguese selection.
- No overlapping widget requests; errors and stale samples are shown explicitly.

## Requirements

- Linux with KDE Plasma 6; QtQuick Controls and Kirigami QML modules.
- `kpackagetool6` (distribution Plasma tools package).
- For the bundled collector: `/usr/bin/python3` (3.10+) and `psutil`.
- NVIDIA driver tools are optional. Without `nvidia-smi`, the NVIDIA card has no values and can be hidden.

Install `python3-psutil` through your distribution if you want the bundled collector. For example, Debian/Ubuntu packages use `python3-psutil`; Fedora-family distributions also provide `python3-psutil`. Use your distribution's supported package/update workflow. No dependency installation is performed by our scripts.

## Install

Extract this source archive and open a terminal inside its `webnerd-system-monitor` directory. Run commands as your desktop user, **without sudo**.

### Existing compatible metrics API

```bash
bash install.sh --widget-only
```

This is the default mode. In particular, an existing Webnerd AI Lab installation should use this option to keep its current collector and telemetry integration.

### New standalone setup

```bash
bash install.sh --with-collector
```

This installs the widget plus a systemd **user** collector service. Installation refuses to start another collector if port 8765 is already occupied. The collector runs during your user session; suspension pauses monitoring.

Open **Edit Mode → Add Widgets → Webnerd System Monitor**, then place it along the right side of the desktop. Resize to suit your display (approximately 350 px wide). The compact layout shows all cards without scrolling and scales the content down when the widget is shortened. Very small sizes reduce text size; increase the widget height/width for readability.

For an upgrade, the old widget package is copied to `${XDG_STATE_HOME:-~/.local/state}/webnerd-system-monitor/backups`. Plasma may keep old QML in memory: save your work, log out and log in if re-adding the widget does not load the new version. No shell restart is forced by our installer.

## Configure

Right-click the widget → **Configure Webnerd System Monitor → General / Geral**.

| Setting | Default |
|---|---|
| API URL | `http://127.0.0.1:8765/status` |
| Refresh interval | 15 seconds |
| Language | Automatic (English or Portuguese) |
| NVIDIA card | Visible |
| AI service cards | Visible |
| Network card | Visible |
| Network interface | Empty: IPv4 default route |
| Background opacity | 100% |

API URLs must use HTTP(S) without embedded credentials, query strings or fragments. A different URL is queried only when you explicitly configure it. The widget has no secret store or remote authentication support. Do not expose the bundled unauthenticated API to a network: it intentionally supports loopback binding only.

History begins when the widget loads and is cleared when the API URL changes. It is not written to disk. A failed sensor is not replaced by a fabricated zero. The RAM percentage comes directly from `psutil`; it is not reconstructed by subtracting rounded GiB values.

## Collector

```bash
python3 collector/monitor.py --help
python3 collector/monitor.py --port 8766 --interval 15 --disk / --no-ai-checks
```

The optional second command runs in the foreground on a different port; point the widget to `http://127.0.0.1:8766/status`. Stop it with Ctrl+C. Do not run it alongside another collector unless you intentionally want an independent instance.

The collector samples on a single background loop (default every 15 seconds). HTTP requests return its cached JSON, avoiding repeated GPU/service queries when multiple widgets read it. Samples older than one minute are rejected by the widget. The first request may return 503 until initial collection finishes.

Local AI checks query only `127.0.0.1:11434/api/version` and `127.0.0.1:3000/health`; HTTP redirects and proxy settings are not followed. Use `--no-ai-checks` to disable them. Service URLs are currently fixed; only their visibility is configurable in the widget.

For the installed service, additional collector flags can be set using a systemd user override; see [operations](docs/OPERATIONS.md).

## Remove

Remove the widget from the desktop, then:

```bash
bash uninstall.sh --widget-only
# Or, if you also installed our bundled collector:
bash uninstall.sh --with-collector
```

Only `webnerd-system-monitor.service` is managed by these scripts. External collectors, remote senders, backups and saved Plasma preferences are retained.

## Privacy and optional integrations

See [PRIVACY.md](PRIVACY.md) and the [API contract](docs/API.md). No Tailscale connection, Mission Control backend, API key or cloud account is required. The public source includes no private infrastructure receiver or remote sender. A separately configured integration may consume this API, subject to its own authentication and privacy design.

The JSON exposes the local hostname and hardware/resource status to processes that can access localhost. Do not submit unredacted hardware captures if they identify your device.

## Development

```bash
python3 -B -m unittest discover -s tests -v
bash -n install.sh
bash -n uninstall.sh
```

See [CONTRIBUTING.md](CONTRIBUTING.md) and [release review](docs/RELEASE_REVIEW.md). Screenshots should use an anonymous sample hostname. The personal workstation screenshot is deliberately not bundled. An anonymous screenshot may be added later.

To validate the draft beside an existing widget, with a compatible API already running, use `bash scripts/install-preview.sh`. It installs a separately named development widget and does not create or replace a collector. Remove it from the desktop and run `kpackagetool6 --type Plasma/Applet --remove pt.webnerd.systemmonitor.preview` when finished.

## License

Copyright © 2026 Webnerd.pt. GPL version 3 or, at your option, any later version. See [LICENSE](LICENSE). No affiliation with or endorsement by KDE, NVIDIA, Ollama or Open WebUI is implied.

The native About page includes authors, roles, portfolio, copyright and license information. The Project settings page provides labelled Blog, Repository and Official website links. Help continues to use the existing contact page until a dedicated feedback form is available.

## Network readings

The collector samples counters once per second independently of HTTP consumers. The widget displays the latest rate at its configured refresh interval. Rates include local transfers and are **not an Internet speed test**.

Automatic interface selection uses the Linux IPv4 default route with the lowest metric. Without one, no interface is guessed; select an interface explicitly in settings. IPv6-only systems and VPN routing may require manual selection. Interfaces are never summed, avoiding double-counting tunnel traffic. Warm-up, disconnection and missing data display unavailable readings.

Existing Lab installations need a compatible network extension in their own collector. A widget-only upgrade against the old API keeps other metrics working but cannot display network rates. The public installer does not modify third-party services. For an existing installation of our bundled collector, see [operations](docs/OPERATIONS.md#updating-the-bundled-collector).

## Keyboard shortcut

After adding exactly one widget, run:

```bash
python3 scripts/set-default-shortcut.py
```

It assigns Ctrl+Alt+M only when available and preserves an existing custom assignment. Change or remove it in the native Keyboard Shortcuts page. If Plasma's scripting interface is unavailable, assign it manually there. The shortcut activates the widget; it does not implement a sidebar show/hide toggle. Automatic assignment was confirmed on the maintainer's installation; conflict and multiple-widget paths remain unverified on a live desktop.

See [CHANGELOG.md](CHANGELOG.md) and [ROADMAP.md](ROADMAP.md).
