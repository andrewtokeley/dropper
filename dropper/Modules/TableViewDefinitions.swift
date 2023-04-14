//
//  TableViewDefinitions.swift
//  dropper
//
//  Created by Andrew Tokeley on 11/04/23.
//

import Foundation
import UIKit

class TableViewDefinitions {
    
    var sectionRowCounts = [Int]()
    var sectionHeaders = [String?]()
    var sectionFooters = [String?]()
    var tableViewCells: [IndexPath: UITableViewCell] = [:]
    
    func addSection(header: String?, footer: String?, rowCount: Int, at: Int) {
        self.sectionHeaders.insert(header, at: at)
        self.sectionFooters.insert(footer, at: at)
        self.sectionRowCounts.insert(rowCount, at: at)
    }
        
    func addRows(for section: Int, cells: [UITableViewCell]) {
        for row in 0..<cells.count {
            tableViewCells[IndexPath(row: row, section: section)] = cells[row]
        }
    }
    
    func updateCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        tableViewCells[indexPath] = cell
    }
    
    func enableCell(_ cell: UITableViewCell, enable: Bool) {
        let cell = tableViewCells.first { (key: IndexPath, value: UITableViewCell) in
            return value == cell
        }
        
        // TODO - remember original style
        cell?.value.selectionStyle = enable ? .default : .none
    }
    
    var sectionCount: Int {
        return sectionRowCounts.count
    }

    func rowsInSection(_ section: Int) -> Int {
        guard section < sectionRowCounts.count else { return 0 }
        return sectionRowCounts[section]
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
