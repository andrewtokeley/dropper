//
//  SettingsInteractor.swift
//  dropper
//
//  Created by Andrew Tokeley on 20/03/23.
//
//

import Foundation
import Viperit

// MARK: - SettingsInteractor Class
final class SettingsInteractor: Interactor {
}

// MARK: - SettingsInteractor API
extension SettingsInteractor: SettingsInteractorApi {
    func loadSettings() {
        presenter.didLoadSettings(Settings())
    }
    
    func saveSettings(_ settings: Settings) {
        presenter.didSaveSettings(settings)
    }
    
}

// MARK: - Interactor Viper Components Api
private extension SettingsInteractor {
    var presenter: SettingsPresenterApi {
        return _presenter as! SettingsPresenterApi
    }
}
