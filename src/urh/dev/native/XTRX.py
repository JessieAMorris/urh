from collections import OrderedDict

import numpy as np
from multiprocessing import Array

from urh.dev.native.Device import Device
from urh.dev.native.lib import xtrx
from multiprocessing.connection import Connection


class XTRX(Device):
    DEVICE_LIB = xtrx
    ASYNCHRONOUS = False
    DEVICE_METHODS = Device.DEVICE_METHODS.copy()
    DEVICE_METHODS.update({
        Device.Command.SET_FREQUENCY.name: "set_frequency",
        Device.Command.SET_BANDWIDTH.name: "set_baseband_filter_bandwidth"
    })

    SYNC_RX_CHUNK_SIZE = 8192
    SYNC_TX_CHUNK_SIZE = 8192 * 2

    @classmethod
    def get_device_list(cls):
        return xtrx.get_device_list()

    @classmethod
    def adapt_num_read_samples_to_sample_rate(cls, sample_rate):
        cls.SYNC_RX_CHUNK_SIZE = 8192 * int(sample_rate / 1e6)

    @classmethod
    def setup_device(cls, ctrl_connection: Connection, device_identifier):
        ret = xtrx.open(device_identifier)
        msg = "SETUP"
        if device_identifier:
            msg += " ({})".format(device_identifier)
        msg += ": "+str(ret)
        ctrl_connection.send(msg)

        return ret == 0

    @classmethod
    def shutdown_device(cls, ctrl_conn: Connection, is_tx: bool):
        if is_tx:
            result = xtrx.stop_tx_mode()
            ctrl_conn.send("STOP TX MODE:" + str(result))
        else:
            result = xtrx.stop_rx_mode()
            ctrl_conn.send("STOP RX MODE:" + str(result))

        result = xtrx.close()
        ctrl_conn.send("CLOSE:" + str(result))

        return True

    @classmethod
    def prepare_sync_receive(cls, ctrl_connection: Connection):
        #TODO
        ctrl_connection.send("Initializing stream...")
        xtrx.setup_stream()
        return usrp.start_stream(cls.SYNC_RX_CHUNK_SIZE)

    @classmethod
    def init_device(cls, ctrl_connection: Connection, is_tx: bool, parameters: OrderedDict):
        xtrx.set_tx(is_tx)
        return super().init_device(ctrl_connection, is_tx, parameters)

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
        return True

    @staticmethod
    def unpack_complex(buffer):
        pass

    @staticmethod
    def pack_complex():
        pass
