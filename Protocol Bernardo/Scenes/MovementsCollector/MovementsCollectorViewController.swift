//
//  MovementsCollectorViewController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import AppKit

class MovementsCollectorViewController: NSViewController {
    
    weak var movementsCollector: MovementsCollector?
    @IBOutlet weak var kinectsList: NSStackView!
    
    var _isAcquiring = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    @IBAction func refreshKinectsList(_ sender: Any) {
        movementsCollector?.refreshKinectsList();
    }
    
    /// Called to pass a new status to the interface
    ///
    /// - Parameter status: The DAE status
    func statusUpdate(_ status: DAEStatus) {
        if(status.kinectCount != kinectsList.views.count) {
            reloadKinectsList(withStatus: status)
            return
        }
        
        kinectsList.views.forEach { view in
            let kinectView = view as! PBKinectRow
            let serial = kinectView.serial!
            let kinect = status.kinects[serial]!
            
            // Update in the values
            setViewValues(kinectView: kinectView, kinect: kinect)
        }
    }
    
    /// Regenerate all the kinect views
    ///
    /// - Parameter status: The new status to generate from
    func reloadKinectsList(withStatus status: DAEStatus) {
        // Remove previously added view
        kinectsList.views.forEach { $0.removeFromSuperview() }
        
        status.kinects.forEach { serial, kinect in
            let kinectView: PBKinectRow = NSView.make(fromNib: "PBKinectRow", owner: nil)
            
            // Values that will not change
            kinectView.serial = serial
            kinectView.outletBox.title = "Kinect #\(kinectsList.views.count + 1)"
            
            // Insert the view in the stack
            kinectsList.addView(kinectView, in: .top)
            
            // Fill in the values
            setViewValues(kinectView: kinectView, kinect: kinect)
        }
    }
    
    func setViewValues(kinectView: PBKinectRow, kinect: KinectStatus) {
        kinectView.serialField.stringValue = kinect.serial
        kinectView.statusField.stringValue = stateLabel(kinect.state)
        
        switch kinect.state.rawValue {
        case 1: // Connecting
            kinectView.actionButton.isEnabled = true;
            kinectView.actionButton.title = "Connect"
        case 2: // Connecting
            kinectView.actionButton.isEnabled = false;
        case 3: // Ready
            kinectView.actionButton.isEnabled = true;
            kinectView.actionButton.title = "Activate"
        case 4: // Active
            kinectView.actionButton.isEnabled = true;
            kinectView.actionButton.title = "Pause"
        case 5: // Closing
            kinectView.actionButton.isEnabled = false;
        default: // Errored
            kinectView.actionButton.isEnabled = false;
            kinectView.actionButton.title = "Errored"
        }
    }
    
    /// Gets the label for the kinect state
    ///
    /// - Parameter state: State of the kinect
    /// - Returns: Label for the state
    func stateLabel(_ state: KinectState) -> String {
        switch state.rawValue {
        case 1: return "Idle"
        case 2: return "Connecting"
        case 3: return "Ready"
        case 4: return "Active"
        case 5: return "Closing"
        default: return "Errored"
        }
    }
}
