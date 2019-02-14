//
//  LayoutSidebarEdition.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

/// The edition sidebar, allowing the user to create new elements and
/// fine tune an element parameters.
class LayoutSidebarEdition: NSViewController {
    // //////////////////
    // MARK: - Properties
    
    /// Reference to the LayoutEditor
    weak var canvas: LayoutCanvas!

    /// The view holding an element parameters view
    @IBOutlet weak var parametersViewHolder: NSView!

    override func viewDidAppear() {
        setSelectedElement(canvas.selectedNode)
    }
    
    
    // /////////////////////////
    // MARK: - Elements creation
    
    /// Tell the canvas to add a new device to the layout
    ///
    /// - Parameter sender:
    @IBAction func addDevice(_ sender: Any) {
        canvas?.createDevice()
    }
    
    /// Tell the canvas to add a new line to the layout
    ///
    /// - Parameter sender:
    @IBAction func addLine(_ sender: Any) {
         canvas?.createLine()
    }
    
    // //////////////////
    // MARK: - Others
    
    /// Remove the currently displayed element paremeters view
    func clear() {
        guard children.count > 0 else { return }
        
        removeChild(at: 0)
        parametersViewHolder.subviews[0].removeFromSuperview()
    }
}


// /////////////////////
// MARK: - LayoutSidebar
extension LayoutSidebarEdition: LayoutSidebar {
    /// Display the parameter views for the given elements
    ///
    /// - Parameter element: A Layout Canvas Element
    func setSelectedElement(_ element: LayoutCanvasElement?) {
        guard let element = element else {
            clear()
            return
        }
        
        // Are we already displaying something ? If so, clean
        if parametersViewHolder.subviews.count > 0 {
            clear()
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
    }
}
