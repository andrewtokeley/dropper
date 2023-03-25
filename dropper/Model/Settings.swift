//
//  Settings.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/03/23.
//

import Foundation

struct Settings: Codable {
    var showGrid: Bool = false
    var enableHaptics: Bool = false
    var showGhost: Bool = true
    
    static var defaultSettings: Settings {
        return Settings(showGrid: true, enableHaptics: true, showGhost: true)
    }
}
