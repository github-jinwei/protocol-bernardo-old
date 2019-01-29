//
//  WelcomeViewController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class WelcomeViewController: NSViewController {
    
    var editor: LayoutEditor!
    
    /// Called when clicked on the `Close` button. Tell the editor to close istelf
    ///
    /// - Parameter sender: The button
    @IBAction func closeAction(_ sender: Any) {
        editor.close()
        dismiss(nil)
    }
    
    /// Called when clicked on the `New` button. Closes the view to access an empty editor
    ///
    /// - Parameter sender: The button
    @IBAction func newLayoutAction(_ sender: Any) {
        dismiss(nil)
    }
    
    /// Called when clicked on the `Open` button. Asks the user to choose an existing layout file
    ///
    /// - Parameter sender: The button
    @IBAction func openLayoutAction(_ sender: Any) {
        // Open file
        // Pass it to the editor
        dismiss(nil)
    }
}
