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
    case colourMatchGroup
    case jewel
    
    var description: String {
        switch self {
        case .oneRow: return "1 Row"
        case .twoRows: return "2 Row"
        case .threeRows: return "3 Row"
        case .fourRows: return "4 Row"
        case .explodedBlock: return "Explodeed Blocks"
        case .match10: return "Match 10"
        case .match20: return "Match 20"
        case .colourMatch: return "Colour Match"
        case .colourMatchGroup: return "Colour Match Group"
        case .jewel: return "Jewel"
        }
    }
}

class Achievements: Codable {
    
    private var state: [Int: Int] = [:]
    
    static var zero: Achievements {
        let zero = Achievements()
        zero.clear()
        return zero
    }
    
    public func clear() {
        state[Achievement.oneRow.rawValue] = 0
        state[Achievement.twoRows.rawValue] = 0
        state[Achievement.threeRows.rawValue] = 0
        state[Achievement.fourRows.rawValue] = 0
        state[Achievement.explodedBlock.rawValue] = 0
        state[Achievement.match10.rawValue] = 0
        state[Achievement.match20.rawValue] = 0
        state[Achievement.colourMatch.rawValue] = 0
        state[Achievement.colourMatchGroup.rawValue] = 0
        state[Achievement.jewel.rawValue] = 0
    }
    
    init() {
        clear()
    }
    
    /**
     Returns the total number of rows removed based on row achievements
     */
    public var totalRowsRemoved: Int {
        return get(.oneRow) + 2 * get(.twoRows) + 3 * get(.threeRows) + 4 * get(.fourRows)
    }
    
    /**
     Sets the total for an achievement
     */
    public func set(_ achievement: Achievement, _ value: Int) {
        state[achievement.rawValue] = abs(value)
    }
    
    /**
     Adds another achievement to the total of achievements of this type
     */
    public func addTo(_ achievement: Achievement, _ value: Int) {
        set(achievement, get(achievement) + value)
    }
    
    /**
     Returns the number of achievements of the given type
     */
    public func get(_ achievement: Achievement) -> Int {
        if let state = state[achievement.rawValue] {
            return state
        }
        return 0
    }
    
    /**
     Returns the sum across a set of achievements.
     */
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
        addTo(.colourMatchGroup, achievements.get(.colourMatchGroup))
        addTo(.jewel, achievements.get(.jewel))
    }
}

extension Achievements: CustomStringConvertible {
    var description: String {
        var result: String = ""
        for achievement in state {
            if achievement.value > 0 {
                if let achievementAsString = Achievement(rawValue: achievement.key) {
                    result += "\(achievementAsString):\(achievement.value)\n"
                }
            }
        }
        if result != "" {
            return result
        }
        return "No Achievements"
    }
}
