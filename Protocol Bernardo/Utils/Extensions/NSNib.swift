//
//  NSNib.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

extension NSNib {
    static func make<T>(fromNib nibName: String, owner: AnyObject?) -> T {
        var instanciatedViews: NSArray? = []
        
        // Instanciate the views
        guard Bundle.main.loadNibNamed(nibName, owner: owner, topLevelObjects: &instanciatedViews), let objects = instanciatedViews else {
            fatalError("Could not load view from nib file \(nibName)")
        }
        
        // Filter for the correct type of view
        let views = objects.filter { $0 is T }
        
        guard views.count == 1 else {
            fatalError("Could not extract the view from the nib. (Number of view with the correct type found : \(views.count)")
        }
        
        return views.first as! T
    }
}
