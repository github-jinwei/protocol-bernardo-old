//
//  String.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-22.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

extension String {
    /// Returns the string the C char[] format comopatible
    ///
    /// - Returns: The char[]
    func CString() -> UnsafePointer<Int8> {
        return (self as NSString).utf8String!
    }
    
    /// If the string represent a filename, give the extension without the dot "."
    var fileExtension: String {
        return String(self.split(separator: ".").last!)
    }
    
    /// If the string represent a filename (not a pathc), give the file name
    /// without the extension
    var fileNameWithoutExtension: String {
        return String(self.split(separator: ".").first!)
    }
}
