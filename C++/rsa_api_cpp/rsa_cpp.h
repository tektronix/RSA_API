#include <stdio.h>
#include <Windows.h>
#include <iostream>
#include <chrono>
#include <stdlib.h>
#include "C:/Tektronix/RSA_API/include/RSA_API.h"

using namespace RSA_API;
using namespace std;
using namespace std::chrono;

int search_connect();
void print_device_info(int* deviceIDs, int numFound, const char** deviceSerial, const char** deviceType);

Spectrum_Settings config_spectrum(double cf, double refLevel, double span, double rbw);
double* create_frequency_array(Spectrum_Settings specSet);
float* acquire_spectrum(Spectrum_Settings specSet);
int peak_power_detector(float* traceData, double* freq, Spectrum_Settings specSet);
void spectrum_example();

double* config_block_iq(double cf, double refLevel, double iqBw, int recordLength);
Cplx32* acquire_block_iq(int recordLength);
void block_iq_example();

void config_dpx(double cf, double refLevel, double span, double rbw);
DPX_FrameBuffer acquire_dpx(DPX_FrameBuffer fb);
void dpx_example();

void config_iq_stream(double cf, double refLevel, double bw, char* fileName, IQSOUTDEST dest, int suffixCtl, int durationMsec);
void iq_stream_example();
void iqstream_status_parser(uint32_t acqStatus);
void config_iq_stream(double cf, double refLevel, double bw, char* fileName, IQSOUTDEST dest, int suffixCtl, int durationMsec);

void config_if_stream(double cf, double refLevel, char* fileDir, char* fileName, int durationMsec);
void if_stream_example();

void if_playback();