//
//  PAEMacOSApp.cpp
//  PositionAcquisitionEngine
//
//  Created by Valentin Dufois on 2019-02-13.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "PAEMacOSApp.hpp"

#include "../PositionAcquisitionEngine/PositionAcquisitionEngine.hpp"

/** The Application global object */
PAEMacOSAppStruct * PAEMacOSApp = new PAEMacOSAppStruct();

PAEMacOSAppStruct::PAEMacOSAppStruct() {
    pae = PositionAcquisitionEngine::getInstance();
}
