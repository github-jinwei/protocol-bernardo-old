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
    
    /// Reference to the layout document
    weak var document: LayoutDocument?
    
    /// Reference to the layout
    weak var layout: Layout!
    
    /// Reference to the calibration profile currently open, might be nil
    weak var profile: LayoutCalibrationProfile!
    
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
    
    /// Device postion delta Orientation
    @IBOutlet weak var deltaOrientationLabel: NSTextField!
    
    /// Device postion delta X
    @IBOutlet weak var deltaXLabel: NSTextField!
    
    /// Device postion delta Y
    @IBOutlet weak var deltaYLabel: NSTextField!
    
    /// Device postion delta Height
    @IBOutlet weak var deltaHeightLabel: NSTextField!
    
    /// Button used to store a calibration profile deltas
    @IBOutlet weak var storeDeltasButton: NSButton!
    
    /// Currently stored orientation delta in the profile
    @IBOutlet weak var storedOrientationDelta: NSTextField!
    
    /// Currently stored X delta in the profile
    @IBOutlet weak var storedXDelta: NSTextField!
    
    /// Currently stored Y delta in the profile
    @IBOutlet weak var storedYDelta: NSTextField!
    
    /// Currently stored height delta in the profile
    @IBOutlet weak var storedHeightDelta: NSTextField!
    
    // //////////////////////
    // MARK: - Properties
    
    /// User position registered on the previous frame on the device being calibrated
    internal var _deltasCalculator = CalibrationDeltasCalculator()
    
    /// The device to calibrate profile
    internal var _deviceCalibrationProfile: DeviceCalibrationProfile!
    
    /// The reference device profile
    internal var _referenceCalibrationProfile: DeviceCalibrationProfile?
    

    
    // Deinit
    deinit {
        App.dae.removeObserver(self)
    }
}


// //////////////////////
// MARK: - View Lifecycle
extension LayoutSidebarCalibration {
    override func viewDidLoad() {
        // Place ourselves as the dae observer and start it if needed
        App.dae.addObsever(self)
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
        fillLayoutDevicesList()
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
        
        // If the user selected the first item (---) deselect the selected device
        guard devicesList.indexOfSelectedItem > 0 else {
            canvas.selectedNode = nil
            return;
        }
        
        /// Get the device uuid
        let deviceUUID = layout.devices[devicesList.indexOfSelectedItem - 1].uuid!
        canvas.selectDevice(withName: devicesList.titleOfSelectedItem!)
        
        // Get the device profile or create a new one if needed
        _deviceCalibrationProfile = profile.device(forUUID: deviceUUID) ??
                               profile.addDevice(withUUID: deviceUUID)
        
        // Display the device profile stored deltas
        displayDeltas(forProfile: _deviceCalibrationProfile)
        
        // Update the list of physical devices
        fillPhysicalDevicesList()
        
        // Go further
        setPhysicalDevice(physicalDevicesList)
    }
    
    /// User selected a physical device for the device to calibrate, update the lists
    /// and interface accordingly
    ///
    /// - Parameter sender: _
    @IBAction func setPhysicalDevice(_ sender: NSPopUpButton) {
        // Clean interface
        referenceDeviceToggle.isEnabled = false
        referenceDeviceToggle.state = .off
        clearAndDisableReferencePanel()
        clearAndDisableCalibrationPanel()
        
        // Make sure the placeholder isn't the one selected
        guard physicalDevicesList.indexOfSelectedItem > 0 &&
              physicalDevicesList.selectedItem!.isEnabled else { return }
        
        // Set the physical device for the profile
        _deviceCalibrationProfile.physicalDeviceSerial = physicalDevicesList.titleOfSelectedItem!
        
        // Activate the isReference toggle and set its value
        referenceDeviceToggle.isEnabled = true
        referenceDeviceToggle.state = _deviceCalibrationProfile.isReference! ? .on : .off
        
        // If this device is marked as reference, do nothing more
        guard referenceDeviceToggle.state == .off else { return }
        
        setReferenceState(referenceDeviceToggle)
    }
    
    /// User changed the reference state for the selected device to calibrate
    ///
    /// - Parameter sender: _
    @IBAction func setReferenceState(_ sender: NSButton) {
        clearAndDisableReferencePanel()
        clearAndDisableCalibrationPanel()
        
        // Set the device reference state based on the toggle
        _deviceCalibrationProfile.isReference = referenceDeviceToggle.state == .on
        
        // If this device is marked as reference, do nothing more
        guard referenceDeviceToggle.state == .off else { return }
        
        // Update the reference device list
        fillReferenceDevicesList()
        
        // Select the reference device if there is one
        guard let referenceDeviceUUID = _deviceCalibrationProfile.referenceDeviceUUID else { return }
        let referenceDevice: Device = layout.devices.first(where: { $0.uuid == referenceDeviceUUID })!
        
        referenceDevicesList.selectItem(withTitle: referenceDevice.name)
        
        setReferenceDevice(referenceDevicesList)
    }
    
