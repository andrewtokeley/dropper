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
    case enableHaptics
}

private class TableViewDefinitions {
    
    var sectionRows = [Int]()
    var sectionHeaders = [String?]()
    var sectionFooters = [String?]()
    var tableViewCells: [IndexPath: UITableViewCell] = [:]
    
    init(sectionRows: [Int], sectionHeaders: [String?], sectionFooters: [String?]) {
        self.sectionRows = sectionRows
        self.sectionHeaders = sectionHeaders
        self.sectionFooters = sectionFooters
    }
    
    var sectionCount: Int {
        return sectionRows.count
    }

    func rowsInSection(_ section: Int) -> Int {
        guard section < sectionRows.count else { return 0 }
        return sectionRows[section]
    }
    func titleForHeader(_ section: Int) -> String? {
        guard section < sectionHeaders.count else { return nil }
        return sectionHeaders[section]
    }
    func titleForFooter(_ section: Int) -> String? {
        guard section < sectionFooters.count else { return nil }
        return sectionFooters[section]
    }
    func tableViewCellFor(_ indexPath: IndexPath) -> UITableViewCell? {
        guard indexPath.section < sectionFooters.count else { return nil }
        guard indexPath.row < rowsInSection(indexPath.section) else { return nil }
        return tableViewCells[indexPath]
    }
}

// MARK: - SettingsView Class

final class SettingsView: UserInterface {
    
    private var showClearHighScoresOption = false
    private var tableViewDefinitions = TableViewDefinitions(
        sectionRows: [2,1,1],
        sectionHeaders: ["Game Options", "Vibrations", "Highscores"],
        sectionFooters: [nil, "Vibrations when you clear a row or make a match", "This is permanent"]
        )
    
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
    
    lazy var enableHapticsTableViewCell: UITableViewCell = {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: nil)
        cell.accessoryView = enableHapticsSwitch
        cell.textLabel?.text = "Enable Haptics"
        cell.selectionStyle = .none
        return cell
    }()
    
    lazy var enableHapticsSwitch: UISwitch = {
        let switchView = UISwitch()
        switchView.addTarget(self, action: #selector(handleSwitchToggle(_:)), for: .valueChanged)
        switchView.tag = SettingsSwitch.enableHaptics.rawValue
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
        
        self.tableViewDefinitions.tableViewCells = [
            IndexPath(row: 0, section: 0): showGridTableViewCell,
            IndexPath(row: 1, section: 0): showGhostTableViewCell,
            IndexPath(row: 0, section: 1): enableHapticsTableViewCell,
            IndexPath(row: 0, section: 2): clearStateTableViewCell
        ]
        
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
            case SettingsSwitch.enableHaptics:
                presenter.didSelectEnableHaptics(enabled: sender.isOn)
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
        enableHapticsSwitch.isOn = settings.enableHaptics
        
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
        return tableViewDefinitions.titleForFooter(section)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewDefinitions.sectionCount
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewDefinitions.titleForHeader(section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDefinitions.rowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableViewDefinitions.tableViewCellFor(indexPath) {
            // special case for clearStateTableView
            if let button = cell.viewWithTag(123) as? UIButton {
                button.isEnabled = self.showClearHighScoresOption
            }
            return cell
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
