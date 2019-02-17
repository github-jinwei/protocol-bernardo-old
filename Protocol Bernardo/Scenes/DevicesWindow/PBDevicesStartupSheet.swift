//
//  PBLiveViewStatus.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-16.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class PBDevicesStartupSheet: NSViewController {
    @IBOutlet weak var liveViewToggle: NSButton!
    @IBOutlet weak var startDriversButton: NSButton!

    override func viewDidAppear() {
        liveViewToggle.state = App.dae.isLiveViewEnabled ? .on : .off
    }

    @IBAction func toggleLiveView(_ sender: Any) {
        App.dae.toggleLiveView()
    }

    @IBAction func startDrivers(_ sender: Any) {
        startDriversButton.isEnabled = false
        App.dae.start()

        (presentingViewController as! DevicesWindow).updateLiveView()
        dismiss(nil)
    }
}
