//
//  DataAcquisitionEngine.hpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef DataAcquisitionEngine_hpp
#define DataAcquisitionEngine_hpp

#include <map>

#include "DAEStatus.h"
#include "Device.hpp"

class DataAcquisitionEngine {
public:
    
    static DataAcquisitionEngine * getInstance() {
        if(!_instance)
            _instance = new DataAcquisitionEngine();
        
        return _instance;
    };
    
    /**
     Holds a loop continuously checking for frame coming from the devices
     */
    void main();
    
    /**
     Parse for any new devices connected
     */
    void parseForDevices();
    
    /**
     Open the connection with the device specified

     @param serial Serial number of the device to connect to
     */
    void connectToDevice(const std::string &serial);
    
    /**
     Activate the device, effectively startint to stream from it

     @param serial Serial number of the device
     */
    void setDeviceActive(const std::string &serial);
    
    /**
     Stops streaming fron the device. Streaming can be resumed if needed

     @param serial Serial number of the device
     */
    void setDeviceIdle(const std::string &serial);
    
    /**
     Gets the status of all devices

     @return The global status
     */
    DAEStatus * getStatus();
    
    ~DataAcquisitionEngine();
    
private:
    DataAcquisitionEngine() {}
    static DataAcquisitionEngine * _instance;
    static bool _openNIInitialized;
    
    
    bool _running = true;
    
    std::map<std::string, Device *> _devices;
};

#endif /* DataAcquisitionEngine_hpp */
