//
//  LayoutSidebarCalibrationSetup.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-06.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class LayoutSidebarCalibration: NSViewController {
    // //////////////////
    // MARK: - References
    
    weak var document: LayoutDocument?
    
    /// Reference to the layout
    weak var layout: Layout!
    
    /// Reference to the calibration profile currently open, might be nil
    weak var profile: LayoutCalibration!
    
    /// Reference to the canvas
    weak var canvas: LayoutCanvas!
    
    // ///////////////
    // MARK: - Outlets
    
    /// The profile name
    @IBOutlet weak var profileNameField: NSTextField!
    
    /// List of devices in the layout
    @IBOutlet weak var devicesList: NSPopUpButton!
    
    /// List of connected and not paired physical devices
    @IBOutlet weak var physicalDevicesList: NSPopUpButton!
    
    /// Status of the selected physical device
    @IBOutlet weak var physicalDeviceStatus: NSTextField!
    
    /// Reference device checkbox
    @IBOutlet weak var referenceDeviceToggle: NSButton!
    
    /// List of available device (in the layout) to calibrate against
    @IBOutlet weak var referenceDevicesList: NSPopUpButton!
    
    /// Status of the selected reference device
    @IBOutlet weak var referenceDeviceStatus: NSTextField!
    
    /// Device postion delta X
    @IBOutlet weak var deltaXLabel: NSTextField!
    
    /// Device postion delta Y
    @IBOutlet weak var deltaYLabel: NSTextField!
    
    /// Device postion delta Height
    @IBOutlet weak var deltaHeightLabel: NSTextField!
    
    /// Device postion delta Orientation
    @IBOutlet weak var deltaOrientationLabel: NSTextField!
    
    /// Device calibration status
    @IBOutlet weak var calibrationStatus: NSTextField!
    
    override func viewDidLoad() {
        // Place ourselves as the dae observer and start it if needed
        App.dae.observer = self
        App.dae.start()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        clearAndDisableAll()
        
        if profile == nil {
            profileNameField.stringValue = "No Profile"
            return
        }
        
        // Set the profile calibration name
        profileNameField.stringValue = profile.name.capitalized

        // Fill the devices list
        devicesList.removeAllItems()
        devicesList.addItem(withTitle: "---")
        layout?.devices.forEach { device in
            devicesList.addItem(withTitle: device.name)
        }
        devicesList.isEnabled = true
    }
    
    @IBAction func openDevices(_ sender: Any) {
        App.core.makeScene(ofType: DevicesScene.self)
    }
}


// MARK: - IBActions
extension LayoutSidebarCalibration {
    /// User selected a device to calibrate, let's update the list of physical devices
    ///
    /// - Parameter sender: _
    @IBAction func setDeviceToCalibrate(_ sender: NSPopUpButton) {
        // Start by cleaning the panel
         clearAndDisableAll()
        
        guard devicesList.indexOfSelectedItem > 0 else { return }
        
        /// Get the device uuid
        let deviceUUID = layout.devices[devicesList.indexOfSelectedItem - 1].uuid!
        canvas.selectDevice(withName: devicesList.titleOfSelectedItem!)
        
        /// If this device isn't part of the calibration profile, add it
        if !profile.calibratedDevices.keys.contains(deviceUUID) {
            // Device is not in the calibration profile, insert it
            profile.calibratedDevices[deviceUUID] = CalibratedDevice()
            profile.calibratedDevices[deviceUUID]!.layoutDeviceUUID = deviceUUID
        }
        
        // Get the device calibration
        let calibratedDevice = profile.calibratedDevices[deviceUUID]!
        calibratedDevice.document = document
        
        // Reset the physical devices list
        physicalDevicesList.removeAllItems()
        physicalDevicesList.addItem(withTitle: "---")
        physicalDevicesList.selectItem(at: 0)
        
        // Fill it with available devices list
        App.dae.status.devices.forEach { serial, device in
            physicalDevicesList.addItem(withTitle: serial)
        }
        
        // And activate it
        physicalDevicesList.isEnabled = true
        
        // And select the physical device if one is already associated
        if calibratedDevice.physicalDeviceSerial != nil {
            physicalDevicesList.selectItem(withTitle: calibratedDevice.physicalDeviceSerial!)
            setPhysicalDevice(physicalDevicesList)
        }
    }
    
