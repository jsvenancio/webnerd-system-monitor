# JSON API

`GET http://127.0.0.1:8765/status` returns a cached JSON snapshot with `Content-Type: application/json` and `Cache-Control: no-store`. Only `/status` is supported. Initial collection may return 503; unsupported paths return 404.

The widget reads:

| Field | Meaning |
|---|---|
| timestamp | UTC ISO-8601 sampling-start time |
| hostname | Current local hostname |
| cpu.usage_percent, logical_cores | Utilization and logical processor count |
| ram.total_gib, used_gib, usage_percent | RAM values; available_gib is also supplied |
| gpu.name, utilization_percent | NVIDIA first-GPU information |
| gpu.memory_used_mib, memory_total_mib | VRAM |
| gpu.status | unavailable when NVIDIA tooling is absent or fails |
| disk.mountpoint, total_gib, free_gib, usage_percent | Selected filesystem |
| load_average.1_min, 5_min, 15_min | Linux load averages |
| temperatures | Sensor groups with label/current_celsius entries |
| services.ollama.status, services.open_webui.status | responding, not_responding, disabled |

The existing v0.2 collector's core fields remain compatible with this widget. Extra fields are ignored. The standalone collector adds RAM availability but does not add remote authentication or transport.

Missing optional values must remain absent/null/unavailable, not be represented as fabricated zeros. A timestamp more than one minute away from the reader's clock is considered stale. A correctly synchronized clock is required.

Do not treat service availability as proof of model loading, successful inference, database health or user authentication. The checks are basic local HTTP probes.
