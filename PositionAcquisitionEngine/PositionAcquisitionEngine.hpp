//
//  PositionAcquisitionEngine.hpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef PositionAcquisitionEngine_hpp
#define PositionAcquisitionEngine_hpp

#include "libraries.hpp"

#include "Structs/PAEStatus.h"
#include "Structs/PAEDeviceStatus.h"

#include "PAELinker.hpp"

// Forward Declarations
class PhysicalDevice;
class LiveViewer;

/** The Position Acquisition engine provides a way of interacting with
 acquisition devices supported by OpenNI ang getting video streams as well as
 real-time human pose estimation.

 Usage of the pae must respect a specific pattern as interaction with OpenNI and NiTE
 is quite unstable. The pae provides multiple checks to prevent most of erroneous actions but some still may happen.

 You access the available devices informations using the `getStatus()` method. This
 returns a structure holding informations about all the devices, their current state, name etc. As well as informations about the users they are tracking.

 The pae provides access to a live view of the video stream of each connected
 devices. This is controlled using the `enableLiveView()` and `disableLiveView()`
 methods BEFORE starting the engine. This will provide an OpenCV window for each
 connected device. When using live view, calls to `getStatus()` must be made from the
 main thread as this is when the windows will be refreshed.

 Actions on the devices are made using the pae directly, and providing serials for
 the concerned device.

 \todo Improve the live view update flow

 \bug OpenNI tends to crash when being stopped, current fix is to free the most of
    used resources without stopping OpenNI
 */
class PositionAcquisitionEngine:
	public openni::OpenNI::DeviceConnectedListener,
	public openni::OpenNI::DeviceDisconnectedListener {
public:

	// MARK: - Singleton
    
    /**
     Gives the instance of the Position Acquisition Engine.

     The PAE is a singleton to prevent having multiple instances communicating with
     the same pool of device at the same time.

     @return The pae instance
     */
    static PositionAcquisitionEngine * getInstance() {
        if(!_instance)
            _instance = new PositionAcquisitionEngine();
        
        return _instance;
    };

	// MARK: - Live View

    /**
     By enabling live view, the pae will create an OpenCV to display the color
     stream of the connected devices. Live view needs to be enabled before starting the pae.
     When using live view, `getStatus()` needs to be called from the main thread
     */
    void enableLiveView();

    /**
     Disable live view
     */
    void disableLiveView();

    /**
     Tell if live view is currently enabled

     @return True if enabled, false otherwise
     */
    inline bool isLiveViewEnabled() { return _liveView; }

	// MARK: - Main controls

    /**
     Init necessary drivers and execute a first parse for devices
     */
    void start();
    
    /**
     Stop all acquisition, disconnect from every device.
     */
    void stop();

	/**
	 Tell is the engine has been started

	 @return True if the engine is running
	 */
	inline bool isRunning() { return _isRunning; }
    
    /**
     Parse for any new devices connected
     */
    void parseForDevices();

	~PositionAcquisitionEngine();

	// MARK: - Status

	/**
	 Gets the status of all devices.

	 The provided status uses allocated memory that needs to be freed using
	 `freeStatus`.

	 @return The global status
	 */
	PAEStatusCollection * getStatus();

	inline PhysicalDevice * getDevice(const std::string &serial) {
		return _devices[serial];
	}

	/**
	 Free the ressources allocated for the given status.

	 Provides a uniform way for properly freeing a pae status

	 @param status The status to free
	 */
	static void freeStatus(PAEStatus * status);

	static void freeCollection(PAEStatusCollection * collection);

	// MARK: - Events

    /**
     Called by the deviceConnectionListener everytime a device is connected

     @param deviceInfo The connected device info
     */
    void onDeviceConnected(const openni::DeviceInfo * deviceInfo);
    
    /**
     Called by the deviceDisconnectionListener everytime a device is disconnected
     
     @param deviceInfo The disconnected device info
     */
    void onDeviceDisconnected(const openni::DeviceInfo * deviceInfo);


	// MARK: - Devices controls

    /**
     Open the connection with all the available devices
     */
    void connectAllDevices();
    
    /**
     Open the connection with the device specified

     @param serial Serial number of the device to connect to
     */
    void connectToDevice(const std::string &serial);

    /**
     Activate all the connected devices
     */
    void activateAllDevices();
    
    /**
     Activate the device, effectively startint to stream from it

     @param serial Serial number of the device
     */
    void activateDevice(const std::string &serial);

    /**
     Deactivate all the activated devices
     */
    void deactivateAllDevices();
    
    /**
     Stops streaming fron the device. Streaming can be resumed if needed

     @param serial Serial number of the device
     */
    void deactivateDevice(const std::string &serial);

	// MARK: - Network

    /**
     Gives access to the linker used by the PAE to emit and receive data

     @return Pointer to the underlying linker
     */
    inline PAELinker * linker() { return &_linker; }

    /**
     Tell the pae if it should emit its status to a server.

     @param shouldEmit True to emit
     */
    inline void shouldEmit(const bool &shouldEmit) { _isEmitter = shouldEmit; }
    
private:
	// MARK: - Singleton

    /** Singleton -> Private constructor */
    PositionAcquisitionEngine();

    /** The unique instance of the PAE */
    static PositionAcquisitionEngine * _instance;

    /** Tell if the PAE is currently running */
    bool _isRunning = false;


	// MARK: Network

    /** Tell if the pae should emit its status to other machines */
    bool _isEmitter = false;

	/** The linker used to send and receive status with other PAE on the network */
	PAELinker _linker;


	// MARK: Live view

    /** Tell if live view is enabled */
    bool _liveView = false;

	/** The viewerm, used when live view is enabled */
	LiveViewer * _viewer = nullptr;

	// MARK: Storage

    /** Holds the hostname of the current machine */
    char hostname[_POSIX_HOST_NAME_MAX + 1];
    
    /** All the available devices */
    std::map<std::string, PhysicalDevice *> _devices;
    
    /**
     Extract the serial of a device from its URI

     @param deviceInfo DeviceInfo for the device as given by OpenNI
     @return The device's serial
     */
    std::string getDeviceSerial(const openni::DeviceInfo * deviceInfo);
};

#endif /* PositionAcquisitionEngine_hpp */
