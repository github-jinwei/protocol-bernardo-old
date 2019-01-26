//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

// /////////////////////////////
// Data Acquisition Engine (DAE)

/**
 DAE C Interfaces
 */
#include "DAE/Structs/DAEStatus.h"

struct DAEStatus * DAEGetStatus();

void DAEPrepare();
void DAEParseForDevices();
void DAEConnectToDevice(const char * c_serial);
void DAESetDeviceActive(const char * c_serial);
void DAESetDeviceIdle(const char * c_serial);
void DAEEndAcquisition();
