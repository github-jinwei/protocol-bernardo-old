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

    @IBOutlet weak var liveViewIcon: NSImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        App.core.registerDevicesWindow(self)
        App.dae.addObsever(self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        
        view.window!.title = "Devices"

        if !App.dae.isRunning {
            performSegue(withIdentifier: "showStartOptionsSegue", sender: nil)
        }
    }

    func updateLiveView() {
        let image: NSImage.Name

        if App.dae.isLiveViewEnabled {
            image = NSImage.statusAvailableName
        } else {
            image = NSImage.statusUnavailableName
        }

        liveViewIcon.image = NSImage(named: image)
    }


    deinit {
        App.dae.removeObserver(self)
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
            let deviceView: PBDeviceRow = NSNib.make(fromNib: "DevicesWindowViews", owner: nil)

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
