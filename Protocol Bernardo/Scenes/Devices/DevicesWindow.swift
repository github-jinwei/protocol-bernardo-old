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

    @IBOutlet weak var liveViewLabel: NSTextField!
    @IBOutlet weak var liveViewIcon: NSImageView!

    var devicesRows: [PBDeviceRow] = []

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
            return
        }

        updateLiveView()
    }

    func updateLiveView() {
        let image: NSImage.Name

        if App.dae.isLiveViewEnabled {
            image = NSImage.statusAvailableName
            liveViewIcon.image = NSImage(named: image)
            return
        }

        liveViewLabel.isHidden = true
        liveViewIcon.isHidden = true
    }

    override func viewWillDisappear() {
        App.dae.removeObserver(self)
    }

    func quit() {
        self.view.window?.close()
    }
}

extension DevicesWindow: DataAcquisitionEngineObserver {

    func dae(_: DataAcquisitionEngine, devicesStatusUpdated devices: ConnectedDevices) {
        DispatchQueue.main.async {
            if devices.count != self.devicesRows.count {
                self.reloadDevicesList(withDevices: devices)
                return
            }

            for deviceView in self.devicesRows {
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
        for machineView in  devicesList.views {
            (machineView as! PBMachineDevicesList).devicesList.views.forEach {
                $0.removeFromSuperview()
            }
            machineView.removeFromSuperview()
            devicesRows.removeAll()
        }

        let sortedDevices = connectedDevices.devices.sorted {

            if $0.value.hostname == $1.value.hostname {
                // The two devices are on the same machine, order by serial
                return $0.key < $1.key
            }

            // The two devices are on different machines, order by hostname
            return $0.value.hostname < $1.value.hostname
        }

        var lastHostname = ""
        var currentBox: PBMachineDevicesList! = nil

        for (serial, device) in sortedDevices {
            // Are we on the same machine as the last device ?
            if device.hostname != lastHostname {
                lastHostname = device.hostname
                currentBox = NSNib.make(fromNib: "DevicesWindowViews", owner: nil)
                currentBox.box.title = device.hostname

                self.devicesList.addView(currentBox, in: .top)
            }

            let deviceView: PBDeviceRow = NSNib.make(fromNib: "DevicesWindowViews", owner: nil)

            // Values that will not change
            deviceView.topController = self
            deviceView.serial = serial
            deviceView.separatorLine.isHidden = currentBox.devicesList.views.count == 0

            // Fill in the values
            deviceView.update(deviceValues: device)

            // Insert the view in the stack
            currentBox.devicesList.addView(deviceView, in: .top)
            devicesRows.append(deviceView)
        }
    }
}
