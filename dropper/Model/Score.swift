//
//  Score.swift
//  dropper
//
//  Created by Andrew Tokeley on 13/04/23.
//

import Foundation

/**
 Structure used to record a score for a game that can be saved to history.
 */
struct Score: Codable {
    
    /**
     Total number of points achieved
     */
    var points: Int = 0
    
    /**
     Combined achievements for game
     */
    var gameAchievements: Achievements = Achievements.zero
        
}
