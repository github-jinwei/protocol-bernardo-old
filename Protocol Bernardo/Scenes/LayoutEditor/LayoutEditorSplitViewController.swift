//
//  LayoutEditorSplitViewController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class LayoutEditorSplitViewController: NSSplitViewController {
    // ///////////
    // Properties
    
    var window: LayoutWindowController!
    
    @IBOutlet weak var editorSplitViewItem: NSSplitViewItem!
    @IBOutlet weak var sidebarSplitViewItem: NSSplitViewItem!
    
    var sidebar: LayoutEditorSidebar {
        return sidebarSplitViewItem.viewController as! LayoutEditorSidebar
    }
    
    var editor: LayoutEditor {
        return editorSplitViewItem.viewController as! LayoutEditor
    }
    
    // ///////////////
    // View Lifecycle
    
    override func viewDidAppear() {
        editor.sidebar = sidebar
        
        sidebar.editor = editor
    }
    
    func setLayout(_ layout: Layout) {
        editor.setLayout(layout)
    }
}
