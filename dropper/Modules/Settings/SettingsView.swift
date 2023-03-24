//
//  SettingsView.swift
//  dropper
//
//  Created by Andrew Tokeley on 20/03/23.
//
//

import UIKit
import Viperit

fileprivate enum SettingsSwitch: Int {
    case showGrid = 0
    case showGhost
}

//MARK: SettingsView Class
final class SettingsView: UserInterface {
    
    lazy private var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.frame, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    lazy var showGhostTableViewCell: UITableViewCell = {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: nil)
        cell.accessoryView = showGhostSwitch
        cell.textLabel?.text = "Show Ghost"
        cell.selectionStyle = .none
        return cell
    }()
    
    lazy var showGhostSwitch: UISwitch = {
        let switchView = UISwitch()
        switchView.addTarget(self, action: #selector(handleSwitchToggle(_:)), for: .valueChanged)
        switchView.tag = SettingsSwitch.showGhost.rawValue
        return switchView
    }()
    
    lazy var showGridTableViewCell: UITableViewCell = {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: nil)
        cell.accessoryView = showGridSwitch
        cell.textLabel?.text = "Show Grid"
        cell.selectionStyle = .none
        return cell
    }()
    
    lazy var showGridSwitch: UISwitch = {
        let switchView = UISwitch()
        switchView.addTarget(self, action: #selector(handleSwitchToggle(_:)), for: .valueChanged)
        switchView.tag = SettingsSwitch.showGrid.rawValue
        return switchView
    }()
    
    override func loadView() {
        super.loadView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(handleClose(_:)))
        self.view.addSubview(tableView)
        setConstraints()
    }
    
    private func setConstraints() {
        tableView.autoPinEdgesToSuperviewEdges()
    }
    
    @objc private func handleClose(_ sender: UIBarButtonItem) {
        presenter.didSelectClose()
    }
    
    @objc private func handleSwitchToggle(_ sender: UISwitch) {
        if let switchView = SettingsSwitch(rawValue: sender.tag) {
            switch switchView {
            case SettingsSwitch.showGrid:
                presenter.didUpdateShowGrid(show: sender.isOn)
                break
            case SettingsSwitch.showGhost:
                presenter.didUpdateShowGhost(show: sender.isOn)
                break
            }
        }
    }
}

//MARK: - SettingsView API
extension SettingsView: SettingsViewApi {
    
    func displaySettings(_ settings: Settings) {
        self.title = "Settings"
        self.view.backgroundColor = .white

        showGridSwitch.isOn = settings.showGrid
        showGhostSwitch.isOn = settings.showGhost
        
        self.tableView.reloadData()
    }
    
}

extension SettingsView: UITableViewDelegate {
    
}

extension SettingsView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Game Options"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if row == 1 {
            return showGridTableViewCell
        } else {
            return showGhostTableViewCell
        }
    }
    
}

// MARK: - SettingsView Viper Components API
private extension SettingsView {
    var presenter: SettingsPresenterApi {
        return _presenter as! SettingsPresenterApi
    }
    var displayData: SettingsDisplayData {
        return _displayData as! SettingsDisplayData
    }
}
