//
//  Settings.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/03/23.
//

import Foundation

struct Settings: Codable {
    var useDefaults: Bool = true
    var showGrid: Bool = false
    var enableHaptics: Bool = false
    var showGhost: Bool = false
    var lastPlayed: Date = Date.distantPast
    
    static var defaultGlobalSettings: Settings {
        return Settings(
            useDefaults: true,
            showGrid: false,
            enableHaptics: false,
            showGhost: false,
            lastPlayed: Date.distantPast)
            
    }
    
    static var defaultGameSettings: Settings {
        return Settings(
            useDefaults: true)            
    }
}
