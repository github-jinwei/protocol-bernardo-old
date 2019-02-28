//
//  PAEMacOSApp.hpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef PAEMacOSApp_h
#define PAEMacOSApp_h

// ///////////////////
// Forward Declaration
class PositionAcquisitionEngine;

class PAEMacOSAppStruct {
public:
    /** The Data Acquisition Engine */
    PositionAcquisitionEngine * pae;

    PAEMacOSAppStruct();
};

extern PAEMacOSAppStruct * PAEMacOSApp;

#endif /* PAEMacOSApp_h */
