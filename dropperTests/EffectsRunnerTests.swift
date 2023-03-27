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
                ["XB", "XB", "XY", "  ", "XR", "  ", "XY"],
                ["XB", "XB", "XY", "XR", "XR", "XB", "XY"],
                ["XB", "XB", "XY", "  ", "XR", "  ", "XY"],
            ])
        
        let runner = EffectsRunner(grid: grid, effects: [
            RemoveRowsEffect(),
            DropBlocksEffect(),
            RemoveMatchedBlocksEffect(minimumMatchCount: 3)
        ])

        // because we haven't defined the runner.applyEffectsToView method, this call will return synchronously, once all the grid effects have been applied
        runner.applyEffects()
        
        
        XCTAssertEqual(runner.achievements.get(.oneRow), 1)
        // 7 for the row and another 4 from the XB colour matches
        XCTAssertEqual(runner.achievements.get(.explodedBlock), 11)
        
//        let effect1 = RemoveRowsEffect(grid: grid)
//        let result1 = effect1.apply()
//        XCTAssertTrue(result1.isMaterial)
//        XCTAssertEqual(result1.achievments.get(.oneRow), 1)
//        let effect11 = DropBlocksEffect(grid: grid)
//        let _ = effect11.apply()
//
//        let effect2 = RemoveMatchedBlocksEffect(grid: grid, minimumMatchCount: 3)
//        let result2 = effect2.apply()
//        XCTAssertTrue(result2.isMaterial)
//        XCTAssertEqual(result2.achievments.get(.explodedBlock), 4)
//
//        // there should be no blocks left
//        XCTAssertEqual(grid.getAll().count, 6)
    }
}
