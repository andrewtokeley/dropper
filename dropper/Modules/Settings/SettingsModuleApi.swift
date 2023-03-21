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
    func displaySettings(_ settings: Settings)
}

//MARK: - SettingsPresenter API
protocol SettingsPresenterApi: PresenterProtocol {
    func didLoadSettings(_ settings: Settings)
    func didUpdateShowGrid(show: Bool)
    func didUpdateShowGhost(show: Bool)
    func didSaveSettings(_ settings: Settings)
}

//MARK: - SettingsInteractor API
protocol SettingsInteractorApi: InteractorProtocol {
    func loadSettings()
    func saveSettings(_ settings: Settings)
}
