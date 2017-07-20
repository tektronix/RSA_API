# usage: python setup.py build_ext --inplace
from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
import numpy as np

setup(
    ext_modules=cythonize(
                # [Extension('rsa_api_test',
                # ['rsa_api_test.pyx'],
                [Extension('rsa_api',
                ['rsa_api.pyx'],
                libraries=['RSA_API'],
                include_dirs=['C:\\Tektronix\\RSA_API\\include',
                              np.get_include()],
                library_dirs=['C:\\Tektronix\\RSA_API\\lib\\x64'])])
)