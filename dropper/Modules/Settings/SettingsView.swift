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
    case showGrid
    case showGhost
    case enableHaptics
}

// MARK: - SettingsView Class

final class SettingsView: UserInterface {
    
    private var enableClearHighScoresOption = false
    private var tableViewDefinitions: TableViewDefinitions?
    
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
        cell.imageView?.image = UIImage(named: "ghost")
        cell.imageView?.autoSetDimension(.width, toSize: 26)
        cell.imageView?.autoSetDimension(.height, toSize: 26)
        cell.imageView?.autoAlignAxis(toSuperviewAxis: .horizontal)
        cell.imageView?.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
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
        cell.imageView?.image = UIImage(named: "grid")
        cell.imageView?.autoSetDimension(.width, toSize: 26)
        cell.imageView?.autoSetDimension(.height, toSize: 26)
        cell.imageView?.autoAlignAxis(toSuperviewAxis: .horizontal)
        cell.imageView?.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        return cell
    }()
    
    lazy var showGridSwitch: UISwitch = {
        let switchView = UISwitch()
        switchView.addTarget(self, action: #selector(handleSwitchToggle(_:)), for: .valueChanged)
        switchView.tag = SettingsSwitch.showGrid.rawValue
        return switchView
    }()
    
    lazy var enableHapticsTableViewCell: UITableViewCell = {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
        cell.accessoryView = enableHapticsSwitch
        cell.textLabel?.text = "Vibrate"
        cell.selectionStyle = .none
        cell.imageView?.image = UIImage(named: "vibrate")
        cell.imageView?.autoSetDimension(.width, toSize: 26)
        cell.imageView?.autoSetDimension(.height, toSize: 26)
        cell.imageView?.autoAlignAxis(toSuperviewAxis: .horizontal)
        cell.imageView?.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
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
    
    func enableClearHighScoresOption(_ enable: Bool) {
        if let button = clearStateTableViewCell.viewWithTag(123) as? UIButton {
            button.isEnabled = enable
        }
    }
    
    func displaySettings(_ settings: Settings, showClearHighScores: Bool) {
        
        tableViewDefinitions = TableViewDefinitions()
        
        // GAME OPTIONS
        var section = 0
        tableViewDefinitions?.addSection(header: nil, footer: nil, rowCount: 2, at: section)
        tableViewDefinitions?.updateCell(showGridTableViewCell, indexPath: IndexPath(row:0, section: section))
        tableViewDefinitions?.updateCell(showGhostTableViewCell, indexPath: IndexPath(row:1, section: 0))
        
        // VIBRATION
        section += 1
        tableViewDefinitions?.addSection(header: nil, footer: "When turned on, phone will vibrate when you clear a row or make a match", rowCount: 1, at: section)
        tableViewDefinitions?.updateCell(enableHapticsTableViewCell, indexPath: IndexPath(row:0, section: section))
        
        // CLEAR HIGH SCORES
        if showClearHighScores {
            section += 1
            tableViewDefinitions?.addSection(header: nil, footer: "For when you want to forget those lucky high scores and start from scratch.", rowCount: 1, at: section)
            tableViewDefinitions?.updateCell(clearStateTableViewCell, indexPath: IndexPath(row:0, section: section))
        }
        self.tableView.reloadData()
        
        self.title = "Settings"
        self.view.backgroundColor = .white
        
        showGridSwitch.isOn = settings.showGrid
        showGhostSwitch.isOn = settings.showGhost
        enableHapticsSwitch.isOn = settings.enableHaptics
        
    }
    
    func displayTitle(_ title: String) {
        self.title = title
    }
}

extension SettingsView: UITableViewDelegate {
    
}

extension SettingsView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return tableViewDefinitions?.titleForFooter(section)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewDefinitions?.sectionCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewDefinitions?.titleForHeader(section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDefinitions?.rowsInSection(section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableViewDefinitions?.tableViewCellFor(indexPath) {
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
