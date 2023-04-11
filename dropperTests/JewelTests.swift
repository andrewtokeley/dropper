//
//  JewelTests.swift
//  dropperTests
//
//  Created by Andrew Tokeley on 9/04/23.
//

import XCTest
@testable import dropper

final class JewelTests: XCTestCase {

    let gameService = ServiceFactory.sharedInstance.gameService
    
    func testJewelPoints() throws {
        
        // in the current level you've removed 10 rows
        let levelAchievements = Achievements.zero
        levelAchievements.addTo(.oneRow, 3)
        
        // then you removed a row with a jewel
        let moveAchievements = Achievements.zero
        moveAchievements.addTo(.oneRow, 1)
        moveAchievements.addTo(.jewel, 1)
        
        // first level
        let level = JewelLevel(1)
        
        let points = level.pointsFor(
            moveAchievements: moveAchievements,
            levelAchievements: levelAchievements)
        
        // 500 + 1000 - 200
        XCTAssertEqual(points,1300)
    }

    func testAddJewel() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "J1", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ])
        
        let jewel = grid.get(GridReference(4,3)).block
        XCTAssertNotNil(jewel)
        XCTAssertTrue(jewel?.type == .jewel)
    }

    func testJewelActsAsBlock() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "S1", "s1", "S1", "  ", "  "],
                ["  ", "  ", "  ", "J1", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ])
        
        XCTAssertFalse(grid.moveShape(.down))
    }
    
    func testShapeStoppedByJewelWhenDropped() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "S1", "s1", "S1", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "J1", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ])
        
        grid.dropShape()
        XCTAssertEqual(grid.shape?.origin.row, 3)
    }
}
