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

    @IBAction func toggleLiveView(_: Any) {
        App.dae.toggleLiveView()
    }

    @IBAction func startDrivers(_: Any) {
        startDriversButton.isEnabled = false
        App.dae.start()

        (presentingViewController as! DevicesWindow).updateLiveView()
        dismiss(nil)
    }

    @IBAction func cancelOpening(_: Any) {
        (presentingViewController as! DevicesWindow).quit()
        dismiss(nil)
    }
}
