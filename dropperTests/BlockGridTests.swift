//
//  BlockGrid.swift
//  dropperTests
//
//  Created by Andrew Tokeley on 19/02/23.
//

import XCTest
@testable import dropper

class BlockGridTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /**
     Standard initialisaton using string array
     */
    func testValidBlockGrid() throws {
        do {
            let grid = try BlockGrid([
                    ["  ", "  ", "PY", "PB", "PR", "  ", "  "],
                    ["  ", "  ", "  ", "  ", "  ", "  ", "  "]
                ])
            XCTAssertEqual(grid.rows, 2)
            XCTAssertEqual(grid.columns, 7)
        } catch {
            XCTFail("Should have worked")
        }
    }
    
    /**
     Each row must have the same number of columns
     */
    func testInvalidRaggedColumns() throws {
        XCTAssertThrowsError(try BlockGrid([
                ["  ", "  ", "PY", "PB", "PR", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  "]
            ]))
    }
    
    func testGetBlock() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "PY", "PB", "PR", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ])
        let result = grid.get(GridReference(6,2))
        XCTAssertNotNil(result.block)
        XCTAssertTrue(result.isInsideGrid)
        XCTAssertEqual(result.gridReference.row, 6)
        XCTAssertEqual(result.gridReference.column, 2)
        XCTAssertEqual(result.block?.colour, .yellow)
        XCTAssertEqual(result.block?.type, .player)
        
        let result2 = grid.get(GridReference(6,3))
        XCTAssertEqual(result2.block?.colour, .blue)
        XCTAssertEqual(result2.block?.type, .player)
        
        XCTAssertNil(grid.get(GridReference(0,0)).block)
        XCTAssertNil(grid.get(GridReference(6,6)).block)
        XCTAssertNil(grid.get(GridReference(60,60)).block)
        
    }
    
    func testGetAllIncludePlayer() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "PY", "PB", "PR", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "XR", "  ", "  ", "  "],
                ["  ", "  ", "  ", "XB", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ])
        
        let blocksNoPlayer = grid.getAll(excludePlayer: true)
        XCTAssertEqual(blocksNoPlayer.count, 2)
        
        let blocksWithPlayer = grid.getAll(excludePlayer: false)
        XCTAssertEqual(blocksWithPlayer.count, 5)
        
    }
    
    func testGetAdjacent() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "PY", "PB", "PR", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ])
        
        let left = grid.adjacent(GridReference(6,2), .left)
        let right = grid.adjacent(GridReference(6,2), .right)
        let top = grid.adjacent(GridReference(6,2), .top)
        let bottom = grid.adjacent(GridReference(6,2), .bottom)
        
        XCTAssertEqual(left.block, nil)
        XCTAssertEqual(left.isInsideGrid, true)
        
        XCTAssertEqual(right.block?.colour, BlockColour.blue)
        XCTAssertEqual(right.isInsideGrid, true)
        
        XCTAssertEqual(top.block, nil)
        XCTAssertEqual(top.isInsideGrid, false)
        
        XCTAssertEqual(bottom.block, nil)
        XCTAssertEqual(bottom.isInsideGrid, true)
    }
    
    func testGetAllAdjacent() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "XB", "  ", "  ", "  "],
                ["  ", "  ", "XB", "XY", "XB", "  ", "  "],
                ["  ", "  ", "  ", "XB", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ])
        
        let adjacents = grid.adjacent(GridReference(4, 3))
        
        XCTAssertEqual(adjacents.count, 4)
        XCTAssertNil(adjacents.first(where: {$0.block == nil }))
        XCTAssertNil(adjacents.first(where: {$0.block?.colour != .blue }))
