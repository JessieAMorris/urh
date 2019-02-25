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
        Device.Command.SET_FREQUENCY.name: "set_center_freq",
        Device.Command.SET_RF_GAIN.name: "set_device_gain",
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

    @property
    def device_parameters(self) -> OrderedDict:
        return OrderedDict([
            (self.Command.SET_SAMPLE_RATE.name, self.sample_rate),
            (self.Command.SET_FREQUENCY.name, self.frequency),
            (self.Command.SET_BANDWIDTH.name, self.bandwidth),
            (self.Command.SET_RF_GAIN.name, self.gain),
            (self.Command.SET_IF_GAIN.name, self.if_gain),
            (self.Command.SET_BB_GAIN.name, self.baseband_gain),
            ("identifier", self.device_serial)
        ])

    @classmethod
    def init_device(cls, ctrl_connection: Connection, is_tx: bool, parameters: OrderedDict):
        ctrl_connection.send("Initializing device...")
        xtrx.set_tx(is_tx)
        return super().init_device(ctrl_connection, is_tx, parameters)

    @classmethod
    def shutdown_device(cls, ctrl_connection: Connection, is_tx: bool):
        ctrl_connection.send("Stopping...")

        result = xtrx.stop_stream()

        ctrl_connection.send("Stopped: " + str(result))

        ctrl_connection.send("Closing...")

        result = xtrx.close()
        ctrl_connection.send("CLOSE:" + str(result))

        return True

    @classmethod
    def prepare_sync_receive(cls, ctrl_connection: Connection):
        ctrl_connection.send("Initializing stream...")
        xtrx.setup_stream()
        ctrl_connection.send("Stream setup")
        ret = xtrx.start_stream(cls.SYNC_RX_CHUNK_SIZE)
        ctrl_connection.send(f"Start stream: {ret}")
        return ret

    @classmethod
    def receive_sync(cls, data_conn: Connection):
        xtrx.recv_stream(data_conn, cls.SYNC_RX_CHUNK_SIZE)

    @classmethod
    def prepare_sync_send():
        pass

    @classmethod
    def send_sync():
        pass

    @property
    def has_multi_device_support(self):
        return True

    @staticmethod
    def unpack_complex(buffer):
        return np.frombuffer(buffer, dtype=np.complex64)

    @staticmethod
    def pack_complex(complex_samples: np.ndarray):
        arr = Array("f", 2 * len(complex_samples), lock=False)
        numpy_view = np.frombuffer(arr, dtype=np.float32)
        numpy_view[:] = complex_samples.view(np.float32)
        return arr
