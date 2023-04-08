//
//  GridView.swift
//  dropper
//
//  Created by Andrew Tokeley on 6/04/23.
//

import Foundation
import UIKit

/**
 Provides a visualisation of a grid with blocks - used for hero images. Doesn't actually play the game.
 */
class GridView: UIView {
    
    private(set) var grid: BlockGrid
    private(set) var gridLinesColour: UIColor
    private var blockViews: [[UIView?]]
    private var highlighted: [GridReference]?
    
    // MARK: - Initialisers
    
    init(_ grid: BlockGrid, gridLinesColour: UIColor, highlighted: [GridReference]?) {
        self.grid = grid
        self.gridLinesColour = gridLinesColour
        self.blockViews = Array(repeating: Array(repeating: nil, count: grid.columns), count: grid.rows)
        self.highlighted = highlighted
        
        super.init(frame: CGRect.zero)

        self.backgroundColor = UIColor.clear
        self.buildView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Build View
    
    private func getBlock(_ colour: BlockColour?) -> UIView {
        let view = UIView()
        view.layer.borderWidth = 0
        if let colour = colour {
            view.backgroundColor = UIColor.from(colour)
        } else {
            view.backgroundColor = UIColor.clear
        }
        return view
                          
    }
    
    private lazy var rowsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillEqually
        return view
    }()
    
    private func getStackViewForRow(_ row: Int) -> UIStackView {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        for column in 0..<grid.columns {
            let blockView = getBlock(grid.blocks[row][column]?.colour)
            blockViews[row][column] = blockView
            stackView.addArrangedSubview(blockView)
        }
        return stackView
    }
    
    func buildView() {
        for r in 0..<grid.rows {
            rowsStackView.insertArrangedSubview(getStackViewForRow(r), at: 0)
        }
        self.addSubview(rowsStackView)
        rowsStackView.autoPinEdgesToSuperviewEdges()
            
    }
    
    func highlightBlocks(_ range: GridRange) {
        highlightBlocks(range.references)
    }
    
    func highlightBlocks(_ references: [GridReference]) {
        for reference in references {
            
            let top = grid.get(reference.adjacent(.top)).gridReference
            var topBlock: UIView?
            if top.row < grid.rows {
                topBlock = self.blockViews[top.row][top.column]
            }
            
            let right = grid.get(reference.adjacent(.right)).gridReference
            var rightBlock: UIView?
            if right.column < grid.columns {
                rightBlock = self.blockViews[right.row][right.column]
            }
            
            let bottom = grid.get(reference.adjacent(.bottom)).gridReference
            var bottomBlock: UIView?
            if bottom.row >= 0 {
                bottomBlock = self.blockViews[bottom.row][bottom.column]
            }
            
            let left = grid.get(reference.adjacent(.left)).gridReference
            var leftBlock: UIView?
            if left.column >= 0 {
                leftBlock = self.blockViews[left.row][left.column]
            }
            
            if let block = self.blockViews[reference.row][reference.column] {

                // redo the current borders on the new layer
                if !references.contains(top) {
                    block.addBorder(toSide: .top, withColor: .white, andThickness: 3)
                    topBlock?.addBorder(toSide: .bottom, withColor: .white, andThickness: 3)
                }
                if !references.contains(right) {
                    block.addBorder(toSide: .right, withColor: .white, andThickness: 3)
                    rightBlock?.addBorder(toSide: .left, withColor: .white, andThickness: 3)
                }
                if !references.contains(bottom) {
                    block.addBorder(toSide: .bottom, withColor: .white, andThickness: 3)
                    bottomBlock?.addBorder(toSide: .top, withColor: .white, andThickness: 3)
                }
                if !references.contains(left) {
                    block.addBorder(toSide: .left, withColor: .white, andThickness: 3)
                    leftBlock?.addBorder(toSide: .right, withColor: .white, andThickness: 3)
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        // Force the UIStackView to layout, in order to get the updated width.
        rowsStackView.layoutIfNeeded()

        for r in 0..<blockViews.count {
            for c in 0..<blockViews[r].count {
                blockViews[r][c]?.addBorder(
                    toSides: [.left, .bottom, .right, .top],
                    withColor: self.gridLinesColour,
                    andThickness: 1)
            }
        }
        
        if let highlighted = self.highlighted {
            highlightBlocks(highlighted)
        }
    }
    
}