    @IBAction func setReferenceDevice(_ sender: NSPopUpButton) {
        clearAndDisableCalibrationPanel()
        
        // Make sure the item selected isn't the placeholder one
        guard referenceDevicesList.indexOfSelectedItem > 0 else { return }
        
        storeDeltasButton.isEnabled = true
        
        // Get the reference device
        let referenceDevice = layout.devices.filter({ $0.name == referenceDevicesList.titleOfSelectedItem! })[0]
        
        _deviceCalibrationProfile.referenceDeviceUUID = referenceDevice.uuid
        _referenceCalibrationProfile = profile.device(forUUID: referenceDevice.uuid)
    }
    
    @IBAction func storeDeltas(_ sender: NSButton) {
        // Get the device and the calibrated device
        let device = layout.devices.filter({ $0.name == devicesList.titleOfSelectedItem! })[0]
        let calibratedDevice = profile.device(forUUID: device.uuid)!
        
        // Store the shown deltas in the calibration profile
        calibratedDevice.orientationDelta = deltaOrientationLabel.doubleValue.rounded(FloatingPointRoundingRule.toNearestOrAwayFromZero)
        calibratedDevice.positionDelta.x = deltaXLabel.doubleValue
        calibratedDevice.positionDelta.y = deltaYLabel.doubleValue
        calibratedDevice.heightDelta = deltaHeightLabel.doubleValue
        
        // And mark the profile as calibrated
        calibratedDevice.isCalibrated = true
        
        displayDeltas(forProfile: calibratedDevice)
    }
}



extension LayoutSidebarCalibration {
    /// Fill the 'Devices' list
    func fillLayoutDevicesList() {
        // Reset the list
        devicesList.removeAllItems()
        devicesList.addItem(withTitle: "---")
        
        // Do we have a layout
        guard let layout = layout else { return }
        
        // Fill the list with every device in the layout
        for device in layout.devices {
            devicesList.addItem(withTitle: device.name)
        }
        
        // Activate the list
        devicesList.isEnabled = true
    }
    
    /// Fill the 'Physical devices" list
    func fillPhysicalDevicesList() {
        // Reset the physical devices list
        physicalDevicesList.removeAllItems()
        physicalDevicesList.addItem(withTitle: "---")
        physicalDevicesList.selectItem(at: 0)
        
        // Fill it with available devices list
        for (serial, _) in App.dae.connectedDevices.devices {
            physicalDevicesList.addItem(withTitle: serial)
        }
        
        // If the physical device for the currently selected device is missing,
        // add it at the end of the list
        guard let physicalDeviceSerial = _deviceCalibrationProfile.physicalDeviceSerial else { return }
        
        if physicalDevicesList.item(withTitle: physicalDeviceSerial) == nil {
            let deviceLine = "\(physicalDeviceSerial) (Not Connected)"
            physicalDevicesList.addItem(withTitle: deviceLine)
            physicalDevicesList.selectItem(withTitle: deviceLine)
            physicalDevicesList.itemArray.last!.isEnabled = false
        } else {
            physicalDevicesList.selectItem(withTitle: physicalDeviceSerial)
        }
        
        // Activate it
        physicalDevicesList.isEnabled = true
    }
    
    /// Reset and fill the 'Calibrate against list'
    func fillReferenceDevicesList() {
        // Reset the list
        referenceDevicesList.removeAllItems()
        referenceDevicesList.addItem(withTitle: "---")
        
        referenceDevicesList.isEnabled = true
        
        // For each device in the layout
        for device in layout.devices {
            // Prevent displaying the same device in the list
            guard device.uuid != _deviceCalibrationProfile.layoutDeviceUUID else { return }
            
            // Add an item with the name
            referenceDevicesList.addItem(withTitle: device.name)
            
            let referenceDeviceProfile = profile.device(forUUID: device.uuid)
            
            // If the device is not calibrated, disable it from the list, and update its label
            if referenceDeviceProfile == nil || (!referenceDeviceProfile!.isReference && !referenceDeviceProfile!.isCalibrated) {
                referenceDevicesList.itemArray.last!.isEnabled = false
                referenceDevicesList.itemArray.last!.title += " (Not Calibrated)"
                return
            }
        }
    }
}