    @IBAction func setPhysicalDevice(_ sender: NSPopUpButton) {
        // Clean interface
        referenceDeviceToggle.isEnabled = false
        referenceDeviceToggle.state = .off
        clearAndDisableReferencePanel()
        clearAndDisableCalibrationPanel()
        
        // Make sure the placeholder isn't the one selected
        guard physicalDevicesList.indexOfSelectedItem > 0 else { return }
        
        // Get the device ant the calibrated device
        let device = layout.devices.filter({ $0.name == devicesList.titleOfSelectedItem! })[0]
        let calibratedDevice = profile.calibratedDevices[device.uuid]!
        
        calibratedDevice.physicalDeviceSerial = physicalDevicesList.titleOfSelectedItem!
        
        // Activate the isReference toggle and set its value
        referenceDeviceToggle.isEnabled = true
        referenceDeviceToggle.state = calibratedDevice.isReference! ? .on : .off
        
        // If this device is marked as reference, do nothing more
        guard referenceDeviceToggle.state == .off else { return }
        
        setReferenceState(referenceDeviceToggle)
    }
    
    @IBAction func setReferenceState(_ sender: NSButton) {
        clearAndDisableReferencePanel()
        clearAndDisableCalibrationPanel()
        
        // Get the device and the calibrated device
        let device = layout.devices.filter({ $0.name == devicesList.titleOfSelectedItem! })[0]
        let calibratedDevice = profile.calibratedDevices[device.uuid]!
        
        calibratedDevice.isReference = referenceDeviceToggle.state == .on
        
        // If this device is marked as reference, do nothing more
        guard referenceDeviceToggle.state == .off else { return }
        
        referenceDevicesList.removeAllItems()
        referenceDevicesList.addItem(withTitle: "---")
        
        referenceDevicesList.isEnabled = true
        
        // Fill the calibrate against list
        layout.devices.forEach { device in
            guard device.uuid != calibratedDevice.layoutDeviceUUID else { return }
            
            referenceDevicesList.addItem(withTitle: device.name)
            
            let cDevice = profile.calibratedDevices[device.uuid]
            
            if cDevice == nil || (!cDevice!.isReference && !cDevice!.isCalibrated) {
                referenceDevicesList.itemArray.last!.isEnabled = false
                referenceDevicesList.itemArray.last!.title += " (Not Calibrated)"
            }
        }
    }
}


// /////////////////////////////////////
// MARK: - DataAcquisitionEngineObserver
extension LayoutSidebarCalibration: DataAcquisitionEngineObserver {
    func dae(_ dae: DataAcquisitionEngine, statusUpdated status: DAEStatus) {
        DispatchQueue.main.async {
            guard self.physicalDevicesList.indexOfSelectedItem > 0 else { return }
            
            self.physicalDeviceStatus.stringValue =
                status.devices[self.physicalDevicesList.titleOfSelectedItem!]!.stateLabel
            
            guard self.referenceDevicesList.indexOfSelectedItem > 0 else { return }
            
            self.referenceDeviceStatus.stringValue = status.devices[self.referenceDevicesList.titleOfSelectedItem!]!.stateLabel
        }
    }
}


extension LayoutSidebarCalibration: LayoutSidebar {
    func setSelectedElement(_ element: LayoutCanvasElement?) {
        guard let device = element as? LayoutCanvasDevice else { return }
        
        guard device.name! != devicesList.titleOfSelectedItem! else { return }
        
        devicesList.selectItem(withTitle: device.name!)
        setDeviceToCalibrate(devicesList)
    }
}


// /////////////////
// MARK: - Clearing
extension LayoutSidebarCalibration {
    func clearAndDisableAll() {
        clearAndDisablePhysicalPanel()
        clearAndDisableReferencePanel()
        clearAndDisableCalibrationPanel()
    }
    
    func clearAndDisablePhysicalPanel() {
        physicalDevicesList.removeAllItems()
        physicalDevicesList.isEnabled = false
        
        physicalDeviceStatus.stringValue = "-"
        
        referenceDeviceToggle.state = .off
        referenceDeviceToggle.isEnabled = false
    }
    
    func clearAndDisableReferencePanel() {
        referenceDevicesList.removeAllItems()
        referenceDevicesList.isEnabled = false
        
        referenceDeviceStatus.stringValue = "-"
    }
    
    func clearAndDisableCalibrationPanel() {
        deltaXLabel.stringValue = "-"
        deltaYLabel.stringValue = "-"
        deltaHeightLabel.stringValue = "-"
        deltaOrientationLabel.stringValue = "-"
        
        calibrationStatus.stringValue = "-"
    }
}
