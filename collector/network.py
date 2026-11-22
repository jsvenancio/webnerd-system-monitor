# SPDX-License-Identifier: GPL-3.0-or-later
"""Local network rates; sampling is independent of HTTP consumers."""
import copy
import threading
import time
from pathlib import Path
import psutil


def default_interface():
    try:
        routes = []
        for line in Path("/proc/net/route").read_text().splitlines()[1:]:
            fields = line.split()
            if len(fields) > 7 and fields[1] == "00000000" and int(fields[3], 16) & 1:
                routes.append((int(fields[6]), fields[0]))
        return min(routes)[1] if routes else None
    except (OSError, ValueError):
        return None


class NetworkSampler:
    def __init__(self):
        self.lock = threading.Lock()
        self.previous = {}
        self.previous_time = None
        self.data = {"default_interface": None, "interfaces": {}}
        self.started = False

    def sample(self):
        now = time.monotonic()
        counters = psutil.net_io_counters(pernic=True, nowrap=True)
        stats = psutil.net_if_stats()
        elapsed = now - self.previous_time if self.previous_time is not None else 0
        interfaces = {}
        for name, counter in counters.items():
            if name == "lo":
                continue
            info = stats.get(name)
            up = bool(info and info.isup)
            old = self.previous.get(name)
            down = upload = None
            if up and old is not None and elapsed > 0:
                received = counter.bytes_recv - old.bytes_recv
                sent = counter.bytes_sent - old.bytes_sent
                if received >= 0 and sent >= 0:
                    down, upload = received / elapsed, sent / elapsed
            interfaces[name] = {"is_up": up, "download_bytes_per_second": down,
                                "upload_bytes_per_second": upload}
        default = default_interface()
        if default not in interfaces or not interfaces[default]["is_up"]:
            default = None
        with self.lock:
            self.data = {"default_interface": default, "interfaces": interfaces}
        self.previous = {name: counter for name, counter in counters.items()
                         if name in interfaces and interfaces[name]["is_up"]}
        self.previous_time = now

    def read(self):
        self.start()
        with self.lock:
            return copy.deepcopy(self.data)

    def start(self):
        with self.lock:
            if self.started:
                return
            self.started = True
        threading.Thread(target=self._loop, name="webnerd-network", daemon=True).start()

    def _loop(self):
        while True:
            try:
                self.sample()
            except (OSError, RuntimeError):
                with self.lock:
                    self.data = {"default_interface": None, "interfaces": {}}
                self.previous = {}
                self.previous_time = None
            time.sleep(1)


network_sampler = NetworkSampler()
