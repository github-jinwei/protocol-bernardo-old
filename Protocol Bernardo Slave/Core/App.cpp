//
//  App.cpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "App.hpp"

#include "../../PositionAcquisitionEngine/PositionAcquisitionEngine.hpp"

ApplicationObject * App = new ApplicationObject();

ApplicationObject::ApplicationObject() {
    pae = PositionAcquisitionEngine::getInstance();
}
