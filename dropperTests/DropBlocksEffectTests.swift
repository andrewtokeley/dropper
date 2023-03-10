//
//  DropBlocksEffectTests.swift
//  dropperTests
//
//  Created by Andrew Tokeley on 26/02/23.
//

import XCTest
@testable import dropper

class DropBlocksEffectTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDropMulitple() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "XR", "XY", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "XB", "  ", "  ", "  "],
            ])
        
        let effect = DropBlocksEffect(grid: grid)
        XCTAssertTrue(effect.apply()) // on move drop, XR and XY will drop
        XCTAssertFalse(effect.apply()) // nothing will drop
        
        XCTAssertEqual(grid.get(GridReference(0, 3)).block?.colour, .blue)
        XCTAssertEqual(grid.get(GridReference(0, 4)).block?.colour, .yellow)
        XCTAssertEqual(grid.get(GridReference(1, 3)).block?.colour, .red)
        
    }

    func testDropBlocksWithWall() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "XR", "XY", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XX", "  ", "  "],
                ["  ", "  ", "  ", "XB", "  ", "  ", "  "],
            ])
        
        let effect = DropBlocksEffect(grid: grid)
        XCTAssertTrue(effect.apply())
        
        
        // check XR has moved one space
        XCTAssertNil(grid.get(GridReference(2, 3)).block)
        XCTAssertEqual(grid.get(GridReference(1, 3)).block?.colour, .red)
        
        // check XY didn't move at all because of the wall
        XCTAssertNotNil(grid.get(GridReference(2, 4)).block)
        
        
    }
    
    func testDropWithPlayer() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "XR", "XY", "  ", "  "],
                ["  ", "  ", "  ", "  ", "PR", "PR", "PR"],
                ["  ", "  ", "  ", "XB", "  ", "XB", "  "],
            ])
        
        let effect = DropBlocksEffect(grid: grid)
        XCTAssertTrue(effect.apply())
        
        // check XY didn't move at all because of the player
        XCTAssertNotNil(grid.get(GridReference(2, 4)).block)
        
        // check player didn't drop
        XCTAssertNil(grid.get(GridReference(0, 4)).block)
    }
}