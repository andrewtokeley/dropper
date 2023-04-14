//
//  SettingsPresenter.swift
//  dropper
//
//  Created by Andrew Tokeley on 20/03/23.
//
//

import Foundation
import Viperit

// MARK: - SettingsPresenter Class
final class SettingsPresenter: Presenter {
    
    private var settings: Settings = Settings()
    private var delegate: SettingsDelegate?
    private var gameTitle: GameTitle?
    
    override func viewHasLoaded() {
        interactor.loadSettings(for: self.gameTitle)
    }
    
    override func setupView(data: Any) {
        if let setupData = data as? SettingsSetupData {
            self.delegate = setupData.delegate
            
            // this will be nil if loading from the home view
            self.gameTitle = setupData.gameTitle
        }
    }
}

// MARK: - SettingsPresenter API
extension SettingsPresenter: SettingsPresenterApi {
    
    func didSelectEnableHaptics(enabled: Bool) {
        settings.enableHaptics = enabled
        interactor.saveSettings(settings: settings, for: self.gameTitle)
    }
    
    func didClearHighScores() {
        view.enableClearHighScoresOption(false)
        delegate?.didUpdateSettings(settings)
    }
    
    func didSelectClearHighScores() {
        interactor.clearHighScores(for: self.gameTitle)
        
    }
    
    func didLoadSettings(_ settings: Settings, showClearHighScores: Bool) {
        self.settings = settings
        view.displaySettings(settings, showClearHighScores: showClearHighScores)
        view.displayTitle("Settings")
        
//        if let title = self.gameTitle {
//            view.displayTitle("\(title.title) Settings")
//        } else {
//            view.displayTitle("Global Settings")
//        }
    }
    
    func didUpdateShowGhost(show: Bool) {
        settings.showGhost = show
        interactor.saveSettings(settings: settings, for: self.gameTitle)
    }
    
    func didUpdateShowGrid(show: Bool) {
        settings.showGrid = show
        interactor.saveSettings(settings: settings, for: self.gameTitle)
    }
    
    func didSaveSettings(_ settings: Settings) {
        delegate?.didUpdateSettings(settings)
    }
    
    func didSelectClose() {
        view.viewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Settings Viper Components
private extension SettingsPresenter {
    var view: SettingsViewApi {
        return _view as! SettingsViewApi
    }
    var interactor: SettingsInteractorApi {
        return _interactor as! SettingsInteractorApi
    }
    var router: SettingsRouterApi {
        return _router as! SettingsRouterApi
    }
}
