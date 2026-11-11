# SPDX-License-Identifier: GPL-3.0-or-later
import http.client
import importlib.util
import json
import threading
import unittest
from pathlib import Path
from unittest.mock import patch

source = Path(__file__).resolve().parents[1] / "collector/monitor.py"
spec = importlib.util.spec_from_file_location("webnerd_monitor", source)
monitor = importlib.util.module_from_spec(spec)
spec.loader.exec_module(monitor)


class CollectorTests(unittest.TestCase):
    def test_cache_shared_between_http_readers(self):
        cache = monitor.Cache(ai_checks=False)
        data = {"timestamp": "2026-01-01T00:00:00+00:00", "hostname": "linux-workstation", "cpu": {"usage_percent": 8}}
        with patch.object(monitor, "collect", return_value=data) as collect:
            cache.update()
            with monitor.Server(("127.0.0.1", 0), cache) as server:
                thread = threading.Thread(target=server.serve_forever, daemon=True)
                thread.start()
                try:
                    for _ in range(2):
                        client = http.client.HTTPConnection(*server.server_address, timeout=3)
                        client.request("GET", "/status")
                        response = client.getresponse()
                        self.assertEqual(response.status, 200)
                        self.assertEqual(response.getheader("Cache-Control"), "no-store")
                        self.assertEqual(json.loads(response.read()), data)
                        client.close()
                finally:
                    server.shutdown(); thread.join()
            collect.assert_called_once()

    def test_failed_sampling_keeps_last_timestamp(self):
        cache = monitor.Cache()
        with patch.object(monitor, "collect", return_value={"timestamp": "old"}):
            cache.update()
        with patch.object(monitor, "collect", side_effect=OSError("sensor failed")):
            with self.assertRaises(OSError):
                cache.update()
        self.assertEqual(json.loads(cache.read())["timestamp"], "old")

    def test_network_binding_is_rejected(self):
        with self.assertRaises(ValueError):
            monitor.Server(("0.0.0.0", 8765), monitor.Cache())

    def test_missing_nvidia_tool_is_explicit(self):
        with patch.object(monitor.subprocess, "run", side_effect=FileNotFoundError):
            self.assertEqual(monitor.gpu_info(), {"status": "unavailable"})


if __name__ == "__main__":
    unittest.main()
