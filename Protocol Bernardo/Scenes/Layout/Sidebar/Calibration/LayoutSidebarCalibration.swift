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
    var layout: Layout! {
        return document!.layout
    }
    
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
    
    /// View encapsulating the live deltas part of the sidebar
    @IBOutlet weak var liveDeltasView: PBCalibrationLiveDeltas!

    /// Button used to store a calibration profile deltas
    @IBOutlet weak var updateProfileButton: NSButton!

    /// Currently stored orientation delta in the profile
    @IBOutlet weak var storedOrientationDelta: NSTextField!
    
    /// Currently stored X delta in the profile
    @IBOutlet weak var storedXDelta: NSTextField!
    
    /// Currently stored Y delta in the profile
    @IBOutlet weak var storedYDelta: NSTextField!
    
    /// Currently stored height delta in the profile
    @IBOutlet weak var storedHeightDelta: NSTextField!
    
    /// Button used to reset the profile deltas to zero
    @IBOutlet weak var clearDeltasButton: NSButton!

    // //////////////////////
    // MARK: - Properties
    
    /// User position registered on the previous frame on the device being calibrated
    var calibrationController = CalibrationController()
}


// //////////////////////
// MARK: - View Lifecycle
extension LayoutSidebarCalibration {
    override func viewDidLoad() {
        calibrationController.delegate = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        calibrationController.layout = layout

        if profile == nil {
            profileNameField.stringValue = "No Profile"
            calibrationController.set(calibrationProfile: nil)
            clearAndDisableAll()
            return
        }

        // Set the profile calibration name
        profileNameField.stringValue = profile.name.capitalized
        calibrationController.set(calibrationProfile: profile)

        // Fill the devices list
        fillLayoutDevicesList()

        setSelectedElement(canvas.selectedNode)
    }
}


// /////////////////////
// MARK: - LayoutSidebar
extension LayoutSidebarCalibration: LayoutSidebar {
    func setSelectedElement(_ element: LayoutCanvasElement?) {
        // Make sure the selected element is a device
        guard let device = element as? LayoutCanvasDevice else {
            devicesList.selectItem(at: 0)
            calibrationController.deviceUUID = nil
            return
        }

        // Select the corresponding item in our list
        devicesList.selectItem(withTitle: device.name!)

        // Get and set the device UUID
        let deviceUUID = device.device!.uuid
        calibrationController.deviceUUID = deviceUUID

        // Update the physical devices list
        fillPhysicalDevicesList()
    }

    func setCalibrationProfile(_ profile: LayoutCalibrationProfile?) {
        calibrationController.set(calibrationProfile: profile)

        guard let profile = profile else {
            profileNameField.stringValue = "No Profile"
            clearAndDisableAll()
            return
        }

        // Set the profile calibration name
        profileNameField.stringValue = profile.name.capitalized

        // And fill the devices list
        fillLayoutDevicesList()
    }
}


// MARK: - IBActions
extension LayoutSidebarCalibration {
    /// User selected a device to calibrate, let's update the list of physical devices
    ///
    /// - Parameter sender: _
    @IBAction func setDeviceToCalibrate(_: NSPopUpButton) {
        // Start by cleaning the panel
         clearAndDisableAll()
        
        // If the user selected the first item (---) deselect the selected device
        guard devicesList.indexOfSelectedItem > 0 else {
            devicesList.removeAllItems()
            devicesList.isEnabled = false

            canvas.selectedNode = nil
            calibrationController.deviceUUID = nil
            return
        }
        
        // Select the selected device on the canvas
        canvas.selectDevice(withName: devicesList.titleOfSelectedItem!)
    }
    
    /// User selected a physical device for the device to calibrate, update the lists
    /// and interface accordingly
    ///
    /// - Parameter sender: _
    @IBAction func setPhysicalDevice(_: NSPopUpButton) {
        // Clean interface
        referenceDeviceToggle.isEnabled = false
        referenceDeviceToggle.state = .off
        clearAndDisableReferencePanel()
        clearAndDisableCalibrationPanel()
        
        // Make sure the placeholder isn't the one selected
        guard physicalDevicesList.indexOfSelectedItem > 0 &&
              physicalDevicesList.selectedItem!.isEnabled else { return }
        
        // Set the physical device for the profile
        calibrationController.deviceSerial = physicalDevicesList.titleOfSelectedItem!
        
        // Activate the isReference toggle and set its value
        referenceDeviceToggle.isEnabled = true
        referenceDeviceToggle.state = (calibrationController.isReference ?? false) ? .on : .off
        
        setReferenceState(referenceDeviceToggle)
    }
    
