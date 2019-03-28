//
//  DeviceConnectionListener.hpp
//  PositionAcquisitionEngine
//
//  Created by Valentin Dufois on 2019-02-09.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef DeviceConnectionListener_hpp
#define DeviceConnectionListener_hpp

#include "../libraries.h"

// Forward Declarations
class PositionAcquisitionEngine;

/** Responds to Device connection events sent by OpenNI */
class DeviceConnectionListener: public openni::OpenNI::DeviceConnectedListener {
public:
    /**
     Called by OpenNI when a new device has been connected

     @param deviceInfo The newly connected device
     */
    void onDeviceConnected(const openni::DeviceInfo * deviceInfo);

    /** Reference to the Position Acquisition Engine */
    PositionAcquisitionEngine * pae;
};

#endif /* DeviceConnectionListener_hpp */
