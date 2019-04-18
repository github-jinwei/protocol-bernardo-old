//
//  RecentFileCellView.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-04-03.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class RecentFileCellView: NSTableCellView {
	@IBOutlet weak var fileIcon: NSImageView!
	@IBOutlet weak var filenameLabel: NSTextField!
	@IBOutlet weak var filepathLabel: NSTextField!

	var fileURL: URL!
}
