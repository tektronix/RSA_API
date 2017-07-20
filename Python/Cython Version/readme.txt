Tektronix RSA_API for Python using Cython


Prerequisites:
1. Windows 7 64 bit (it will probably work on 8 and 10 as well, but I haven't
tested it)
2. Python 3.6.x (tested on Python 3.6.0), NumPy 1.11.3, Matplotlib 2.0.0.
Installing Anaconda is the easiest way to do this if you don't already have
Python 3 (https://www.continuum.io/downloads).
3. RSA_API version 3.9.0029 or later (http://www.tek.com/model/rsa306-software)
    a. Make sure to add C:\Tektronix\RSA_API\lib\x64 to the system PATH.
    Failure to do this has wasted a lot of my time in the past, don't let it
     happen to you
4. A Tektronix RSA306B or RSA500/600 series spectrum analyzer.


Description:
The goal behind this project was to enable the use of the RSA_API in Python
without having to use ctypes to manage the Python-C type conversion required
by the API.

Cython creates a Cython module (*.pyd file) that is built from a Cython file
(*.pyx) and Cython header (*.pxd). The beauty of Cython is that it compiles
a Python module that can contain functions, structs, and enum types exported
from a dll. I've handled all the type conversions and pointer handling in
the Cython module so users can simply import the .pyd file as they would
import any other Python module and use the functions and structs defined there.


Usage:
There are three usage options.
1. Use the .pyd file I've already generated (example in cython_example.py)
2. Compile the .pyd file yourself (run "python setup.py build_ext --inplace"
 in the command prompt at the directory containing this readme file)
3. Write your own .pyx/.pxd file/edit the ones here and compile the Cython
module from scratch. You'd then go back to 1.


Helpful links:
http://docs.cython.org/en/latest/src/userguide/external_C_code.html
http://docs.cython.org/en/latest/src/tutorial/strings.html
http://docs.cython.org/en/latest/src/userguide/language_basics.html
http://docs.cython.org/en/latest/src/userguide/source_files_and_compilation.html

As always, community contribution is welcome.
