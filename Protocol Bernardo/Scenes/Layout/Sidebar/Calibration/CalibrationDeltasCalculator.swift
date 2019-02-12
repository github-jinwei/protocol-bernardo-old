//
//  CalibrationDeltasCalculator.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-10.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

class CalibrationDeltasCalculator {
    /// Queue of stored positions coming from the device being calibrated
    var calibrationPositionsQueue = Queue<Position>()
    
    /// Queue of stored positions coming fron the reference device
    var referencePositionsQueue = Queue<Position>()
    
    /// Number of positions stored in the queues
    var positionsCount: Int = 0
}

extension CalibrationDeltasCalculator {
    func insert(calibrationPosition: Position, referencePosition: Position) {
        calibrationPositionsQueue.enqueue(value: calibrationPosition)
        referencePositionsQueue.enqueue(value: referencePosition)
        
        positionsCount += 1
    }
    
    func reset() {
        calibrationPositionsQueue = Queue<Position>()
        referencePositionsQueue = Queue<Position>()
        
        positionsCount = 0
    }
}

extension CalibrationDeltasCalculator {
    /// Gives the calibration deltas using the stored positions. If
    /// not enough usable positions are available, this method returns nil
    ///
    /// - Returns: The calibration deltas
    func getDeltas() -> CalibrationDeltas? {
        guard positionsCount > 15 else { return nil }
        
        var deltas = CalibrationDeltas()
        
        let calibratingVector = movementVector(forQueue: calibrationPositionsQueue)
        let referenceVector = movementVector(forQueue: referencePositionsQueue)
        
        deltas.orientation = referenceVector.angle(with: calibratingVector)
        
        // Get and remove front positions from the queues
        let calibrationPosition = calibrationPositionsQueue.dequeue()!
        let referencePosition = referencePositionsQueue.dequeue()!
        self.positionsCount -= 1
        
        deltas.xPosition = calibrationPosition.x - referencePosition.x
        deltas.yPosition = calibrationPosition.z - referencePosition.z
        
        deltas.height = calibrationPosition.y - referencePosition.y
        
        return deltas
    }
    
    internal func movementVector(forQueue queue: Queue<Position>) -> Position {
        let oldPos = queue.front
        let lastPos = queue.back
        
        return abs(oldPos - lastPos)
    }
}
