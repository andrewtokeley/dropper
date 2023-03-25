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
    let gameService = ServiceFactory.sharedInstance.gameService
}

// MARK: - SettingsInteractor API
extension SettingsInteractor: SettingsInteractorApi {
    
    func loadSettings(for title: GameTitle) {
        gameService.getSettings(for: title) { settings in
            if let settings = settings {
                self.presenter.didLoadSettings(settings)
            }
        }
    }
    
    func saveSettings(for title: GameTitle, settings: Settings) {
        gameService.saveSettings(for: title, settings: settings) {
            self.presenter.didSaveSettings(settings)
        }
    }
    
}

// MARK: - Interactor Viper Components Api
private extension SettingsInteractor {
    var presenter: SettingsPresenterApi {
        return _presenter as! SettingsPresenterApi
    }
}
