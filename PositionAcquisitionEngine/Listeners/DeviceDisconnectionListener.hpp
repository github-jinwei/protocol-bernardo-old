//
//  DeviceDisconnectionListener.hpp
//  PositionAcquisitionEngine
//
//  Created by Valentin Dufois on 2019-02-09.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef DeviceDisconnectedListener_hpp
#define DeviceDisconnectedListener_hpp

#include "../libraries.h"

// Forward Declarations
class PositionAcquisitionEngine;

/** Responds to Device disconnection events sent by OpenNI */
class DeviceDisconnectionListener: public openni::OpenNI::DeviceDisconnectedListener {
public:
    /** Called by openNi when a device disconnect */
    void onDeviceDisconnected(const openni::DeviceInfo * deviceInfo);

    /** Reference to the Position Acquisition Engine */
    PositionAcquisitionEngine * pae;
};

#endif /* DeviceDisconnectedListener_hpp */
