//
//  SettingsService.swift
//  dropper
//
//  Created by Andrew Tokeley on 11/04/23.
//

import Foundation

/**
 Protocol that defines the methods for the SettingsService. This service is responsible for managing global settings.
 */
protocol SettingsServiceContract {
        
    func getSettings(completion: ((Settings?) -> Void)?)
    func saveSettings(settings: Settings, completion: (()->Void)?)
    func clearSettingsState(completion: ((Bool)->Void)?)

}

class SettingsService: ServiceBase {
    enum KeyType: String {
        case SETTINGS = "dropper_settings"
    }
    
    let userDefaults = UserDefaults.standard
    
    var storeKey: String {
        return KEY_PREFIX + KeyType.SETTINGS.rawValue
    }
}

extension SettingsService: SettingsServiceContract {
    
    func getSettings(completion: ((Settings?) -> Void)?) {
        let settings = try? userDefaults.getObject(forKey: storeKey, castTo: Settings.self)
        if let settings = settings {
            completion?(settings)
        } else {
            completion?(Settings.defaultGlobalSettings)
        }
    }
    
    func saveSettings(settings: Settings, completion: (()->Void)?) {
        if let _ = try? userDefaults.setObject(settings, forKey: storeKey) {
            completion?()
        }
    }
    
    func clearSettingsState(completion: ((Bool)->Void)?) {
        userDefaults.removeObject(forKey: storeKey)
        completion?(true)
    }

}


