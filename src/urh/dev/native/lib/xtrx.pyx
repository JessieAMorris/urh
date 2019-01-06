cimport urh.dev.native.lib.cxtrx as cxtrx
from libc.stdlib cimport malloc, free
from libcpp cimport bool
import time

from urh.util.Logger import logger

TIMEOUT = 0.2

cdef cxtrx.xtrx_dev* _c_device

cdef size_t CHANNEL = 0
cdef bool IS_TX = False

cpdef get_device_list():
    """
    Obtain a list of XTRX devices attached to the system
    """
    cdef cxtrx.xtrx_device_info_t devs[32]
    cdef int res = cxtrx.xtrx_discovery(devs, 32)

    result = []
    cdef int i
    for i in range(res):
        result.append(devs[i].uniqname.decode("UTF-8"))

    return result

cpdef open(str device_identifier=""):
    # TODO: flag (4) should not be hardcoded but is taken from the example xtrx code
    return cxtrx.xtrx_open(device_identifier.encode('UTF-8'), 4, &_c_device)

cpdef set_tx(bool is_tx):
    global IS_TX
    IS_TX = <bool>is_tx

cpdef bool get_tx():
    return IS_TX

cpdef set_frequency(freq_hz):
    time.sleep(TIMEOUT)

    cdef cxtrx.xtrx_tune_t type

    if IS_TX:
        type = cxtrx.xtrx_tune_mode.XTRX_TUNE_TX_FDD
    else:
        type = cxtrx.xtrx_tune_mode.XTRX_TUNE_RX_FDD

    cdef double actual

    return cxtrx.xtrx_tune(_c_device, type, freq_hz, &actual)

cpdef set_channel(size_t channel):
    global CHANNEL
    CHANNEL = <size_t>channel
    return 0

cpdef size_t get_channel():
    return CHANNEL

cpdef stop_tx_mode():
    return cxtrx.xtrx_stop(_c_device, cxtrx.xtrx_direction.XTRX_TX)

cpdef stop_rx_mode():
    return cxtrx.xtrx_stop(_c_device, cxtrx.xtrx_direction.XTRX_RX)
