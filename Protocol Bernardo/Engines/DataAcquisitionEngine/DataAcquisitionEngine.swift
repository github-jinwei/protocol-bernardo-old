//
//  DataAcquisitionEngine.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import Repeat

class DataAcquisitionEngine {
    // ////////////////
    // MARK: Properties
    
    /// Delegate for events listening
    weak var delegate: DataAcquisitionEngineDelegate?
    
    /// Holds the loop for the status fetcher
    internal var _statusFetcherLoop: Repeater?
    
    /// The engine state (internal)
    internal var _engineStatus: DAEStatus! {
        didSet {
            // Tell the delegate the status has been updated
            delegate?.dae(self, statusUpdated: self._engineStatus!)
        }
    }
    
    /// The engine state
    var status: DAEStatus! { return _engineStatus }
    
    // //////////////////////
    // MARK: Engine Lifecycle
    
    func start() {
        // Init the DAE on the CPP side on another thread
        DispatchQueue.global(qos: .userInitiated).async {
            DAEPrepare();
        }
        
        // Start a loop to query the CPP DAE status regularly
        _statusFetcherLoop = Repeater(interval: .milliseconds(100), mode: .infinite, tolerance: .milliseconds(100), queue: DispatchQueue.global(qos: .utility), observer: self.fetchStatus)
        _statusFetcherLoop?.start()
    }
    
    /// Calls the CPP DAE repeatedly to get its current status
    ///
    /// - Parameter repeater: The wrepeater
    func fetchStatus(_ repeater: Repeater) {
        _engineStatus = DAEGetStatus()!.pointee
    }
    
    /// Changes the device status to its next possible state
    ///
    /// - Parameter serial: The serial of the device
    func toggleDeviceStatus(withSerial serial: String) {
        // Make sure the serial is a valid one
        guard let device = _engineStatus.devices[serial] else {
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
    
    /// Refresh the available devices list
    func refreshDevicesList() {
        DAEParseForDevices()
    }
    
    /// Tries to connect to the device
    ///
    /// - Parameter deviceSerial: The serial of the device
    func connect(toDevice deviceSerial: String) {
        DAEConnectToDevice(deviceSerial.CString())
    }
    
    /// Tries to activate the device and starte collecting data
    ///
    /// - Parameter deviceSerial: The serial of the device
    func activate(device deviceSerial: String) {
        DAESetDeviceActive(deviceSerial.CString())
    }

    /// Pause data acquisition from the device. It still possible to resume it
    /// by calling `activate`
    ///
    /// - Parameter deviceSerial: The device's serial
    func pause(device deviceSerial: String) {
        DAESetDeviceIdle(deviceSerial.CString())
    }
    
    /// End any tracking task and disconnect properly from every device
    func end() {
        _statusFetcherLoop?.removeAllObservers(thenStop: true)
        _statusFetcherLoop = nil
        
        DAEEndAcquisition()
    }
}
