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
    
    override func viewHasLoaded() {
        interactor.loadSettings()
    }
    
    override func setupView(data: Any) {
        if let setupData = data as? SettingsSetupData {
            delegate = setupData.delegate
        }
    }
}

// MARK: - SettingsPresenter API
extension SettingsPresenter: SettingsPresenterApi {
    
    func didLoadSettings(_ settings: Settings) {
        self.settings = settings
        view.displaySettings(settings)
    }
    
    func didUpdateShowGhost(show: Bool) {
        settings.showGhost = show
        interactor.saveSettings(settings)
    }
    
    func didUpdateShowGrid(show: Bool) {
        settings.showGrid = show
        interactor.saveSettings(settings)
    }
    
    func didSaveSettings(_ settings: Settings) {
        delegate?.didUpdateSettings(settings)
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
