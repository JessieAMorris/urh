cdef extern from "libxtrx/xtrx_api.h":
    struct xtrx_dev

    enum xtrx_flags:
        XTRX_O_LOGLVL_MASK = 0x000f
        XTRX_O_LOGLVL_LMS7_OFF  = 4
        XTRX_O_LOGLVL_LMS7_MASK = 0x00f0
        XTRX_O_RESET            = 0x0100

    ctypedef struct gtime_data:
        uint32_t sec
        uint32_t nsec

    ctypedef gtime_data gtime_data_t

    ctypedef uint64_t master_ts

    # int xtrx_open(const char* device, unsigned flags, struct xtrx_dev ** dev)
    # int xtrx_open_multi(unsigned numdevs, const char** devices, unsigned flags, struct xtrx_dev** dev)
    # int xtrx_open_list(const char* devices, const char* flags, struct xtrx_dev** dev)

    # void xtrx_close(struct xtrx_dev* dev)

    ctypedef enum xtrx_clock_source:
        XTRX_CLKSRC_INT = 0
        XTRX_CLKSRC_EXT = 1
        XTRX_CLKSRC_EXT_W1PPS_SYNC = 2

    ctypedef xtrx_clock_source structxtrx_clock_source_t

    int xtrx_set_ref_clk(struct xtrx_dev* dev, unsigned refclkhz, xtrx_clock_source_t clksrc)

    ctypedef struct xtrx_device_info:
        char uniqname[64]
        char proto[16]
        char speed[16]
        char serial[32]
        char devid[64]
    ctypedef xtrx_device_info xtrx_device_info_t

    int xtrx_discovery(xtrx_device_info_t* devs, size_t maxbuf)

    ctypedef enum xtrx_samplerate_flags:
        # Flags 1 throgh 8 are reserveed for debug
        XTRX_SAMPLERATE_DEBUG_NO_RX_SISO_LML = (1U << 0)
        XTRX_SAMPLERATE_DEBUG_SLOW_MCLK = (1U << 1)
        XTRX_SAMPLERATE_DEBUG_NO_RX_DECIM = (1U << 2)
        XTRX_SAMPLERATE_DEBUG_NO_TX_INTR = (1U << 3)
        XTRX_SAMPLERATE_FORCE_TX_INTR = (1U << 4)
        XTRX_SAMPLERATE_FORCE_RX_DECIM = (1U << 5)
        XTRX_SAMPLERATE_DEBUG_NO_RX_FCLK_GEN = (1U << 16)
        XTRX_SAMPLERATE_DEBUG_NO_TX_SISO_LML = (1U << 17)
        XTRX_SAMPLERATE_DEBUG_NO_8MA_LML = (1U << 18)
        XTRX_SAMPLERATE_DEBUG_NO_VIO_SET = (1U << 19)
        XTRX_SAMPLERATE_FORCE_UPDATE = (1U << 30)
        XTRX_SAMPLERATE_AUTO_DECIM = (1U << 31)
    ctypedef xtrx_samplerate_flags xtrx_samplerate_flags_t

    int xtrx_set_samplerate(struct xtrx_dev* dev, double cgen_rate, double rxrate,
                                 double txrate, unsigned flags, double* actualcgen, double* actualrx, double* actualtx)

    ctypedef enum xtrx_channel:
        XTRX_CH_A  = 1
        XTRX_CH_B  = 2
        XTRX_CH_AB = XTRX_CH_A | XTRX_CH_B
        XTRX_CH_ALL = ~0U
    ctypedef xtrx_channel xtrx_channel_t

    ctypedef enum xtrx_tune:
        XTRX_TUNE_RX_FDD
        XTRX_TUNE_TX_FDD
        XTRX_TUNE_TX_AND_RX_TDD
        XTRX_TUNE_BB_RX
        XTRX_TUNE_BB_TX
    ctypedef  xtrx_tune xtrx_tune_t

    int xtrx_tune(struct xtrx_dev* dev, xtrx_tune_t type, double freq, double *actualfreq)
    int xtrx_tune_ex(struct xtrx_dev* dev, xtrx_tune_t type, xtrx_channel_t ch, double freq, double *actualfreq)
    int xtrx_tune_tx_bandwidth(struct xtrx_dev* dev, xtrx_channel_t ch, double bw, double *actualbw)
    int xtrx_tune_rx_bandwidth(struct xtrx_dev* dev, xtrx_channel_t ch, double bw, double *actualbw)

    ctypedef enum xtrx_gain_type:
        XTRX_RX_LNA_GAIN
        XTRX_RX_TIA_GAIN
        XTRX_RX_PGA_GAIN
        XTRX_TX_PAD_GAIN
        XTRX_RX_LB_GAIN
    ctypedef xtrx_gain_type xtrx_gain_type_t

    int xtrx_set_gain(struct xtrx_dev* dev, xtrx_channel_t ch, xtrx_gain_type_t gt, double gain, double *actualgain)

    ctypedef enum xtrx_antenna:
        XTRX_RX_L
        XTRX_RX_H
        XTRX_RX_W
        XTRX_TX_H
        XTRX_TX_W
        XTRX_RX_L_LB
        XTRX_RX_W_LB
        XTRX_RX_AUTO
        XTRX_TX_AUTO
    ctypedef xtrx_antenna xtrx_antenna_t

    int xtrx_set_antenna(struct xtrx_dev* dev, xtrx_antenna_t antenna)
    int xtrx_set_antenna_ex(struct xtrx_dev* dev, xtrx_channel_t ch, xtrx_antenna_t antenna)

    ctypedef enum xtrx_wire_format:
        XTRX_WF_8  = 1
        XTRX_WF_12 = 2
        XTRX_WF_16 = 3
    ctypedef xtrx_wire_format xtrx_wire_format_t

    ctypedef enum xtrx_direction:
        XTRX_RX = 1
        XTRX_TX = 2
        XTRX_TRX = XTRX_RX | XTRX_TX
    ctypedef xtrx_direction xtrx_direction_t

    ctypedef enum xtrx_host_format:
        XTRX_IQ_FLOAT32 = 1
        XTRX_IQ_INT16   = 2
        XTRX_IQ_INT8    = 3
    ctypedef xtrx_host_format xtrx_host_format_t


    ctypedef enum xtrx_run_params_flags:
        XTRX_RUN_DIGLOOPBACK = 1
        XTRX_RUN_RXLFSR      = 2
        XTRX_RUN_GTIME       = 4
    ctypedef xtrx_run_params_flags xtrx_run_params_flags_t

    ctypedef enum xtrx_run_sp_flags:
        XTRX_RSP_TEST_SIGNAL_A  = 2
        XTRX_RSP_TEST_SIGNAL_B  = 4
        XTRX_RSP_SWAP_AB        = 8
        XTRX_RSP_SWAP_IQ        = 16
        XTRX_RSP_SISO_MODE      = 32
        XTRX_RSP_SCALE          = 64
        XTRX_RSP_NO_DC_CORR     = 128
        XTRX_RSP_SWAP_IQB       = 256
        XTRX_STREAMDSP_1        = 512
        XTRX_STREAMDSP_2        = 1024
    ctypedef xtrx_run_sp_flags xtrx_run_sp_flags_t

    ctypedef struct xtrx_run_stream_params:
        xtrx_wire_format_t wfmt
        xtrx_host_format_t hfmt
        xtrx_channel_t chs
        uint32_t paketsize
        uint32_t flags
        float scale
        uint32_t reserved[12 - 6]
    ctypedef xtrx_run_stream_params xtrx_run_stream_params_t

    ctypedef struct xtrx_run_params:
        xtr x_direction_t         dir
        unsigned                 nflags
        xtrx_run_stream_params_t tx
        xtrx_run_stream_params_t rx
        master_ts                rx_stream_start
        void*                    tx_repeat_buf
        gtime_data_t             gtime
        uint32_t                 reserved[8]
    ctypedef xtrx_run_params xtrx_run_params_t

    ctypedef enum xtrx_gtime_cmd:
        XTRX_GTIME_ENABLE_INT
        XTRX_GTIME_ENABLE_INT_WEXT
        XTRX_GTIME_ENABLE_INT_WEXTE
        XTRX_GTIME_ENABLE_EXT
        XTRX_GTIME_DISABLE
        XTRX_GTIME_GET_RESOLUTION
        XTRX_GTIME_SET_GENSEC
        XTRX_GTIME_GET_CUR
        XTRX_GTIME_APPLY_CORRECTION
        XTRX_GTIME_GET_GPSPPS_DELTA
    ctypedef xtrx_gtime_cmd xtrx_gtime_cmd_t

    int xtrx_gtime_op(struct xtrx_dev* dev, int devno, xtrx_gtime_cmd_t cmd, gtime_data_t in, gtime_data_t *out)

    enum xtrx_gpios:
        XTRX_GPIO_ALL = -1
        XTRX_GPIO1 = 0
        XTRX_GPIO_PPS_I = XTRX_GPIO1
        XTRX_GPIO2 = 1
        XTRX_GPIO_PPS_O = XTRX_GPIO2
        XTRX_GPIO3 = 2
        XTRX_GPIO_TDD = XTRX_GPIO3
        XTRX_GPIO4 = 3
        XTRX_GPIO5 = 4
        XTRX_GPIO_LED_WWAN = XTRX_GPIO5
        XTRX_GPIO6 = 5
        XTRX_GPIO_LED_WLAN = XTRX_GPIO6
        XTRX_GPIO7 = 6
        XTRX_GPIO_LED_WPAN = XTRX_GPIO7
        XTRX_GPIO8 = 7
        XTRX_GPIO9 = 8
        XTRX_GPIO_EXT0 = XTRX_GPIO9
        XTRX_GPIO10 = 9
        XTRX_GPIO_EXT1 = XTRX_GPIO10
        XTRX_GPIO11 = 10
        XTRX_GPIO_EXT2 = XTRX_GPIO11
        XTRX_GPIO12 = 11
        XTRX_GPIO_EXT3 = XTRX_GPIO12
        XTRX_GPIO_EPPS_O = XTRX_GPIO12
        XTRX_LED = 12
        XTRX_SAFE = 13
        XTRX_GPIOS_TOTAL = 14

    ctypedef enum xtrx_gpio_func:
        XTRX_GPIO_FUNC_IN
        XTRX_GPIO_FUNC_OUT
        XTRX_GPIO_FUNC_PPS_O
        XTRX_GPIO_FUNC_PPS_I
        XTRX_GPIO_FUNC_ALT0
        XTRX_GPIO_FUNC_ALT1
        XTRX_GPIO_FUNC_ALT2

    ctypedef xtrx_gpio_func xtrx_gpio_func_t

    int xtrx_gpio_configure(struct xtrx_dev* dev, int devno, int gpio_num, xtrx_gpio_func_t function)
    int xtrx_gpio_out(struct xtrx_dev* dev, int devno, unsigned out)
    int xtrx_gpio_clear_set(struct xtrx_dev* dev, int devno, unsigned clear_msk, unsigned set_msk)
    int xtrx_gpio_in(struct xtrx_dev* dev, int devno, unsigned* in)
    void xtrx_run_params_init(xtrx_run_params_t* params)
    int xtrx_run_ex(struct xtrx_dev* dev, const xtrx_run_params_t* params)
    int xtrx_stop(struct xtrx_dev* dev, xtrx_direction_t dir)

    enum xtrx_send_ex_flags:
        XTRX_TX_DISCARDED_TO = 1
        XTRX_TX_SEND_ZEROS = 2
        XTRX_TX_DONT_BUFFER = 4
        XTRX_TX_TIMEOUT = 8
        XTRX_TX_NO_DISCARD = 16

    ctypedef struct xtrx_send_ex_info:
        unsigned samples
        unsigned flags
        master_ts ts
        const void* const* buffers
        unsigned buffer_count
        unsigned timeout
        unsigned out_flags
        unsigned out_samples
        master_ts out_txlatets
    ctypedef xtrx_send_ex_info xtrx_send_ex_info_t

    int xtrx_send_sync_ex(struct xtrx_dev* dev, xtrx_send_ex_info_t* info)

    enum:
        MAX_RECV_BUFFERS = 2

    enum xtrx_recv_ex_info_flags:
        RCVEX_STOP_ON_OVERRUN = 1
        RCVEX_DONT_WAIT       = 2
        RCVEX_DONT_INSER_ZEROS = 4
        RCVEX_DROP_OLD_ON_OVERFLOW = 8
        RCVEX_EXTRA_LOG = 16
        RCVEX_TIMOUT = 32

    enum xtrx_recv_ex_info_events:
        RCVEX_EVENT_OVERFLOW   = 1
        RCVEX_EVENT_FILLED_ZERO = 2

    ctypedef struct xtrx_recv_ex_info:
        unsigned samples
        unsigned buffer_count
        void* const* buffers
        unsigned flags
        unsigned timeout
        unsigned out_samples
        unsigned out_events
        master_ts out_first_sample
        master_ts out_overrun_at
        master_ts out_resumed_at
    ctypedef xtrx_recv_ex_info xtrx_recv_ex_info_t

    int xtrx_recv_sync_ex(struct xtrx_dev* dev, xtrx_recv_ex_info_t* info)