//        let left = grid.get(GridReference(4,2))
//        XCTAssertEqual(left.block?.colour, .yellow)
//        XCTAssertEqual(left.isInsideGrid, true)
        
    }
    
    func testGetColumnGaps() throws {
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "XB", "  ", "  ", "  "],
                ["XB", "  ", "  ", "XB", "  ", "  ", "  "],
                ["  ", "  ", "  ", "XB", "  ", "  ", "  "],
                ["XB", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "XB", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "XB", "  ", "  ", "  ", "  "],
            ])
        
        var gaps = grid.getColumnGaps(0)
        XCTAssertEqual(gaps.count, 2)
        XCTAssertEqual(gaps[0].start.row, 0)
        XCTAssertEqual(gaps[0].end.row, 1)
        XCTAssertEqual(gaps[0].length, 2)
        XCTAssertEqual(gaps[1].start.row, 3)
        XCTAssertEqual(gaps[1].end.row, 3)
        XCTAssertEqual(gaps[1].length, 1)
        
        gaps = grid.getColumnGaps(1)
        XCTAssertEqual(gaps.count, 1)
        XCTAssertEqual(gaps[0].start.row, 0)
        XCTAssertEqual(gaps[0].end.row, 0)
        XCTAssertEqual(gaps[0].length, 1)
        
        gaps = grid.getColumnGaps(2)
        XCTAssertEqual(gaps.count, 0)

        gaps = grid.getColumnGaps(3)
        XCTAssertEqual(gaps.count, 1)
        XCTAssertEqual(gaps[0].start.row, 0)
        XCTAssertEqual(gaps[0].end.row, 2)
        XCTAssertEqual(gaps[0].length, 3)
        
        gaps = grid.getColumnGaps(4)
        XCTAssertEqual(gaps.count, 0)
    }
    
    func testMoveBlock() throws {
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["PY", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ])
        
        // Down (Can)
        XCTAssertTrue(grid.moveBlock(from: GridReference(4,0), direction: .down))
        XCTAssertNil(grid.get(GridReference(4,0)).block)
        XCTAssertNotNil(grid.get(GridReference(3,0)).block)
        
        // Left (Can't)
        XCTAssertFalse(grid.moveBlock(from: GridReference(3,0), direction: .left))
        XCTAssertNotNil(grid.get(GridReference(3,0)).block)
        
        // Right (Can)
        XCTAssertTrue(grid.moveBlock(from: GridReference(3,0), direction: .right))
        XCTAssertNil(grid.get(GridReference(3,0)).block)
        XCTAssertNotNil(grid.get(GridReference(3,1)).block)
    }
    
    func testMovePlayerMoveRight() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "PY", "PB", "PR", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ])
        
        XCTAssertTrue(grid.movePlayer(.right))
        XCTAssertTrue(grid.movePlayer(.right))
        XCTAssertFalse(grid.movePlayer(.right)) // hit the side
        
        XCTAssertNotNil(grid.get(GridReference(5, 6)).block)
        XCTAssertNotNil(grid.get(GridReference(5, 5)).block)
        XCTAssertNotNil(grid.get(GridReference(5, 4)).block)
                      
    }
    
    func testMovePlayerMoveLeft() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "PY", "PB", "PR", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ])
        
        XCTAssertTrue(grid.movePlayer(.left))
        XCTAssertTrue(grid.movePlayer(.left))
        XCTAssertFalse(grid.movePlayer(.left)) // hit the side
                      
    }
    
    func testCanMovePlayer() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "PY", "PB", "PR", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XY", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XB", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XY", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XR", "  ", "  "],
            ])
        XCTAssertTrue(grid.canMovePlayer(.down))
        XCTAssertTrue(grid.movePlayer(.down))
        XCTAssertFalse(grid.canMovePlayer(.down))
    }
    
    func testMovePlayerMoveDown() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "PY", "PB", "PR", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XY", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XB", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XY", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XR", "  ", "  "],
            ])
        
        XCTAssertTrue(grid.movePlayer(.down))
        
        // PY should have moved down
        XCTAssertNil(grid.get(GridReference(5,2)).block)
        XCTAssertEqual(grid.get(GridReference(4,2)).block?.type, .player)
        XCTAssertEqual(grid.get(GridReference(4,2)).block?.colour, .yellow)
        
        // PB should have moved down
        XCTAssertNil(grid.get(GridReference(5,3)).block)
        XCTAssertEqual(grid.get(GridReference(4,3)).block?.type, .player)
        XCTAssertEqual(grid.get(GridReference(4,3)).block?.colour, .blue)
        
        // PR should have moved down
        XCTAssertNil(grid.get(GridReference(5,4)).block)
        XCTAssertEqual(grid.get(GridReference(4,4)).block?.type, .player)
        XCTAssertEqual(grid.get(GridReference(4,4)).block?.colour, .red)
        
    }
    
    func testMovePlayerMoveDown2() throws {
        
        let grid = try! BlockGrid([
                ["PY", "PY", "PB", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ])
        
        XCTAssertTrue(grid.movePlayer(.down))

        XCTAssertEqual(grid.get(GridReference(5, 2)).block?.type, .player)
        XCTAssertEqual(grid.get(GridReference(5, 1)).block?.type, .player)
        XCTAssertEqual(grid.get(GridReference(5, 0)).block?.type, .player)
        XCTAssertNil(grid.get(GridReference(6, 0)).block)
    }
    
    func testMovePlayerToGround() throws {
        
        let grid = try! BlockGrid(
            rows: 7,
            columns: 7)
            
        // add play to (4,3)
        if let _ = try? grid.addPlayer(Shape.elbow(.red)) {
            
            XCTAssertTrue(grid.hasPlayer)
            
            // drop to ground
            grid.dropPlayer()
            
            // check the lowest row of the player is 0
            let references = grid.playerBlocks.map { $0.gridReference }
            let minRow = references.min(by: { (a, b) in a.row < b.row})!.row
            
            XCTAssertEqual(minRow, 0)
            
        } else {
            
            XCTFail()
        }
        
    }
    
    func testMovePlayerOnTopOfBlocks() throws {
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "PY", "PB", "PR", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XY", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XB", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XY", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XR", "  ", "  "],
            ])
        
        // Should be abel to move once
        XCTAssertTrue(grid.movePlayer(.down))
        
        // Should NOT be able to move past these blocks, because there's no match
        XCTAssertFalse(grid.movePlayer(.down))
    }
    
