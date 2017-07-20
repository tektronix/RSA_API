# rsa_api_python_36

The RSA_API allows anyone to write scripts, lightweight applications, or plugins that directly control and acquire data from Tektronix USB RSAs without needing to run SignalVu-PC.
This repository contains complete RSA_API usage examples for Python, including configuring the RSA hardware, capturing and plotting data, and streaming IF and IQ data to disk.

There are two versions, the Python-ctypes version and a Cython version.
The Python-ctypes version calls functions directly from RSA_API.dll and handles all the Python-C type conversions in the script itself. There is a very detailed PDF walkthrough for this version.
The Cython version is a compiled Cython module that handles all the Python-C type conversions in the module itself and there is no need to use ctypes at all in the final script. I expect this will be easiest to use even without a detailed walkthrough since the final script can be written in pure Python+NumPy. See Cython/readme.txt for more details.
