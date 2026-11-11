# Security

Do not publish secret values or sensitive logs in public issues. For a suspected vulnerability, use GitHub's private vulnerability reporting feature if enabled by the maintainer; otherwise report a non-sensitive request for a private contact route.

This release preparation has no independent security audit or supported stable release yet. The bundled API deliberately listens only on loopback. Do not expose it by changing the bind address or adding a public forwarding rule.

Private vulnerability reporting must be enabled by the repository owner before relying on that route. No stable version is supported yet.
