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
#include <unistd.h>
#include <limits.h>

#include "DAEStatus.h"
#include "DeviceConnectionListener.hpp"
#include "DeviceDisconnectionListener.hpp"

// Forward Declarations
class PhysicalDevice;

class DataAcquisitionEngine {
public:
    
    static DataAcquisitionEngine * getInstance() {
        if(!_instance)
            _instance = new DataAcquisitionEngine();
        
        return _instance;
    };

    /**
     By enabling live view, the dae will create an OpenCV to display the color
     stream of the connected devices. Live view needs to be enabled before starting the dae.
     When using live view, `getStatus()` needs to be called from the main thread
     */
    void enableLiveView();

    /**
     Disable live view
     */
    void disableLiveView();

    inline bool isLiveViewEnabled() { return _liveView; }
    
    /**
     Init necessary drivers and execute a first parse for devices
     */
    void start();
    
    /**
     Stop all acquisition, disconnect from everuy device.
     */
    void stop();
    
    /**
     Parse for any new devices connected
     */
    void parseForDevices();
    
    /**
     Called by the deviceConnectionListener everytime a device is connected

     @param deviceInfo The connected device info
     */
    void onNewDevice(const openni::DeviceInfo * deviceInfo);
    
    /**
     Called by the deviceDisconnectionListener everytime a device is disconnected
     
     @param deviceInfo The disconnected device info
     */
    void onDeviceDisconnected(const openni::DeviceInfo * deviceInfo);
    
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
    DataAcquisitionEngine();
    static DataAcquisitionEngine * _instance;
    
    /** Tell if OpenNI has already been initialized or not */
    static bool _openNIInitialized;

    bool _liveView = false;

    char hostname[_POSIX_HOST_NAME_MAX + 1];
    
    /** All the available devices */
    std::map<std::string, PhysicalDevice *> _devices;

    /** New device connection listener */
    DeviceConnectionListener _connectionListener;
    
    /** Device disconnection listener */
    DeviceDisconnectionListener _disconnectionListener;
    
    /**
     Extract the serial of a device from its URI

     @param deviceInfo DeviceInfo for the device as given by OpenNI
     @return The device's serial
     */
    std::string getDeviceSerial(const openni::DeviceInfo * deviceInfo);
};

extern "C" {
    struct DAEStatus * DAEGetStatus();

    void DAEEnableLiveView();
    void DAEDisableLiveView();
    void DAEPrepare();
    void DAEConnectToDevice(const char * c_serial);
    void DAESetDeviceActive(const char * c_serial);
    void DAESetDeviceIdle(const char * c_serial);
    void DAEEndAcquisition();
}

#endif /* DataAcquisitionEngine_hpp */