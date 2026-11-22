# SPDX-License-Identifier: GPL-3.0-or-later
import sys
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'collector'))
import network

class NetworkTests(unittest.TestCase):
    def sample(self, sampler, received, sent, now, up=True):
        counters = {'wifi0': SimpleNamespace(bytes_recv=received, bytes_sent=sent)}
        with patch.object(network.psutil, 'net_io_counters', return_value=counters), \
             patch.object(network.psutil, 'net_if_stats', return_value={'wifi0': SimpleNamespace(isup=up)}), \
             patch.object(network.time, 'monotonic', return_value=now), \
             patch.object(network, 'default_interface', return_value='wifi0'):
            sampler.sample()
        return sampler.data['interfaces']['wifi0']

    def test_rates_use_elapsed_time_not_http_request_frequency(self):
        sampler = network.NetworkSampler()
        first = self.sample(sampler, 100, 200, 10)
        self.assertIsNone(first['download_bytes_per_second'])
        second = self.sample(sampler, 1100, 700, 12)
        self.assertEqual(second['download_bytes_per_second'], 500)
        self.assertEqual(second['upload_bytes_per_second'], 250)

    def test_reset_and_reconnect_do_not_fabricate_rates(self):
        sampler = network.NetworkSampler()
        self.sample(sampler, 1000, 2000, 10)
        self.assertIsNone(self.sample(sampler, 20, 30, 11)['download_bytes_per_second'])
        self.assertIsNone(self.sample(sampler, 30, 40, 12, False)['download_bytes_per_second'])
        self.assertIsNone(self.sample(sampler, 100, 200, 13)['download_bytes_per_second'])
