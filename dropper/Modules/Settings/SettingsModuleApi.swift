//
//  SettingsModuleApi.swift
//  dropper
//
//  Created by Andrew Tokeley on 20/03/23.
//
//

import Viperit

//MARK: - SettingsRouter API
protocol SettingsRouterApi: RouterProtocol {
}

//MARK: - SettingsView API
protocol SettingsViewApi: UserInterfaceProtocol {
    func displayTitle(_ title: String)
    func displaySettings(_ settings: Settings, showClearHighScores: Bool)
    func enableClearHighScoresOption(_ enable: Bool)
}

//MARK: - SettingsPresenter API
protocol SettingsPresenterApi: PresenterProtocol {
    func didLoadSettings(_ settings: Settings, showClearHighScores: Bool)
    func didSelectClearHighScores()
    func didClearHighScores()
    func didUpdateShowGrid(show: Bool)
    func didUpdateShowGhost(show: Bool)
    func didSelectEnableHaptics(enabled: Bool)
    func didSaveSettings(_ settings: Settings)
    func didSelectClose()
}

//MARK: - SettingsInteractor API
protocol SettingsInteractorApi: InteractorProtocol {
    func loadSettings(for title: GameTitle?)
    func saveSettings(settings: Settings, for title: GameTitle?)
    func clearHighScores(for title: GameTitle?)
}
