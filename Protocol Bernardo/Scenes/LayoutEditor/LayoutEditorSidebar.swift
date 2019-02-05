//
//  LayoutEditorSidebar.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class LayoutEditorSidebar: NSViewController {
    /// Reference to the LayoutEditor
    weak var editor: LayoutEditor?
    
    @IBOutlet weak var parametersViewHolder: NSView!
    
    /// Tell the editor to add a new device to the layout
    ///
    /// - Parameter sender:
    @IBAction func addDevice(_ sender: Any) {
        editor?.createDevice()
    }
    
    /// Tell the editor to add new line to the layout
    ///
    /// - Parameter sender:
    @IBAction func addLine(_ sender: Any) {
        // editor?.createLine()
    }
    
    
    /// Remove the currently displayed element paremeters view
    func clear() {
        guard children.count > 0 else { return }
        
        removeChild(at: 0)
        parametersViewHolder.subviews[0].removeFromSuperview()
    }
    
    /// Display the parameter views for the given elements
    ///
    /// - Parameter element: A Layout Editor Element
    func displayParameters(ofElement element: LayoutEditorElement) {
        let elementParametersView: NSViewController = element.getParametersController()
        elementParametersView.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(elementParametersView)
        parametersViewHolder.addSubview(elementParametersView.view)
        
        NSLayoutConstraint.activate([
            elementParametersView.view.leadingAnchor.constraint(equalTo: parametersViewHolder.leadingAnchor, constant: 0),
            elementParametersView.view.trailingAnchor.constraint(equalTo: parametersViewHolder.trailingAnchor, constant: 0),
            elementParametersView.view.topAnchor.constraint(equalTo: parametersViewHolder.topAnchor, constant: 3),
        ])
    }
}
