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
    let settingsService = ServiceFactory.sharedInstance.settingsService
}

// MARK: - SettingsInteractor API
extension SettingsInteractor: SettingsInteractorApi {
    
    func loadSettings(for title: GameTitle? = nil) {
        // get global settings
        settingsService.getSettings() { settings in
            if let settings = settings {
                self.presenter.didLoadSettings(settings, showClearHighScores: true)
            }
        }
    }

    func saveSettings(settings: Settings, for title: GameTitle? = nil) {
        if let title = title {
            gameService.saveSettings(for: title, settings: settings) {
                self.presenter.didSaveSettings(settings)
            }
        } else {
            settingsService.saveSettings(settings: settings) {
                self.presenter.didSaveSettings(settings)
            }
        }
    }
    
    func clearHighScores(for title: GameTitle? = nil) {
        gameService.clearScoreState(for: title) { result in
            if result {
                self.presenter.didClearHighScores()
            }
        }
    }
    
}

// MARK: - Interactor Viper Components Api
private extension SettingsInteractor {
    var presenter: SettingsPresenterApi {
        return _presenter as! SettingsPresenterApi
    }
}