// /////////////////////////////////////
// MARK: - DataAcquisitionEngineObserver
extension LayoutSidebarCalibration: DataAcquisitionEngineObserver {
    func dae(_ dae: DataAcquisitionEngine, devicesStatusUpdated devices: ConnectedDevices) {
        // Start by checking if we have a device profile selected
        guard _deviceCalibrationProfile != nil else { return }
        
        // Is there a selected physical device ?
        guard let serial = self._deviceCalibrationProfile?.physicalDeviceSerial else { return }
        
        // Make sure this device is connected
        guard let physicalDevice = devices.with(serial: serial) else { return }
        
        // Display the state of the device
        DispatchQueue.main.async {
            self.physicalDeviceStatus.stringValue = physicalDevice.stateLabel
        }
        
        // Do nothing more if the current device is a reference one
        if _deviceCalibrationProfile.isReference { return }
        
        // Is there a selected reference device ?
        guard _referenceCalibrationProfile != nil else { return }
        
        // Make sure this reference device has an associated, connected physical device
        guard let referencePhysicalDevice = devices.with(serial: _referenceCalibrationProfile?.physicalDeviceSerial) else {
            return
        }
        
        // Display the state of the reference device
        DispatchQueue.main.async {
            self.referenceDeviceStatus.stringValue = referencePhysicalDevice.stateLabel
        }
        
        // If there is at least one user tracked by each device
        guard physicalDevice.users.count > 0 &&
              referencePhysicalDevice.users.count > 0 else { return }
        
        // Make sure their first users are both being tracked
        guard physicalDevice.users[0].state == USER_TRACKED && referencePhysicalDevice.users[0].state == USER_TRACKED else {
            
                DispatchQueue.main.async {
                    self.clearDeltas()
                }
                return
        }
        
        // Get the users CoM on the global coordinates system
        let globalDevicePos = _deviceCalibrationProfile.globalCoordinates(forPosition: physicalDevice.users[0].centerOfMass)
        let globalReferencePos = _referenceCalibrationProfile!.globalCoordinates(forPosition: referencePhysicalDevice.users[0].centerOfMass)
        
        // Add them to the deltas calculator
        self._deltasCalculator.insert(calibrationPosition: globalDevicePos,
                                referencePosition: globalReferencePos)
        
        // Get the deltas
        let deltas = self._deltasCalculator.getDeltas()
        
        DispatchQueue.main.async {
            // Display the orientation delta
            self.deltaOrientationLabel.floatValue = rad2deg(deltas?.orientation.rounded() ?? 0.0)
//
//            // If the orientation delta is low enough, display the other deltas
//            guard self.deltaOrientationLabel.floatValue < 3.0 else {
//                self.deltaXLabel.stringValue = "-"
//                self.deltaYLabel.stringValue = "-"
//                self.deltaHeightLabel.stringValue = "-"
//                return
//            }
            
            self.deltaXLabel.intValue = Int32(Int((deltas?.xPosition.rounded() ?? 0.0) / 10.0))
            self.deltaYLabel.intValue = Int32(Int((deltas?.yPosition.rounded() ?? 0.0) / 10.0))
            self.deltaHeightLabel.intValue = Int32(Int((deltas?.height.rounded() ?? 0.0) / 10.0))
        }
    }
}


extension LayoutSidebarCalibration: LayoutSidebar {
    func setSelectedElement(_ element: LayoutCanvasElement?) {
        guard let device = element as? LayoutCanvasDevice else {
            devicesList.selectItem(at: 0)
            setDeviceToCalibrate(devicesList)
            return
        }
        
        guard device.name! != devicesList.titleOfSelectedItem else { return }
        
        devicesList.selectItem(withTitle: device.name!)
        setDeviceToCalibrate(devicesList)
    }
}


// /////////////////
// MARK: - Clearing
extension LayoutSidebarCalibration {
    func displayDeltas(forProfile profile: DeviceCalibrationProfile) {
        guard profile.isCalibrated else {
            storedOrientationDelta.stringValue = "-"
            storedXDelta.stringValue = "-"
            storedYDelta.stringValue = "-"
            storedHeightDelta.stringValue = "-"
            return
        }
        
        storedOrientationDelta.doubleValue = profile.calibratedOrientation
        storedXDelta.doubleValue = profile.calibratedPosition.x
        storedYDelta.doubleValue = profile.calibratedPosition.y
        storedHeightDelta.doubleValue = profile.calibratedHeight
    }
    
    
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
        storeDeltasButton.isEnabled = false
        
        clearDeltas()
        
        _deltasCalculator.reset()
    }
    
    func clearDeltas() {
        deltaXLabel.stringValue = "-"
        deltaYLabel.stringValue = "-"
        deltaHeightLabel.stringValue = "-"
        deltaOrientationLabel.stringValue = "-"
    }
}
