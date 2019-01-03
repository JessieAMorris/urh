cimport urh.dev.native.lib.cxtrx as cxtrx
from libc.stdlib cimport malloc, free

from urh.util.Logger import logger

cdef xtrx_dev* c_device

cpdef size_t CHANNEL = 0
cpdef bool IS_TX = False

cpdef set_tx(bool is_tx):
    global IS_TX
    IS_TX = <bool>is_tx

cpdef bool get_tx():
    return IS_TX

cpdef set_channel(size_t channel):
    global CHANNEL
    CHANNEL = <size_t>channel
    return 0

cpdef size_t get_channel():
    return CHANNEL

cpdef list get_device_list():
    """
    Obtain a list of XTRX devices attached to the system
    """
    cdef cxtrx.xtrx_device_info_t devs[32]
    cdef int res = xtrx_discovery(devs, 32)
    if res:
        return True
    else:
        return False