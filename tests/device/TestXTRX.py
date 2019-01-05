import unittest
import sys
import time

import numpy as np

# Use local libraries instead of system
sys.path.insert(0, '../../src')

from urh.util import util

util.set_shared_library_path()


#from urh.dev.native.XTRX import XTRX
from urh.dev.native.lib import xtrx


class TestXTRX(unittest.TestCase):
    def test_cython_wrapper(self):

        xtrx_found = xtrx.get_device_list()
        if xtrx_found:
            print("XTRX Found:")
        else:
            print("XTRX not found:")


if __name__ == "__main__":
    unittest.main()
