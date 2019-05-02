//
//  PositionAcquisitionEngine.swift
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
/// The data acquisition engine uses the PositionAcquisitionEngine static library to communicate
/// with the devives. Itself runs using OpenNI and the provided driver by the devices
/// constructors.
///
/// The Data Acquisition Engine receive the tracking informations from the devices,
/// and gives it to its observers using the `PositionAcquisitionEngineObserver.pae(_:, devicesStatusUpdated:)` method
///
/// The current support of the kinect on Mac, as well as NiTE2 for skeleton tracking,
/// is quite instable. Some actions like connecting to a device needs to be done on the main thread
/// to prevent crashes, and closing algorithm seems to crashes for unknown reasons.
///
/// The Data Acquisition Engine support live view for the connected devices,
/// albeit in a limited form. Live view can only be toggled when the engine isn't running, and
/// requires status updates to be made from the main thread. This has negative impact
/// on the application preformance but not on the underlying DAE process.
/// Live view should only be used during calibration process or while constructing an installation.
class PositionAcquisitionEngine {

    // //////////////////
    // MARK: - Properties

    /// Refresh rate of the pae
    private(set) var refreshRate: UInt = 60

    /// Holds the loop for the status fetcher
    private var statusFetcherLoop: Repeater?

    /// The devices handled by the engine
	private var machines = [AcquisitionMachine]()

    /// Wrapper with all the connected machines
    var connectedMachines: [AcquisitionMachine] {
        return machines
    }

	/// Wrapper with all the connected devices
	var devices: [Serial: AcquisitionDevice] {
		var devices = [Serial: AcquisitionDevice]()

		for machine in machines {
			machine.devices.forEach {
				devices[$0.key] = $0.value
			}
		}

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

	/// Closes the PAE drivers on closing if needed
	deinit {
		end()
	}


	// ///////////////
	// MARK: Observers

	/// List of all the observers
	private var observers = [PositionAcquisitionEngineObserver]()

	/// Add the given observer to the list of observers
	///
	/// - Parameter obs: The observer to add
	func addObserver(_ obs: PositionAcquisitionEngineObserver) {
		observers.append(obs)
	}

	/// Remove the given observer from the list of observers
	///
	/// - Parameter obs: The observer to remove
	func removeObserver(_ obs: PositionAcquisitionEngineObserver) {
		observers.removeAll { $0 === obs }
	}
}


// //////////////////////
// MARK: - Engine Lifecycle
extension PositionAcquisitionEngine {
    /// Start the engine, parse for available devices and start the status fetcher loop. Starting from here, all observers will continuously receive the current state of the connected devices
    func start() {
        guard !isRunning else { return }

        // Init the DAE on the CPP side on another thread
        DispatchQueue.global(qos: .userInitiated).async {
            PAEPrepare()
        }

        PAEShouldReceive(1)
        PAEConnectTo("localhost".CString(), "3000".CString(), 0)

        // Start a loop to query the CPP DAE status regularly
        statusFetcherLoop = Repeater(interval: .milliseconds(Int(10000 / refreshRate)),
                                     mode: .infinite,
                                     tolerance: .milliseconds(Int(1000 / refreshRate)),
                                     queue: DispatchQueue.global(qos: .utility),
                                     observer: self.fetchStatus)
        statusFetcherLoop?.start()

		App.logs?.insert(message: "Engine started", prefix: "PAE")
    }

	/// End any tracking task and disconnect properly from every device
	func end() {
		guard isRunning else { return }

		statusFetcherLoop?.removeAllObservers(thenStop: true)
		statusFetcherLoop = nil

		PAEEndAcquisition()
	}
}


// //////////////////
// MARK: - Live View
extension PositionAcquisitionEngine {
	/// Enable or disable live view for the devices connected to this machine.
	///
	/// Live view requires fetch calls to be made from the main thread. This has
	/// an impact on the application performance and responsiveness as status
	/// updates are not made in the background anymore.
	func toggleLiveView() {
		if isLiveViewEnabled {
			PAEDisableLiveView()
			isLiveViewEnabled = false
			return
		}

		PAEEnableLiveView()
		isLiveViewEnabled = true
	}
}


// //////////////////////
// MARK: - Status getters
extension PositionAcquisitionEngine {
    /// Select the appropriate queue then calls the CPP DAE to get
    /// its current status
    ///
    /// - Parameter repeater: The wrepeater
    private func fetchStatus(_: Repeater) {
        if isLiveViewEnabled {
            // Live view requires fetches to be executed from the main queue
            DispatchQueue.main.async {
                self.doFetchStatus()
            }
            return
        }

        self.doFetchStatus()
    }

    /// Actually calls the pae to get and store its status
    private func doFetchStatus() {
        // Get the engine status
        let statusPointer = PAEGetStatus()

		App.logs?.insert(message: "Status updated. Dispatching...", prefix: "PAE")

        // Copy informations from the status pointer to our own struct
        machines = statusPointer!.pointee.copyForSwift()

		// Free the memory
		PAEFreeCollection(statusPointer!)

        // Tell all the observes
		observers.forEach { $0.pae(self, statusUpdated: machines) }
    }
}


// //////////////////////////
// MARK: - Actions on devices
extension PositionAcquisitionEngine {
    /// Changes the device status to its next possible state
    ///
    /// - Parameter serial: The serial of the device
    func toggleDeviceStatus(withSerial serial: Serial) {
        // Make sure the serial is a valid one
        guard let device = devices[serial] else {
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
        PAEConnectToDevice(deviceSerial.CString())

		App.logs?.insert(message: "Device `\(deviceSerial)` connected", prefix: "PAE")
    }

    /// Tries to activate the device and starte collecting data
    ///
    /// - Parameter deviceSerial: The serial of the device
    func activate(device deviceSerial: Serial) {
        PAESetDeviceActive(deviceSerial.CString())

		App.logs?.insert(message: "Device `\(deviceSerial)` activated", prefix: "PAE")
    }

    /// Pause data acquisition from the device. It still possible to resume it
    /// by calling `activate`
    ///
    /// - Parameter deviceSerial: The device's serial
    func pause(device deviceSerial: Serial) {
        PAESetDeviceIdle(deviceSerial.CString())

		App.logs?.insert(message: "Device `\(deviceSerial)` paused", prefix: "PAE")
    }
}
