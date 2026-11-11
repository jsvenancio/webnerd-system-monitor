#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Loopback-only Linux metrics API. No remote telemetry or credential storage."""
import argparse
import json
import math
import platform
import shutil
import subprocess
import threading
import time
import urllib.request
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

import psutil


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args):
        return None


def check_service(url, version=False):
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}), NoRedirect())
    try:
        with opener.open(url, timeout=2) as response:
            result = {"status": "responding", "http_status": response.status}
            if version:
                data = json.loads(response.read(8192))
                value = data.get("version")
                if isinstance(value, str):
                    result["version"] = value[:80]
            return result
    except (OSError, ValueError, AttributeError):
        return {"status": "not_responding"}


def gpu_info():
    try:
        result = subprocess.run([
            "nvidia-smi", "--query-gpu=name,memory.total,memory.used,utilization.gpu",
            "--format=csv,noheader,nounits"], capture_output=True, text=True,
            timeout=4, check=True)
        values = [value.strip() for value in result.stdout.strip().splitlines()[0].split(",")]
        return {"name": values[0], "memory_total_mib": int(values[1]),
                "memory_used_mib": int(values[2]), "utilization_percent": int(values[3])}
    except (OSError, subprocess.SubprocessError, ValueError, IndexError):
        return {"status": "unavailable"}


def temperatures():
    result = {}
    try:
        for sensor, entries in psutil.sensors_temperatures().items():
            result[sensor] = [{"label": entry.label or sensor,
                               "current_celsius": entry.current if entry.current is not None and math.isfinite(entry.current) else None}
                              for entry in entries]
    except (AttributeError, OSError):
        pass
    return result


def collect(disk_path="/", ai_checks=True):
    memory = psutil.virtual_memory()
    disk = shutil.disk_usage(disk_path)
    load = psutil.getloadavg()
    return {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "hostname": platform.node(), "system": platform.system(),
        "cpu": {"usage_percent": psutil.cpu_percent(interval=0.2),
                "logical_cores": psutil.cpu_count()},
        "ram": {"total_gib": round(memory.total / 1024**3, 2),
                "used_gib": round(memory.used / 1024**3, 2),
                "available_gib": round(memory.available / 1024**3, 2),
                "usage_percent": memory.percent},
        "gpu": gpu_info(),
        "disk": {"mountpoint": disk_path, "total_gib": round(disk.total / 1024**3, 2),
                 "used_gib": round(disk.used / 1024**3, 2),
                 "free_gib": round(disk.free / 1024**3, 2),
                 "usage_percent": round(disk.used / disk.total * 100, 1) if disk.total else None},
        "load_average": {"1_min": load[0], "5_min": load[1], "15_min": load[2]},
        "temperatures": temperatures(),
        "services": {
            "ollama": check_service("http://127.0.0.1:11434/api/version", True) if ai_checks else {"status": "disabled"},
            "open_webui": check_service("http://127.0.0.1:3000/health") if ai_checks else {"status": "disabled"},
        },
    }


class Cache:
    def __init__(self, disk_path="/", ai_checks=True):
        self.disk_path, self.ai_checks = disk_path, ai_checks
        self.lock = threading.Lock()
        self.payload = None

    def update(self):
        payload = json.dumps(collect(self.disk_path, self.ai_checks),
                             ensure_ascii=False, allow_nan=False).encode()
        with self.lock:
            self.payload = payload

    def read(self):
        with self.lock:
            return self.payload


class Handler(BaseHTTPRequestHandler):
    def setup(self):
        self.request.settimeout(3)
        super().setup()

    def log_message(self, *args):
        pass

    def do_GET(self):
        if self.path != "/status":
            self.send_error(404)
            return
        payload = self.server.cache.read()
        if payload is None:
            self.send_error(503, "Metrics not ready")
            return
        self.send_response(200)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)


class Server(ThreadingHTTPServer):
    daemon_threads = True
    block_on_close = False

    def __init__(self, address, cache):
        if address[0] != "127.0.0.1":
            raise ValueError("Only IPv4 loopback binding is supported")
        self.cache = cache
        self.slots = threading.BoundedSemaphore(8)
        super().__init__(address, Handler)

    def process_request(self, request, address):
        if not self.slots.acquire(False):
            self.shutdown_request(request)
            return
        try:
            super().process_request(request, address)
        except BaseException:
            self.slots.release()
            raise

    def process_request_thread(self, request, address):
        try:
            super().process_request_thread(request, address)
        finally:
            self.slots.release()

    def handle_error(self, request, address):
        print("Local monitor: request failed", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=8765)
    parser.add_argument("--interval", type=int, default=15)
    parser.add_argument("--disk", default="/")
    parser.add_argument("--no-ai-checks", action="store_true")
    args = parser.parse_args()
    if not 1024 <= args.port <= 65535 or not 5 <= args.interval <= 30:
        parser.error("port: 1024–65535; collection interval: 5–30 seconds")
    shutil.disk_usage(args.disk)
    cache = Cache(args.disk, not args.no_ai_checks)
    stop = threading.Event()

    def worker():
        while not stop.is_set():
            started = time.monotonic()
            try:
                cache.update()
            except Exception as error:
                print("Local monitor: sampling failed (" + type(error).__name__ + ")", flush=True)
            stop.wait(max(1, args.interval - (time.monotonic() - started)))

    with Server(("127.0.0.1", args.port), cache) as server:
        thread = threading.Thread(target=worker, name="webnerd-sampler", daemon=True)
        thread.start()
        print("Webnerd System Monitor: http://127.0.0.1:" + str(args.port) + "/status", flush=True)
        try:
            server.serve_forever()
        finally:
            stop.set()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
