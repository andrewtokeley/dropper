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
    
    private var showClearHighScoresOption = false
    
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
    
    lazy var clearStateTableViewCell: UITableViewCell = {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: nil)
        let button = UIButton(primaryAction: UIAction { (action) in
            self.presenter.didSelectClearHighScores()
        })
        button.setTitle("Clear high scores", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.contentHorizontalAlignment = .left
        button.tag = 123
        cell.contentView.addSubview(button)
        
        button.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0))
        button.autoSetDimension(.height, toSize: 50)
        return cell
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
    
    func removeClearHighScoresOption() {
        self.showClearHighScoresOption = false
        tableView.reloadData()
    }
    
    func displaySettings(_ settings: Settings, showClearHighScores: Bool) {
        self.title = "Settings"
        self.view.backgroundColor = .white

        showGridSwitch.isOn = settings.showGrid
        showGhostSwitch.isOn = settings.showGhost
        
        self.showClearHighScoresOption = showClearHighScores
        self.tableView.reloadData()
    }
    
    func displayTitle(_ title: String) {
        self.title = title
    }
}

extension SettingsView: UITableViewDelegate {
    
}

extension SettingsView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return ""
        }
        return "This action will remove all high scores for this game."
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Game Options"
        } else {
            return "Scores"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 {
            if row == 0 {
                return showGridTableViewCell
            } else {
                return showGhostTableViewCell
            }
        } else if section == 1 {
            
            if let button = clearStateTableViewCell.viewWithTag(123) as? UIButton {
                button.isEnabled = self.showClearHighScoresOption
            }
            return clearStateTableViewCell
        }
        return UITableViewCell()
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