//    func testMoveAndSplitPlayer() throws {
//        let grid = try! BlockGrid([
//                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
//                ["  ", "  ", "PY", "PB", "PR", "  ", "  "],
//                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
//                ["  ", "  ", "  ", "  ", "XR", "  ", "  "],
//                ["  ", "  ", "  ", "  ", "XR", "  ", "  "],
//                ["  ", "  ", "  ", "  ", "XY", "  ", "  "],
//                ["  ", "  ", "  ", "  ", "XR", "  ", "  "],
//            ])
//        
//        // Should be able to move once
//        XCTAssertEqual(grid.playerBlocks.count, 3)
//        XCTAssertTrue(grid.movePlayer(.down))
//        
//        // Since the red player blocks will match the red blocks, it will split to be only two blocks and be able to keep moving down
//        
//        // Check something was removed
//        let removeMatchesEffect = RemoveMatchedBlocksEffect(grid: grid)
//        XCTAssertTrue(removeMatchesEffect.apply())
//
//        // That only two player blocks are left and it can move down further
//        XCTAssertEqual(grid.playerBlocks.count, 2)
//        XCTAssertTrue(grid.movePlayer(.down))
//        
//    }
//    
    func testAddPlayerOrigin() throws {
        let grid = try! BlockGrid(
            rows: 7,
            columns: 7)
        
        // add a L shape
        if let _ = try? grid.addPlayer(Shape.bucket(.blue)) {
            XCTAssertNotNil(grid.playerOrigin)
        } else {
            XCTFail()
        }
    }
    
    func testAddPlayerWithColour() throws {
        let grid = try! BlockGrid(
            rows: 7,
            columns: 7)
        
        // add vertical 3 block player shape
        if let _ = try? grid.addPlayer(Shape.longBar(.blue)) {
            let blocks = grid.playerBlocks
            XCTAssertEqual(blocks[0].block?.colour, BlockColour.blue)
            XCTAssertEqual(blocks[1].block?.colour, BlockColour.blue)
            XCTAssertEqual(blocks[1].block?.colour, BlockColour.blue)
        } else {
            XCTFail()
        }
    }
    
    func testRotateUPlayer() throws {
        let grid = try! BlockGrid(
            rows: 7,
            columns: 7)
            
        if let _ = try? grid.addPlayer(Shape.bucket(.blue)) {
            XCTAssertTrue(grid.rotatePlayer())
            
        } else {
            XCTFail()
        }
        
    }
    
    func testRotate3Player() throws {
        
        let grid = try! BlockGrid(
            rows: 7,
            columns: 7)
            
        if let _ = try? grid.addPlayer(Shape.longBar(.blue)) {
            // starts vertical
            let player = grid.playerBlocks
            let column = player[0].gridReference.column
            XCTAssertEqual(player[1].gridReference.column, column)
            XCTAssertEqual(player[2].gridReference.column, column)
            
            // After rotate becomes horizontal
            XCTAssertTrue(grid.rotatePlayer())
            let newPlayer = grid.playerBlocks.map { $0.gridReference }
            let row = newPlayer[0].row
            XCTAssertEqual(newPlayer[1].row, row)
            XCTAssertEqual(newPlayer[2].row, row)
            
        } else {
            XCTFail()
        }
    }
}
