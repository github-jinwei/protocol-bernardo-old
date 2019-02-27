//
//  DataAcquisitionEngine.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import Repeat

/// The Data Acquisition Engine provides an interface with the available acquisition
/// devices.
///
/// The data acquisition engine uses the DataAcquisitionEngine static library to communicate
/// with the devives. Itself runs using OpenNI and the provided driver by the devices
/// constructors.
///
/// The Data Acquisition Engine receive the tracking informations from the devices,
/// and gives it to its observers using the `DataAcquisitionEngineObserver.dae(_:, devicesStatusUpdated:)` method
///
/// The current support of the kinect on Mac, as well as NiTE2 for skeleton tracking,
/// is quite instable. Some actions like connecting to a device needs to be done on the main thread
/// to prevent crashes, and closing algorithm seems to crashes for unknown reasons.
///
/// The Data Acquisition Engine support live view for the connected devices, albeit in a limited form. Live view can only be toggled when the engine isn't running, and
/// requires status updates to be made from the main thread. This has negative impact on the application preformance but not on the underlying DAE process. Live view should only be used during calibration process or while constructing an installation.
class DataAcquisitionEngine {

    // ////////////////
    // MARK: Delegates

    /// Delegate for events listening
    internal var observers: [DataAcquisitionEngineObserver] = []

    /// Add a new observer to the DAE. Observers are kept as strong references,
    /// you need to remove them to prevent memory leaks
    ///
    /// - Parameter observer: The observer to add
    func addObsever(_ observer: DataAcquisitionEngineObserver) {
        observers.append(observer)
    }

    /// Removes the given oberserver from the list of obervers
    ///
    /// - Parameter observer: The observer to remove
    func removeObserver(_ observer: DataAcquisitionEngineObserver) {
        observers.removeAll { $0 === observer }
    }


    // ////////////////
    // MARK: - Properties

    var refreshRate: UInt {
        return 30
    }

    /// Holds the loop for the status fetcher
    private var statusFetcherLoop: Repeater?

    /// The devices handled by the engine
    private var devices = ConnectedDevices()

    /// Wrapper with all the connected devices
    var connectedDevices: ConnectedDevices {
        return devices
    }

    /// Tell if the DAE is currently running
    var isRunning: Bool {
        get {
            return statusFetcherLoop != nil
        }
    }

    /// Tell if live view is enabled
    var isLiveViewEnabled: Bool = false


    // //////////////////
    // MARK: - Live View

    /// Enable or disable live view for the devices connected to this machine.
    ///
    /// Live view requires fetch calls to be made from the main thread. This has
    /// an impact on the application performance and responsiveness as status
    /// updates are not made in the background anymore.
    func toggleLiveView() {
        if isRunning {
            return
        }

        if isLiveViewEnabled {
            DAEDisableLiveView()
            isLiveViewEnabled = false
            return
        }

        DAEEnableLiveView()
        isLiveViewEnabled = true
    }
    


    // //////////////////////
    // MARK: - Engine Lifecycle

    /// Start the engine, parse for available devices and start the status fetcher loop. Starting from here, all observers will continuously receive the current state of the connected devices
    func start() {
        guard !isRunning else { return }

        // Init the DAE on the CPP side on another thread
        DispatchQueue.global(qos: .userInitiated).async {
            DAEPrepare()
        }

        // Start a loop to query the CPP DAE status regularly
        statusFetcherLoop = Repeater(interval: .milliseconds(Int(10000 / refreshRate)),
                                     mode: .infinite,
                                     tolerance: .milliseconds(Int(1000 / refreshRate)),
                                     queue: DispatchQueue.global(qos: .utility),
                                     observer: self.fetchStatus)
        statusFetcherLoop?.start()
    }

    /// Select the appropriate queue then calls the CPP DAE to get
    /// its current status
    ///
    /// - Parameter repeater: The wrepeater
    func fetchStatus(_: Repeater) {
        if isLiveViewEnabled {
            // Live view requires fetches to be executed from the main queue
            DispatchQueue.main.async {
                self.doFetchStatus()
            }
            return
        }

        self.doFetchStatus()
    }

    /// Actually calls the dae to get and store its status
    internal func doFetchStatus() {
        // Get the engine status
        let statusPointer = DAEGetStatus()

        // Copy informations from the status pointer to our own struct
        devices.setDevices(statusPointer!.pointee.copyAndDeallocate())

        // Free the memory
        statusPointer?.deallocate()

        // Tell all the observes
        observers.forEach { $0.dae(self, devicesStatusUpdated: devices) }
    }

    /// Changes the device status to its next possible state
    ///
    /// - Parameter serial: The serial of the device
    func toggleDeviceStatus(withSerial serial: Serial) {
        // Make sure the serial is a valid one
        guard let device = devices.with(serial: serial) else {
            return
        }

        // Depending on the current device statem switch to the next one
        switch device.state {
        case DEVICE_IDLE: connect(toDevice: serial)
        case DEVICE_READY: activate(device: serial)
        case DEVICE_ACTIVE: pause(device: serial)
        default: return
        }
    }

    /// Tries to connect to the device
    ///
    /// - Parameter deviceSerial: The serial of the device
    func connect(toDevice deviceSerial: Serial) {
        DAEConnectToDevice(deviceSerial.CString())
    }

    /// Tries to activate the device and starte collecting data
    ///
    /// - Parameter deviceSerial: The serial of the device
    func activate(device deviceSerial: Serial) {
        DAESetDeviceActive(deviceSerial.CString())
    }

    /// Pause data acquisition from the device. It still possible to resume it
    /// by calling `activate`
    ///
    /// - Parameter deviceSerial: The device's serial
    func pause(device deviceSerial: Serial) {
        DAESetDeviceIdle(deviceSerial.CString())
    }

    /// End any tracking task and disconnect properly from every device
    func end() {
        guard isRunning else { return }

        statusFetcherLoop?.removeAllObservers(thenStop: true)
        statusFetcherLoop = nil

        DAEEndAcquisition()
    }

    /// Closes the DAE drivers on closing if needed
    deinit {
        end()
    }
}
