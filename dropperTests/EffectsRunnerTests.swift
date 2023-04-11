//
//  File.swift
//  dropperTests
//
//  Created by Andrew Tokeley on 13/03/23.
//

import Foundation

import XCTest
@testable import dropper

class EffectsRunnerTests: XCTestCase {
    
    func testMergedAchievements() throws {
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["X2", "X1", "X3", "  ", "X2", "  ", "X1"],
                ["X1", "X2", "X3", "X2", "X2", "X2", "X1"],
                ["X1", "X1", "X1", "  ", "X2", "  ", "X2"],
            ])
        
        let runner = EffectsRunner(grid: grid, effects: [
            RemoveRowsEffect(),
            DropIntoEmptyRowsEffect(),
        ])

        runner.applyEffects()
        
        XCTAssertEqual(grid.getAll().count, 10)

    }
}
