//
//  LayoutCalibrationDocument.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-06.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class LayoutCalibrationDocument: NSDocument {
    weak var delegate: NSDocumentDelegate?
    
    weak var _layoutDocument: LayoutDocument?
    
    internal var _calibration = LayoutCalibration()
    
    var calibration: LayoutCalibration {
        return _calibration
    }
}

extension LayoutCalibrationDocument {
    override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
        guard fileWrapper.isRegularFile else {
            Swift.print("Invalid Selection")
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        
        // Load the content of the layout and store it
        let calibrationData = fileWrapper.regularFileContents!
        _calibration = try! JSONDecoder().decode([LayoutCalibration].self,
                                 from: calibrationData)[0]
    }
    
    override func write(to url: URL, ofType typeName: String) throws {
        do {
            let calibrationData = try JSONEncoder().encode([_calibration])
            try calibrationData.write(to: url, options: [])
        } catch {
            NSAlert(error: error).runModal()
            return
        }
        
        delegate?.document(self, didSave: true, contextInfo: nil)
    }
}

extension LayoutCalibrationDocument {
    func setLayoutDocument(_ layoutDocument: LayoutDocument) {
        _layoutDocument = layoutDocument
    }
}
