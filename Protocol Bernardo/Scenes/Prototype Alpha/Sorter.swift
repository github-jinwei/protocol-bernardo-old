//
//  Sorter.swift
//  Prototype Alpha Sort
//
//  Created by Marie-Lou Barbier on 2019-03-14.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import simd

class Sorter {
    public var folderIndex: Int = 0                     // index of current folder to work with
    private var workingTable: [Int] = Array(0..<36)     // the sorted Int table from 0 to 35
    private var isSorted: Bool = true                   // table sorting state
    private let chaosThreshold: Double = 0.2            // probability of shuffling a fully sorted table

    var sortLevel: Float {
        var goodPlace = 0;

        for i in 0..<workingTable.count {
            if workingTable[i] == i {
                goodPlace += 1
            }
        }

        return Float(goodPlace) / Float(workingTable.count);
    }
    
    
    public func sortTable(_ chaosRate: Double) -> Void {
        // browsing the working table
        for i in 0..<workingTable.count {
            let currentIndex: Int = i
            var otherIndex: Int

            let deltaMax = Int(Double(workingTable.count) * chaosRate) + 1
            var delta = Int.random(in: 1...deltaMax)
            delta = delta - (delta / 2);

            otherIndex = currentIndex + delta
            otherIndex = Int(simd_clamp(Double(otherIndex), Double(0), Double(workingTable.count - 1)))
            
            let currentValue = workingTable[currentIndex]
            let otherValue = workingTable[otherIndex]
            
            
            let randomComparator: Double = Double.random(in: 0...1)
            
            // has a chance to sort values when they are not sorted
            if(currentIndex < otherIndex) {
                if((currentValue > otherValue) && (randomComparator > chaosRate)) {
                    workingTable.swapAt(currentIndex, otherIndex)
                }
                if((currentValue < otherValue) && (randomComparator < chaosRate)) {
                    workingTable.swapAt(currentIndex, otherIndex)
                }
            }
            
            if(currentIndex > otherIndex) {
                if((currentValue < otherValue) && (randomComparator > chaosRate)) {
                    workingTable.swapAt(currentIndex, otherIndex)
                }
                if((currentValue > otherValue) && (randomComparator < chaosRate)) {
                    workingTable.swapAt(currentIndex, otherIndex)
                }
            }
        }
    }
    
    
    public func shuffleTable(_ chaosRate: Double) -> Void {
        // browsing the working table
        for i in 0..<workingTable.count - 1 {
            let current = workingTable[i]
            let next = workingTable[i+1]
            
            let randomComparator: Double = Double.random(in: 0...1)
            
            // has a little chance to shuffle values if they are already sorted
            if(current <= next && randomComparator < chaosRate) {
                workingTable.swapAt(i, Int.random(in: 0...35))
            }
        }
    }
    
    
    // sets table state to sorted or not
    public func checkTableSorted() -> Bool {
        for i in 0..<workingTable.count - 1 {
            let current = workingTable[i]
            let next = workingTable[i+1]
            
            if(current > next) {
                return false
            }
        }
        
        return true
    }
    
    
    // shuffles and returns the working table depending on chaos rate
    public func getSortedTable(chaosRate: Double) -> [Int] {
        // returns table when it is fully sorted and chaos rate is too low)
        if(self.isSorted && chaosRate < chaosThreshold) {
            return workingTable
        }
        
        if(isSorted && chaosRate > chaosThreshold) {
            // picks the following folder
            folderIndex += 1
            
            if(folderIndex > 2) {
                folderIndex = 0
            }
        }
        
        // --- sorting / shuffling operations ---
        sortTable(chaosRate)
        shuffleTable(chaosRate)
        
        isSorted = checkTableSorted()
//        print("table sorted ? \(isSorted)")
        
        return workingTable
    }
}
