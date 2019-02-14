//
//  App.cpp
//  DataAcquisitionEngine
//
//  Created by Valentin Dufois on 2019-02-13.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "App.hpp"

#include "DAE/DataAcquisitionEngine.hpp"

/** The Application global object */
AppStruct * App = new AppStruct();

AppStruct::AppStruct() {
    dae = DataAcquisitionEngine::getInstance();
}
