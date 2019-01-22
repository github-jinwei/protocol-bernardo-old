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
        _engineStatus = DAEGetStatus()!.pointee
        delegate?.dae(self, statusUpdated: _engineStatus!)
    }
    
    func toggleKinectStatus(withSerial serial: String) {
        guard let kinect = _engineStatus.kinects[serial] else {
            return
        }
        
        switch kinect.state.rawValue {
        case 1: connect(toKinect: serial)
        case 3: activate(kinect: serial)
        case 4: pause(kinect: serial)
        default: return
        }
    }
    
    func refreshKinectsList() {
        DAEParseForKinects()
    }
    
    func connect(toKinect kinectSerial: String) {
        DAEConnectToKinect(kinectSerial.CString())
    }
    
    func activate(kinect kinectSerial: String) {
        DAESetKinectActive(kinectSerial.CString())
    }
    
    func pause(kinect kinectSerial: String) {
        DAESetKinectIdle(kinectSerial.CString())
    }
    
    func end() {
        _statusFetcherLoop?.removeAllObservers(thenStop: true)
        _statusFetcherLoop = nil
        
        DAEEndAcquisition()
    }
}
