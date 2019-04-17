//
//  EditionSidebarController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

/// The edition sidebar, allowing the user to create new elements and
/// fine tune an element parameters.
class EditionSidebarController: NSViewController, DocumentHandlerSidebar {

    // //////////////////
    // MARK: - Properties

	/// Reference to the document
	weak var document: LayoutDocument!

    /// The view holding an element parameters view
    @IBOutlet weak var parametersViewHolder: NSView!

    override func viewDidAppear() {
		document.layoutView.delegate = self
		
		canvas(document.layoutView, selectionChanged: document.layoutView.selectedNode)
    }
    
    
    // /////////////////////////
    // MARK: - Elements creation
    
    /// Tell the layoutView to add a new device to the layout
    ///
    /// - Parameter sender:
    @IBAction func addDevice(_: Any) {
        document.layoutView.createDevice()
    }
    
    /// Tell the layoutView to add a new line to the layout
    ///
    /// - Parameter sender:
    @IBAction func addLine(_: Any) {
         document.layoutView.createLine()
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
extension EditionSidebarController: LayoutCanvasDelegate {

	func canvas(_: LayoutViewController, document: LayoutDocument) {
		document.updateChangeCount(.changeDone)
	}

    /// Display the parameter views for the given elements
    ///
    /// - Parameter element: A Layout Canvas Element
	func canvas(_: LayoutViewController, selectionChanged element: LayoutCanvasElement?) {
        guard let element = element else {
            clear()
            return
        }
        
        // Are we already displaying something ? If so, clean
        if parametersViewHolder.subviews.count > 0 {
            clear()
        }
        
        let elementParametersView: NSViewController = element.parametersController
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
