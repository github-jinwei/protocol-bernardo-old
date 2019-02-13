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
    
    var recentCalibrationPosition: Position!
    
    /// Queue of stored positions coming fron the reference device
    var referencePositionsQueue = Queue<Position>()
    
    var recentReferencePosition: Position!
    
    /// Number of positions stored in the queues
    var positionsCount: Int = 0
}

extension CalibrationDeltasCalculator {
    func insert(calibrationPosition: Position, referencePosition: Position) {
        calibrationPositionsQueue.enqueue(value: calibrationPosition)
        referencePositionsQueue.enqueue(value: referencePosition)
        
        recentCalibrationPosition = calibrationPosition
        recentReferencePosition = referencePosition
        
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
        
        let calibratingVector = movementVector(from: recentCalibrationPosition, forQueue: calibrationPositionsQueue)
        let referenceVector = movementVector(from: recentReferencePosition, forQueue: referencePositionsQueue)
        
        self.positionsCount -= 1
        
        deltas.orientation = referenceVector.angle(with: calibratingVector)
        
        deltas.xPosition = recentCalibrationPosition.x - recentReferencePosition.x
        deltas.yPosition = recentCalibrationPosition.z - recentReferencePosition.z
        
        deltas.height = recentCalibrationPosition.y - recentReferencePosition.y
        
        return deltas
    }
    
    internal func movementVector(from: Position, forQueue queue: Queue<Position>) -> Position {
        let oldPos = from
        let lastPos = queue.dequeue()!
        
        return abs(oldPos - lastPos)
    }
}
