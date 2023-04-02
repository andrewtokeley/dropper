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
        if let title = self.gameTitle {
            interactor.loadSettings(for: title)
        }
    }
    
    override func setupView(data: Any) {
        if let setupData = data as? SettingsSetupData {
            self.delegate = setupData.delegate
            self.gameTitle = setupData.gameTitle
        }
    }
}

// MARK: - SettingsPresenter API
extension SettingsPresenter: SettingsPresenterApi {
    
    func didClearHighScores() {
        view.removeClearHighScoresOption()
    }
    
    func didSelectClearHighScores() {
        if let title = self.gameTitle {
            interactor.clearHighScores(for: title)
        }
    }
    func didLoadSettings(_ settings: Settings, showClearHighScores: Bool) {
        self.settings = settings
        view.displaySettings(settings, showClearHighScores: showClearHighScores)
        if let title = self.gameTitle {
            view.displayTitle("\(title.title) Settings")
        }
    }
    
    func didUpdateShowGhost(show: Bool) {
        if let title = self.gameTitle {
            settings.showGhost = show
            interactor.saveSettings(for: title, settings: settings)
        }
    }
    
    func didUpdateShowGrid(show: Bool) {
        if let title = self.gameTitle {
            settings.showGrid = show
            interactor.saveSettings(for: title, settings: settings)
        }
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
