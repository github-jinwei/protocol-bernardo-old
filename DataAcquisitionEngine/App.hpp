//
//  CApp.hpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef CApp_h
#define CApp_h

// ///////////////////
// Forward Declaration
class DataAcquisitionEngine;

class AppStruct {
public:
    /** The Data Acquisition Engine */
    DataAcquisitionEngine * dae;

    AppStruct();
};

extern AppStruct * App;

#endif /* CApp_h */
