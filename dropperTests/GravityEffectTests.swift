//
//  GravityEffectTests.swift
//  dropperTests
//
//  Created by Andrew Tokeley on 9/04/23.
//

import XCTest
@testable import dropper

final class GravityEffectTests: XCTestCase {

    func testGravityAllBlocks() throws {
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "X2", "  ", "  ", "  ", "  "],
                ["  ", "  ", "X2", "X2", "X4", "X2", "X2"],
                ["X1", "  ", "  ", "X2", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "]
            ])
        
        let effect = GravityEffect()
        let result = effect.apply(grid)
        XCTAssertEqual(result.blocksRemoved.count, 0)
        XCTAssertEqual(result.blocksMoved.count, 8)
        
        let row = grid.getRow(0)
        XCTAssertEqual(row[0].block?.type, .block)
        XCTAssertEqual(row[2].block?.type, .block)
        XCTAssertEqual(row[3].block?.type, .block)
        XCTAssertEqual(row[4].block?.type, .block)
        XCTAssertEqual(row[5].block?.type, .block)
        XCTAssertEqual(row[5].block?.type, .block)
        
    }
    
    func testGravityWithJewels() throws {
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "X2", "  ", "J2", "  ", "  "],
                ["  ", "  ", "J2", "X2", "X4", "X2", "X2"],
                ["X1", "  ", "  ", "X2", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "]
            ])
        
        let effect = GravityEffect()
        let result = effect.apply(grid)
        XCTAssertEqual(result.blocksMoved.count, 6)
        
        let row = grid.getRow(0)
        XCTAssertNotNil(row[0].block)
        XCTAssertNil(row[1].block)
        XCTAssertNil(row[2].block)
        XCTAssertNotNil(row[3].block)
        XCTAssertNotNil(row[4].block)
        XCTAssertNotNil(row[5].block)
        XCTAssertNotNil(row[6].block)
        
    }
}
