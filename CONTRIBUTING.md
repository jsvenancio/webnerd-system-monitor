# Contributing

Start with a small issue explaining your Plasma/Qt version, Linux distribution and hardware relevant to the problem. Remove hostnames, private IP addresses and secrets from logs and screenshots.

Keep collection separate from presentation. New collectors must preserve the JSON fields consumed by the widget or document a schema migration. Do not add remote telemetry or root privileges to the default install.

Run the Python tests and shell syntax checks before proposing changes. Validate UI changes in a real Plasma 6 session, including the configuration page, unavailable sensors and a stopped collector. Avoid adding large dependencies for simple charts.

Contributions use GPL-3.0-or-later. Only submit material you may license under those terms.
