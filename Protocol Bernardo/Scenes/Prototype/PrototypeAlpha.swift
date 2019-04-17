//
//  PrototypeAlpha.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-03-18.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import Repeat
import simd

struct SortingData: Codable {
    var positions: [Int]
    var folder: Int
    var coef: Float
    var sortLevel: Float
}

class PrototypeAlpha {
    let sorter = Sorter()

    private var repeater: Repeater?

    let maxDistance: Float = 1000.0 // mm

    var socket = Socket()

    init() {
        socket.connect(to: "localhost", port: 5000)

        repeater = Repeater(interval: .milliseconds(1000),
                            mode: .infinite,
                            tolerance: .milliseconds(100),
                            queue: DispatchQueue.global(qos: .utility),
                            observer: self.refresh)
        repeater?.start()

        _ = sorter.getSortedTable(chaosRate: 1.0)

    }

    func refresh(_: Repeater) {
        let users = App.usersEngine.users

        var acc: Float = 0.01

        for user in users {
            var deltaX = abs(user.latestPhysic.skeleton.torso.position.x - user.firstPhysic.skeleton.torso.position.x)
            var deltaZ = abs(user.latestPhysic.skeleton.torso.position.z - user.firstPhysic.skeleton.torso.position.z)

            deltaX = simd_clamp(deltaX, 0, maxDistance) / 1000
            deltaZ = simd_clamp(deltaZ, 0, maxDistance) / 1000

            acc += (deltaX + deltaZ) / 2
        }

        if(users.count > 0) {
            acc /= Float(users.count)
        }
        
        var dataStruct = SortingData(positions: [], folder: 0, coef: acc, sortLevel: 0)

        dataStruct.positions = sorter.getSortedTable(chaosRate: Double(acc))
        dataStruct.folder = sorter.folderIndex
        dataStruct.sortLevel = sorter.sortLevel

        let encoder = JSONEncoder()
        encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "1.0", negativeInfinity: "0.0", nan: "0.0")
        let data = try! encoder.encode(dataStruct)
        socket.emit(data: data)
    }
}
