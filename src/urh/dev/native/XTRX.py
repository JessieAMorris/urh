from collections import OrderedDict

import numpy as np
from multiprocessing import Array

from urh.dev.native.Device import Device
from urh.dev.native.lib import usrp
from multiprocessing.connection import Connection


class XTRX(Device):

    @classmethod
    def get_device_list(cls):


    @classmethod
    def adapt_num_read_samples_to_sample_rate():


    @classmethod
    def setup_device():

    @classmethod
    def init_device():

    @classmethod
    def shutdown_device():

    @classmethod
    def prepare_sync_receive():

    @classmethod
    def receive_sync():

    @classmethod
    def prepare_sync_send():


    @classmethod
    def send_sync():


    def set_device_gain():

    @property
    def has_multi_device_support(self):

    @property
    def device_parameters(self):

    @staticmethod
    def unpack_complex(buffer):

    @staticmethod
    def pack_complex():
