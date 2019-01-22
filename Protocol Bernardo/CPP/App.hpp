//
//  CApp.hpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef CApp_h
#define CApp_h

#include "DAE/DataAcquisitionEngine.hpp"

class AppStruct {
public:
    DataAcquisitionEngine * dae;
};

AppStruct * App = new AppStruct();

#endif /* CApp_h */
