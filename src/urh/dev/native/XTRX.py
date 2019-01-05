from collections import OrderedDict

import numpy as np
from multiprocessing import Array

from urh.dev.native.Device import Device
from urh.dev.native.lib import usrp
from multiprocessing.connection import Connection


class XTRX(Device):

    @classmethod
    def get_device_list(cls):
        pass


    @classmethod
    def adapt_num_read_samples_to_sample_rate():
        pass


    @classmethod
    def setup_device():
        pass

    @classmethod
    def init_device():
        pass

    @classmethod
    def shutdown_device():
        pass

    @classmethod
    def prepare_sync_receive():
        pass

    @classmethod
    def receive_sync():
        pass

    @classmethod
    def prepare_sync_send():
        pass


    @classmethod
    def send_sync():
        pass


    def set_device_gain():
        pass

    @property
    def has_multi_device_support(self):
        pass

    @property
    def device_parameters(self):
        pass

    @staticmethod
    def unpack_complex(buffer):
        pass

    @staticmethod
    def pack_complex():
        pass
