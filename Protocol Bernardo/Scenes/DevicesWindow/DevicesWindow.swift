//
//  DevicesWindow.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class DevicesWindow: NSViewController {
    /// The devices list
    @IBOutlet weak var devicesList: NSStackView!

    /// The live view toggle
    @IBOutlet weak var liveViewToggle: NSButton!

    /// The DAE start/stop button
    @IBOutlet weak var startStopDAEButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        App.core.registerDevicesWindow(self)

        App.dae.addObsever(self)

        if App.dae.isLiveViewEnabled {
            liveViewToggle.state = .on
        } else {
            liveViewToggle.state = .off
        }

        if App.dae.isRunning {
            startStopDAEButton.title = "Stop Drivers"
            liveViewToggle.isEnabled = false
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        
        view.window!.title = "Devices"
    }


    deinit {
        App.dae.removeObserver(self)
    }

    @IBAction func toggleLiveView(_ sender: Any) {
        // Do nothing if the dae is already running
        if App.dae.isRunning {
            return
        }

        App.dae.toggleLiveView()
    }

    @IBAction func toggleDataAcquistionEngine(_ sender: Any) {
        if App.dae.isRunning {
            App.dae.end()

            startStopDAEButton.title = "Start Drivers"
            liveViewToggle.isEnabled = true
            return
        }

        App.dae.start()
        startStopDAEButton.title = "Stop Drivers"
        liveViewToggle.isEnabled = false
    }
}

extension DevicesWindow: DataAcquisitionEngineObserver {

    func dae(_ dae: DataAcquisitionEngine, devicesStatusUpdated devices: ConnectedDevices) {
        DispatchQueue.main.async {
            if devices.count != self.devicesList.views.count {
                self.reloadDevicesList(withDevices: devices)
                return
            }

            for view in self.devicesList.views {
                let deviceView = view as! PBDeviceRow
                let serial = deviceView.serial!
                let device = devices.with(serial: serial)!

                // Update in the values
                deviceView.update(deviceValues: device)
            }
        }
    }

}

extension DevicesWindow {

    /// Regenerate all the device views
    ///
    /// - Parameter status: The new status to generate from
    func reloadDevicesList(withDevices connectedDevices: ConnectedDevices) {
        // Remove previously added view
        devicesList.views.forEach { $0.removeFromSuperview() }

        for (serial, device) in connectedDevices.devices {
            let deviceView: PBDeviceRow = NSNib.make(fromNib: "PBDeviceRow", owner: nil)

            // Values that will not change
            deviceView.topController = self
            deviceView.serial = serial
            deviceView.outletBox.title = "Device #\(devicesList.views.count + 1)"

            // Fill in the values
            deviceView.update(deviceValues: device)

            // Insert the view in the stack
            devicesList.addView(deviceView, in: .top)
        }
    }

}