    /// User changed the reference state for the selected device to calibrate
    ///
    /// - Parameter sender: _
    @IBAction func setReferenceState(_: NSButton) {
        clearAndDisableReferencePanel()
        clearAndDisableCalibrationPanel()
        
        // Set the device reference state based on the toggle
        calibrationController.isReference = referenceDeviceToggle.state == .on
        
        // If this device is marked as reference, do nothing more
        guard referenceDeviceToggle.state == .off else { return }
        
        // Update the reference device list
        fillReferenceDevicesList()
    }
    
    @IBAction func setReferenceDevice(_: NSPopUpButton) {
        clearAndDisableCalibrationPanel()
        
        // Make sure the item selected isn't the placeholder one
        guard referenceDevicesList.indexOfSelectedItem > 0 &&
              referenceDevicesList.selectedItem!.isEnabled else { return }
        
        // Get and set the reference device
        let referenceDevice = layout.devices.filter { $0.name == referenceDevicesList.titleOfSelectedItem! }[0]
        calibrationController.referenceUUID = referenceDevice.uuid
    }
    
    @IBAction func storeDeltas(_: NSButton) {
        calibrationController.storeDeltas()
    }

    @IBAction func clearDeltas(_: NSButton) {
        calibrationController.clearDeltas()
    }
}



extension LayoutSidebarCalibration {
    /// Fill the 'Devices' list
    func fillLayoutDevicesList() {
        // Reset the list
        devicesList.removeAllItems()
        devicesList.addItem(withTitle: "---")
        devicesList.isEnabled = true
        
        let layoutDevicesList = calibrationController.layoutDevicesList

        for (name, isEnabled) in layoutDevicesList.sorted(by: { $0.key < $1.key }) {
            devicesList.addItem(withTitle: name)
            devicesList.itemArray.last!.isEnabled = isEnabled
        }
    }
    
    /// Fill the 'Physical devices" list
    func fillPhysicalDevicesList() {
        // Reset the physical devices list
        physicalDevicesList.removeAllItems()
        physicalDevicesList.addItem(withTitle: "---")
        physicalDevicesList.selectItem(at: 0)

        // Activate the list
        physicalDevicesList.isEnabled = true

        let physicalDevices = calibrationController.physicalDevicesList
        
        // Fill it with available devices list
        for (serial, isEnabled) in physicalDevices.sorted(by: { $0.key < $1.key }) {
            physicalDevicesList.addItem(withTitle: serial)
            physicalDevicesList.itemArray.last!.isEnabled = isEnabled
        }
        
        // If a physical device is present in the profile, select it
        if let deviceSerial = calibrationController.deviceSerial {
            physicalDevicesList.selectItem(withTitle: deviceSerial)
            setPhysicalDevice(physicalDevicesList)
        }
    }
    
    /// Reset and fill the 'Calibrate against list'
    func fillReferenceDevicesList() {
        // Reset the list
        referenceDevicesList.removeAllItems()
        referenceDevicesList.addItem(withTitle: "---")
        referenceDevicesList.selectItem(at: 0)
        
        referenceDevicesList.isEnabled = true
        
        let referenceDevices = calibrationController.referenceDevicesList

        for (name, isEnabled) in referenceDevices.sorted(by: { $0.key < $1.key }) {
            referenceDevicesList.addItem(withTitle: name)
            referenceDevicesList.itemArray.last!.isEnabled = isEnabled
        }

        // If a reference device is present in the profile, select it
        if let referenceUUID = calibrationController.referenceUUID {
            if let deviceName = layout.device(withUUID: referenceUUID)?.name {
                referenceDevicesList.selectItem(withTitle: deviceName)
                setReferenceDevice(referenceDevicesList)
            }
        }
    }
}



// /////////////////////////////////////
// MARK: - CalibrationControllerDelegate
extension LayoutSidebarCalibration: CalibrationControllerDelegate {
    func calibration(_: CalibrationController, physicalDeviceStateChanged state: DeviceState) {
        DispatchQueue.main.async {
            self.physicalDeviceStatus.stringValue = state.label
        }
    }

    func calibration(_: CalibrationController, referenceDeviceStateChanged state: DeviceState) {
        DispatchQueue.main.async {
            self.referenceDeviceStatus.stringValue = state.label
        }
    }

    func calibration(_: CalibrationController, liveDeltasUpdated deltas: CalibrationDeltas?) {
        // Update deltas values on the interface
        DispatchQueue.main.async {
            self.liveDeltasView.show(deltas: deltas)

            // Activate the update device profile button if there is deltas
            self.updateProfileButton.isEnabled = deltas != nil
        }
    }

    func calibration(_: CalibrationController, storedDeltasChanged deltas: CalibrationDeltas) {
        storedOrientationDelta.floatValue = deltas.orientation ?? 0.0
        storedXDelta.floatValue = deltas.xPosition / 10.0
        storedYDelta.floatValue = deltas.yPosition / 10.0
        storedHeightDelta.floatValue = deltas.height / 10.0
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
        updateProfileButton.isEnabled = false
    }
}
