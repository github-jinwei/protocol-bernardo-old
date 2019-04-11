//
//  LayoutDocumentObserver.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-04-08.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

protocol LayoutDocumentObserver: AnyObject {
	func layout(_: LayoutDocument, calibrationProfileDidChanged: LayoutCalibrationProfile?)
}
