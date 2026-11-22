# Changelog

## 0.4.1 — 2026-11-22 (experimental)

- Add download/upload charts, decimal bit-rate units and network interface selection.
- Sample network counters independently of HTTP readers; show unavailable values during warm-up/disconnection.
- Add per-widget background opacity, live preview and Apply/discard handling.
- Fit all cards into the widget without scrolling using compact spacing and height adaptation.
- Add author portfolio, labelled project links and a conflict-aware Ctrl+Alt+M setup helper.
- Preserve the existing metrics contract and keep external Lab services independent.
- Validate network display, layout and opacity preview/save/discard on Nobara KDE; add network-rate tests.

## 0.3.0 — experimental

- Extract a standalone Plasma package and loopback-only Python collector.
- Add API URL, refresh interval, language and card visibility settings.
- Add English/Portuguese interface and documentation.
- Share one collector snapshot across readers.
- Add an Intel package-temperature fallback and explicit unavailable values.
- Package installation/removal scripts with backups and occupied-port checks.
- Exclude private infrastructure, identifiers and personal screenshots.

## 0.2.0 — private prototype

- Vertical desktop sidebar with CPU, RAM and NVIDIA charts.
- Temperatures, disk, load and local AI status cards.
- Content-based temperature-card height.
- Used on Nobara Linux 44 / Plasma 6.7.5.
