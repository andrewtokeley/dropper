//
//  RemoveMatchedBlocksEffectTests.swift
//  dropperTests
//
//  Created by Andrew Tokeley on 25/02/23.
//

import XCTest
@testable import dropper

class RemoveMatchedBlocksEffectTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSingleMatchRemoved() throws {
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "XR", "XR", "XR", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ])
        
        let effect = RemoveMatchedBlocksEffect(grid: grid)
        XCTAssertTrue(effect.apply())
        
        // there should be no blocks left
        XCTAssertEqual(grid.getAll().count, 0)
    }
    
    func testSingleMatch() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "XR", "XR", "XR", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ])
        
        let effect = RemoveMatchedBlocksEffect(grid: grid)
        let groups = effect.findConnectedGroups(grid: grid)
        
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups[0].count, 3)
    }
    
    func testMatchMultiple() throws {
        
        let grid = try! BlockGrid([
                ["XR", "XR", "  ", "  ", "  ", "  ", "  "],
                ["XR", "XR", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "XR", "XR", "XR", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["XR", "XR", "XR", "XR", "  ", "  ", "  "],
            ])
        
        let effect = RemoveMatchedBlocksEffect(grid: grid)
        let groups = effect.findConnectedGroups(grid: grid)
        
        XCTAssertEqual(groups.count, 3)
        XCTAssertEqual(groups[0].count + groups[1].count + groups[2].count, 11)
    }
    
    func testMatchMultipleColours() throws {
        
        let grid = try! BlockGrid([
                ["XR", "XR", "  ", "  ", "  ", "  ", "  "],
                ["XR", "XR", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "XB", "XB", "XB", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["XY", "XY", "XY", "XY", "  ", "  ", "  "],
            ])
        
        let effect = RemoveMatchedBlocksEffect(grid: grid)
        let groups = effect.findConnectedGroups(grid: grid)
        
        XCTAssertEqual(groups.count, 3)
        XCTAssertEqual(groups[0].count + groups[1].count + groups[2].count, 11)
    }

    func testSingleComplexShape() throws {
        
        let grid = try! BlockGrid([
                ["XR", "XR", "  ", "  ", "  ", "  ", "  "],
                ["XR", "XR", "  ", "  ", "  ", "  ", "  "],
                ["  ", "XR", "  ", "  ", "  ", "  ", "  "],
                ["  ", "XR", "XR", "XR", "XR", "  ", "  "],
                ["  ", "  ", "XR", "  ", "  ", "  ", "  "],
                ["  ", "  ", "XR", "  ", "  ", "  ", "  "],
                ["XR", "XR", "XR", "XR", "  ", "  ", "  "],
            ])
        
        let effect = RemoveMatchedBlocksEffect(grid: grid)
        let groups = effect.findConnectedGroups(grid: grid)
        
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups[0].count, 15)
    }
    
    func testGreaterThanThreeOnly() throws {
        
        let grid = try! BlockGrid([
                ["XR", "XR", "  ", "  ", "  ", "  ", "  "],
                ["XR", "XR", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "XB", "XB", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["XY", "XY", "XY", "XY", "  ", "  ", "  "],
            ])
        
        let effect = RemoveMatchedBlocksEffect(grid: grid, minimumMatchCount: 3)
        let groups = effect.findConnectedGroups(grid: grid)
        
        XCTAssertEqual(groups.count, 2)
        XCTAssertEqual(groups[0].count + groups[1].count, 8)
    }
}
