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

    func testNoMatchesRemoved() throws {
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "XR", "XY", "XR", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ])
        
        let effect = RemoveMatchedBlocksEffect(minimumMatchCount: 3)
        let result = effect.apply(grid)
        
        XCTAssertFalse(result.isMaterial)
        
        // there should be no blocks left
        XCTAssertEqual(grid.getAll().count, 3)
    }
    
    func testMatch10Achievement() throws {
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "XR", "  ", "  ", "  "],
                ["  ", "  ", "XR", "XR", "XR", "  ", "  "],
                ["  ", "  ", "XR", "XR", "XR", "  ", "  "],
                ["  ", "  ", "  ", "XR", "XR", "  ", "  "],
                ["  ", "  ", "  ", "XR", "XR", "  ", "  "],
            ])
        
        let effect = RemoveMatchedBlocksEffect(minimumMatchCount: 10)
        let result = effect.apply(grid)
        
        XCTAssertTrue(result.isMaterial)
        XCTAssertEqual(result.achievments.get(.match10), 1)
        
        // there should be no blocks left
        XCTAssertEqual(grid.getAll().count, 0)
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
        
        let effect = RemoveMatchedBlocksEffect(minimumMatchCount: 3)
        let result = effect.apply(grid)
        
        XCTAssertTrue(result.isMaterial)
        XCTAssertEqual(result.blocksRemoved.count, 3)
        
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
        
        let effect = RemoveMatchedBlocksEffect()
        let groups = effect.findConnectedGroups(grid: grid, minimumMatchCount: 3)
        
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
        
        let effect = RemoveMatchedBlocksEffect()
        let groups = effect.findConnectedGroups(grid: grid, minimumMatchCount: 3)
        
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
        
        let effect = RemoveMatchedBlocksEffect()
        let groups = effect.findConnectedGroups(grid: grid, minimumMatchCount: 3)
        
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
        
        let effect = RemoveMatchedBlocksEffect()
        let groups = effect.findConnectedGroups(grid: grid, minimumMatchCount: 3)
        
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
        
        let effect = RemoveMatchedBlocksEffect(minimumMatchCount: 3)
        let groups = effect.findConnectedGroups(grid: grid, minimumMatchCount: 3)
        
        XCTAssertEqual(groups.count, 2)
        XCTAssertEqual(groups[0].count + groups[1].count, 8)
    }
}
