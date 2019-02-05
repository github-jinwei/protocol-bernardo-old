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
    weak var canvas: LayoutCanvas?
    
    var isDisplayingParameters: Bool = false
    
    @IBOutlet weak var parametersViewHolder: NSView!
    
    /// Tell the canvas to add a new device to the layout
    ///
    /// - Parameter sender:
    @IBAction func addDevice(_ sender: Any) {
        canvas?.createDevice()
    }
    
    /// Tell the canvas to add new line to the layout
    ///
    /// - Parameter sender:
    @IBAction func addLine(_ sender: Any) {
        // canvas?.createLine()
    }
    
    /// Display the parameter views for the given elements
    ///
    /// - Parameter element: A Layout Canvas Element
    func displayParameters(ofElement element: LayoutCanvasElement) {
        if isDisplayingParameters {
            clear()
            isDisplayingParameters = false
        }
        
        let elementParametersView: NSViewController = element.getParametersController()
        elementParametersView.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(elementParametersView)
        parametersViewHolder.addSubview(elementParametersView.view)
        
        NSLayoutConstraint.activate([
            elementParametersView.view.leadingAnchor.constraint(equalTo: parametersViewHolder.leadingAnchor, constant: 0),
            elementParametersView.view.trailingAnchor.constraint(equalTo: parametersViewHolder.trailingAnchor, constant: 0),
            elementParametersView.view.topAnchor.constraint(equalTo: parametersViewHolder.topAnchor, constant: 3),
        ])
        
        isDisplayingParameters = true
    }
    
    /// Remove the currently displayed element paremeters view
    func clear() {
        guard children.count > 0 else { return }
        
        removeChild(at: 0)
        parametersViewHolder.subviews[0].removeFromSuperview()
    }
}
