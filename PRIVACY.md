# Privacy

The bundled collector binds only to IPv4 loopback (`127.0.0.1`). It has no remote upload, analytics, registration, advertising or credential storage.

It reads resource metrics and the local hostname. Temperature labels and GPU model names may also identify hardware. Local processes that can reach localhost can read the unauthenticated JSON API.

If enabled, AI checks query only the local Ollama version and Open WebUI health endpoints. They do not request conversations, prompts, models, files, accounts or credentials. Redirects and environment proxy settings are disabled for those checks.

The widget queries the API URL selected in its settings. It defaults to the local collector; configuring another address is an explicit user action. HTTP(S) credentials, query strings and fragments are not supported in the configured URL.

The five-minute history is kept in widget memory and resets when reloaded. The collector also keeps only its latest snapshot in memory. No metrics database is created.

This repository does not include a remote sender, infrastructure receiver, private network addresses, secret files or device screenshots. Separate remote integrations must be reviewed and configured independently.

The API has no commands for changing system settings or controlling services. The installers create user-owned files and optionally a user service; they do not change firewall rules or require root.
