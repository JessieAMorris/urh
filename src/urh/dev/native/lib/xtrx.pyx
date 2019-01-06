cimport urh.dev.native.lib.cxtrx as cxtrx
from libc.stdlib cimport malloc, free
from libc.string cimport memcpy
from libcpp cimport bool
from ctypes import c_uint
import time

from urh.util.Logger import logger

TIMEOUT = 0.25

cdef cxtrx.xtrx_dev* _c_device
cdef double _actual_rxsample_rate
cdef double _actual_txsample_rate

cdef cxtrx.xtrx_run_params_t _stream_params

cdef cxtrx.xtrx_channel_t CHANNEL = cxtrx.xtrx_channel.XTRX_CH_A
cdef bool IS_TX = False

cdef int MAX_PAKETS = 65536

cpdef set_tx(bool is_tx):
    global IS_TX
    IS_TX = <bool>is_tx

    return 0

cpdef bool get_tx():
    return IS_TX

cpdef set_channel(size_t channel):
    global CHANNEL

    cdef cxtrx.xtrx_channel_t actual_channel

    if (channel == 0):
        actual_channel = cxtrx.xtrx_channel.XTRX_CH_A;
    elif (channel == 1):
        actual_channel = cxtrx.xtrx_channel.XTRX_CH_B;
    else:
        raise Exception("Invalid XTRX channel")

    CHANNEL = actual_channel
    return 0

cpdef cxtrx.xtrx_channel_t get_channel():
    return CHANNEL

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
    cxtrx.xtrx_log_setlevel(cxtrx.xtrx_flags.XTRX_O_LOGLVL_LMS7_OFF, NULL)

    return cxtrx.xtrx_open(device_identifier.encode('UTF-8'),
            cxtrx.xtrx_flags.XTRX_O_LOGLVL_LMS7_OFF | cxtrx.xtrx_flags.XTRX_O_RESET, &_c_device)

cpdef int set_center_freq(double center_freq):
    cdef cxtrx.xtrx_tune_t type

    if IS_TX:
        type = cxtrx.xtrx_tune_mode.XTRX_TUNE_TX_FDD
    else:
        type = cxtrx.xtrx_tune_mode.XTRX_TUNE_RX_FDD

    cdef double actual

    time.sleep(TIMEOUT)

    return cxtrx.xtrx_tune(_c_device, type, center_freq, &actual)

cpdef int set_sample_rate(double sample_rate):
    global _actual_txsample_rate
    global _actual_rxsample_rate

    cdef double master

    time.sleep(TIMEOUT)

    cdef int ret
    cdef double txsample_rate = 0
    cdef double rxsample_rate = 0

    if IS_TX:
        txsample_rate = sample_rate
    else:
        rxsample_rate = sample_rate

    ret = cxtrx.xtrx_set_samplerate(_c_device, 0, rxsample_rate, txsample_rate, 0,
            &master, &_actual_rxsample_rate, &_actual_txsample_rate);

    return ret

cpdef int set_bandwidth(double bandwidth):
    cdef double actual

    if IS_TX:
        return cxtrx.xtrx_tune_tx_bandwidth(_c_device, CHANNEL, bandwidth, &actual)
    else:
        return cxtrx.xtrx_tune_rx_bandwidth(_c_device, CHANNEL, bandwidth, &actual)

cpdef int set_rf_gain(double normalized_gain):
    cdef double actual

    if IS_TX:
        return cxtrx.xtrx_set_gain(_c_device, CHANNEL, cxtrx.xtrx_gain_type.XTRX_TX_PAD_GAIN, normalized_gain, &actual)
    else:
        return cxtrx.xtrx_set_gain(_c_device, CHANNEL, cxtrx.xtrx_gain_type.XTRX_RX_LNA_GAIN, normalized_gain, &actual)

cpdef int setup_stream():
    cdef cxtrx.xtrx_run_stream_params_t *params

    if IS_TX:
        _stream_params.dir = cxtrx.xtrx_direction.XTRX_TX
        params = &_stream_params.tx
        cxtrx.xtrx_stop(_c_device, cxtrx.xtrx_direction.XTRX_TX);
    else:
        _stream_params.dir = cxtrx.xtrx_direction.XTRX_RX
        params = &_stream_params.rx
        cxtrx.xtrx_stop(_c_device, cxtrx.xtrx_direction.XTRX_RX);

    params.wfmt = cxtrx.xtrx_wire_format.XTRX_WF_16
    params.hfmt = cxtrx.xtrx_host_format.XTRX_IQ_FLOAT32
    params.chs = CHANNEL
    params.paketsize = 0
    params.flags = 0

cpdef int start_stream(int num_samples):
    _stream_params.nflags = 0

    if IS_TX:
        if _actual_txsample_rate < 1:
            raise Exception("TX Sample Rate not set")

        _stream_params.tx_repeat_buf = NULL
    else:
        if _actual_rxsample_rate < 1:
            raise Exception("RX Sample Rate not set")

        _stream_params.rx_stream_start = 4096

    return cxtrx.xtrx_run_ex(_c_device, &_stream_params)

cpdef int stop_stream():
    if IS_TX:
        return cxtrx.xtrx_stop(_c_device, cxtrx.xtrx_direction.XTRX_TX)
    else:
        return cxtrx.xtrx_stop(_c_device, cxtrx.xtrx_direction.XTRX_RX)

cpdef int close():
    global _c_device

    cxtrx.xtrx_close(_c_device);
    _c_device = NULL

cpdef int recv_stream(connection, int num_samples):
    cdef float* result = <float*>malloc(num_samples * 2 * sizeof(float))
    if not result:
        raise MemoryError()

    cdef float* buff = <float *>malloc(num_samples * 2 * sizeof(float))
    if not buff:
        raise MemoryError()

    cdef void ** buffs = <void **> &buff

    cdef cxtrx.xtrx_recv_ex_info rex
    rex.samples = num_samples
    rex.buffer_count = 1
    rex.buffers = buffs
    rex.flags = cxtrx.xtrx_recv_ex_info_flags.RCVEX_DONT_INSER_ZEROS

    cdef int current_index = 0
    cdef int i = 0

    try:
        while current_index < 2*num_samples:
            res = cxtrx.xtrx_recv_sync_ex(_c_device, &rex)
            if res == 0:
                memcpy(&result[current_index], &buff[0], 2 * rex.out_samples * sizeof(float))

                current_index += (2 * rex.out_samples)

        connection.send_bytes(<float[:2*num_samples]> result)
    finally:
        free(buff)
        free(result)

