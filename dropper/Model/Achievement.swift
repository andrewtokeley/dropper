//
//  Achievement.swift
//  dropper
//
//  Created by Andrew Tokeley on 12/03/23.
//

import Foundation

/**
 Enum of all possible achievements a player can collect
 */
enum Achievement: Int {
    case oneRow = 0
    case twoRows
    case threeRows
    case fourRows
    case explodedBlock
    case match10
    case match20
    case colourMatch
}

class Achievements {
    
    private var state: [Achievement: Int] = [:]
    
    static var zero: Achievements {
        let zero = Achievements()
        zero.clear()
        return zero
    }
    
    public func clear() {
        state[.oneRow] = 0
        state[.twoRows] = 0
        state[.threeRows] = 0
        state[.fourRows] = 0
        state[.explodedBlock] = 0
        state[.match10] = 0
        state[.match20] = 0
        state[.colourMatch] = 0
    }
    
    init() {
        clear()
    }
    
    public func set(_ achievement: Achievement, _ value: Int) {
        state[achievement] = abs(value)
    }
    
    public func addTo(_ achievement: Achievement, _ value: Int) {
        set(achievement, get(achievement) + value)
    }
    
    public func get(_ achievement: Achievement) -> Int {
        return state[achievement]!
    }
    
    public func sum(_ achievements: [Achievement]) -> Int {
        var sum = 0
        for a in achievements {
            sum += get(a)
        }
        return sum
    }
    
    /**
     Merge with another achievement
     */
    public func merge(_ achievements: Achievements) {
        addTo(.oneRow, achievements.get(.oneRow))
        addTo(.twoRows, achievements.get(.twoRows))
        addTo(.threeRows, achievements.get(.threeRows))
        addTo(.fourRows, achievements.get(.fourRows))
        addTo(.explodedBlock, achievements.get(.explodedBlock))
        addTo(.match10, achievements.get(.match10))
        addTo(.match20, achievements.get(.match20))
        addTo(.colourMatch, achievements.get(.colourMatch))
    }
}
