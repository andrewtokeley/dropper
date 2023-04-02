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
                // check if there are any high scores
                self.gameService.getScoreHistory(for: title) { scores in
                    self.presenter.didLoadSettings(settings, showClearHighScores: scores.count > 0)
                }
            }
        }
    }
    
    func saveSettings(for title: GameTitle, settings: Settings) {
        gameService.saveSettings(for: title, settings: settings) {
            self.presenter.didSaveSettings(settings)
        }
    }
    
    func clearHighScores(for title: GameTitle) {
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
