//
//  HomeViewController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-04-03.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class HomeViewController: NSViewController {

	@IBOutlet weak var recentFilesList: NSOutlineView!

	@IBAction func newLayout(_ sender: Any) {
		App.layoutEngine.newLayout()
	}

	@IBAction func openLayout(_ sender: Any) {
		App.layoutEngine.openLayout()
	}

	override func viewDidAppear() {
		super.viewDidAppear()

		App.core.registerHomeWindow(self.view.window!.windowController!)
	}

	override func keyDown(with event: NSEvent) {
		guard event.keyCode == Keycode.returnKey || event.keyCode == Keycode.enter else { return }

		if let fileURL = recentFilesList.item(atRow: recentFilesList.selectedRow) as? URL {
			App.layoutEngine.openLayout(at: fileURL)
		}
	}
}

extension HomeViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return false
	}

	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return App.layoutEngine.documentsController.recentDocumentURLs.count
		}

		return 0
	}

	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if item == nil {
			return App.layoutEngine.documentsController.recentDocumentURLs[index]
		}

		return ""
	}

	func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
		return 60
	}
}

extension HomeViewController: NSOutlineViewDelegate {
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		guard let fileURL = item as? URL else { return nil }

		let fileCell = recentFilesList.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "recentFileCell"), owner: self) as! RecentFileCellView

		let wrapper = try! FileWrapper(url: fileURL, options: .withoutMapping)
		fileCell.fileIcon.image = wrapper.icon
		fileCell.filenameLabel.stringValue = wrapper.filename!
		fileCell.filepathLabel.stringValue = fileURL.relativeString.removingPercentEncoding!
		fileCell.fileURL = fileURL

		return fileCell
	}
}
