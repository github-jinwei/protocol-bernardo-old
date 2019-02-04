//
//  LayoutEditorSidebar.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class LayoutEditorSidebar: NSViewController {
    
    override func viewDidLoad() {
    }
    
    func clear() {
        guard children.count > 0 else { return }
        
        removeChild(at: 0)
        view.subviews[0].removeFromSuperview()
    }
    
    func displayParameters(ofElement element: LayoutEditorElement) {
        let elementParametersView: NSViewController = element.getParametersController()
        elementParametersView.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(elementParametersView)
        view.addSubview(elementParametersView.view)
        
        NSLayoutConstraint.activate([
            elementParametersView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            elementParametersView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            elementParametersView.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 3),
        ])
    }
}
