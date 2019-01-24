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
    internal var _engineStatus: DAEStatus!
    
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
        self._engineStatus = DAEGetStatus()!.pointee
        self.delegate?.dae(self, statusUpdated: self._engineStatus!)
    }
    
    func toggleDeviceStatus(withSerial serial: String) {
        guard let device = _engineStatus.devices[serial] else {
            return
        }
        
        switch device.state.rawValue {
        case 1: connect(toDevice: serial)
        case 3: activate(device: serial)
        case 4: pause(device: serial)
        default: return
        }
    }
    
    func refreshDevicesList() {
        DAEParseForDevices()
    }
    
    func connect(toDevice deviceSerial: String) {
        DAEConnectToDevice(deviceSerial.CString())
    }
    
    func activate(device deviceSerial: String) {
        DAESetDeviceActive(deviceSerial.CString())
    }
    
    func pause(device deviceSerial: String) {
        DAESetDeviceIdle(deviceSerial.CString())
    }
    
    func end() {
        _statusFetcherLoop?.removeAllObservers(thenStop: true)
        _statusFetcherLoop = nil
        
        DAEEndAcquisition()
    }
}
