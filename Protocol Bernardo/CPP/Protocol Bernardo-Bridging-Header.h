//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

// /////////////////////////////
// Data Acquisition Engine (DAE)

/**
 DAE C Interfaces
 */
#include "DAEStatus.h"

DAEStatus * DAEGetStatus();

void DAEPrepare();
void DAEParseForKinects();
void DAEConnectToKinect(const char * c_serial);
void DAESetKinectActive(const char * c_serial);
void DAESetKinectIdle(const char * c_serial);
void DAEEndAcquisition();
