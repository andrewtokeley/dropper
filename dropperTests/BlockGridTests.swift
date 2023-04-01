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
    
    func testAddingShapeWithDefaultReference() throws {
        
        let grid = try BlockGrid(rows: 10, columns: 10)
        
        // this will try and add the shape at (0,0) and should fail
        XCTAssertFalse(grid.addShape(Shape.L(.colour2)))
    
    }
    /**
     Standard initialisaton using string array
     */
    func testValidBlockGrid() throws {
        do {
            let grid = try BlockGrid([
                    ["  ", "  ", "S1", "s1", "S1", "S1", "  "],
                    ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                    ["  ", "  ", "  ", "  ", "  ", "  ", "  "]
                ])
            XCTAssertEqual(grid.rows, 3)
            XCTAssertEqual(grid.columns, 7)
            XCTAssertTrue(grid.hasShape)
            XCTAssertEqual(grid.shape?.origin, GridReference(2,3))
        } catch {
            XCTFail("Should have worked: " + error.localizedDescription)
        }
    }
    
    /**
     Each row must have the same number of columns
     */
    func testInvalidRaggedColumns() throws {
        XCTAssertThrowsError(try BlockGrid([
                ["  ", "  ", "S1", "s1", "S1", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  "]
            ]))
    }
    
    func testGetBlock() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "X1", "X2", "X3", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "S2", "S2", "  ", "  ", "  "],
                ["  ", "S2", "s2", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ])
        let result = grid.get(GridReference(6,3))
        XCTAssertNotNil(result.block)
        XCTAssertTrue(result.isInsideGrid)
        XCTAssertEqual(result.gridReference.row, 6)
        XCTAssertEqual(result.gridReference.column, 3)
        XCTAssertEqual(result.block?.colour, .colour2)
        XCTAssertEqual(result.block?.type, .block)
        
        XCTAssertEqual(grid.shape?.colours[0], .colour2)
        
    }
    
    func testGetAllIncludeShape() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "S1", "s1", "S1", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "XR", "  ", "  ", "  "],
                ["  ", "  ", "  ", "XB", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ])
        
        let blocksNoPlayer = grid.getAll(includeShape: false)
        XCTAssertEqual(blocksNoPlayer.count, 2)
        
        let blocksWithPlayer = grid.getAll(includeShape: true)
        XCTAssertEqual(blocksWithPlayer.count, 5)
        
    }
    
    func testGetAdjacent() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "X1", "X1", "X1", "  ", "  "],
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
        
        XCTAssertEqual(right.block?.colour, BlockColour.colour1)
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
        XCTAssertNil(adjacents.first(where: {$0.block?.colour != .colour4 }))
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
                ["X1", "  ", "  ", "  ", "  ", "  ", "  "],
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
                ["  ", "  ", "S1", "s1", "S1", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ])
        
        XCTAssertTrue(grid.moveShape(.right))
        XCTAssertTrue(grid.moveShape(.right))
        XCTAssertFalse(grid.moveShape(.right)) // hit the side
        
        XCTAssertEqual(grid.shape?.origin, GridReference(5,5))
                      
    }
    
    func testMovePlayerMoveLeft() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "S1", "s1", "S1", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ])
        
        XCTAssertTrue(grid.moveShape(.left))
        XCTAssertTrue(grid.moveShape(.left))
        XCTAssertFalse(grid.moveShape(.left)) // hit the side
                      
    }
    
    func testCanMovePlayerByOriginReference() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XY", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XR", "  ", "  "],
            ])
        
        // add a horizontal longBar to top
        let shape = Shape.I(.colour4)
        shape.move(GridReference(6,3))
        XCTAssertNotNil(grid.addShape(shape))
        
        XCTAssertFalse(grid.canMoveShape(GridReference(0,3))) // nope
        XCTAssertFalse(grid.canMoveShape(GridReference(0,4))) // nope
        XCTAssertFalse(grid.canMoveShape(GridReference(1,4))) // nope
        
        XCTAssertTrue(grid.canMoveShape(GridReference(2,4))) // yep
        XCTAssertTrue(grid.canMoveShape(GridReference(3,4))) // yep
        XCTAssertTrue(grid.canMoveShape(GridReference(2,3))) // yep
    }
    
    func testDoubleDropBug() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
            ])
        // add an longbar
        let shape = Shape.I(.random)
        shape.move(GridReference(6,4))
        XCTAssertTrue(grid.addShape(shape))
        let _ = grid.dropShape()
        
        // check block all the way down
        if let newOrigin = grid.shape?.origin {
            XCTAssertNotNil(newOrigin)
            XCTAssertEqual(newOrigin.row, 0)
        } else {
            XCTFail()
        }
    }
    
    func testPlayerCanDropTo() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "XY", "  ", "XY", "  ", "  "],
                ["  ", "  ", "XB", "  ", "XR", "  ", "  "],
            ])
        // add an I horizontal
        let shape = Shape.I(.colour4)
        shape.move(GridReference(6,3))
        XCTAssertTrue(grid.addShape(shape))
        XCTAssertTrue(grid.moveShape(.down))
        XCTAssertTrue(grid.moveShape(.down))
        XCTAssertTrue(grid.rotateShape())
        
        let dropTo = grid.shapeCanDropTo
        XCTAssertNotNil(dropTo)
        XCTAssertEqual(dropTo?.row, 2)
        XCTAssertEqual(dropTo?.column, grid.shape?.origin.column)
    }
    
    func testCanMovePlayer() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "S1", "s1", "S1", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "X1", "  ", "  "],
                ["  ", "  ", "  ", "  ", "X2", "  ", "  "],
                ["  ", "  ", "  ", "  ", "X3", "  ", "  "],
                ["  ", "  ", "  ", "  ", "X4", "  ", "  "],
            ])
        XCTAssertTrue(grid.canMoveShape(.down))
        XCTAssertTrue(grid.moveShape(.down))
        XCTAssertFalse(grid.canMoveShape(.down))
    }
    
    func testMovePlayerMoveDown() throws {
        
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "S1", "s1", "S1", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "X1", "  ", "  "],
                ["  ", "  ", "  ", "  ", "X2", "  ", "  "],
                ["  ", "  ", "  ", "  ", "X3", "  ", "  "],
                ["  ", "  ", "  ", "  ", "X4", "  ", "  "],
            ])
        
        XCTAssertTrue(grid.moveShape(.down))
        
        // Shape should have moved down
        XCTAssertEqual(grid.shape?.origin.row, 4)
    }
    
    func testMovePlayerToGround() throws {
        
        let grid = try! BlockGrid(
            rows: 7,
            columns: 7)
            
        // add play to (4,3)
        let shape = Shape.L(.colour2)
        shape.move(GridReference(4,3))
        if grid.addShape(shape) {
            
            XCTAssertNotNil(grid.shape)
            
            // drop to ground
            grid.dropShape()
            
            // check the lowest row of the player is 0
            let minRow = shape.references.min(by: { (a, b) in a.row < b.row})!.row
            
            XCTAssertEqual(minRow, 0)
            
        } else {
            
            XCTFail()
        }
        
    }
    
    func testMovePlayerOnTopOfBlocks() throws {
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "S1", "s1", "S1", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XY", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XB", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XY", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XR", "  ", "  "],
            ])
        
        // Should be abel to move once
        XCTAssertTrue(grid.moveShape(.down))
        
        // Should NOT be able to move past these blocks, because there's no match
        XCTAssertFalse(grid.moveShape(.down))
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
    func testAddPlayerFailsIfNoRoom() throws {
        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "XB", "XB", "  ", "  "],
                ["  ", "  ", "XY", "XB", "XR", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XR", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XR", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XY", "  ", "  "],
                ["  ", "  ", "  ", "  ", "XR", "  ", "  "],
            ])
        
        // add a L shape
        let shape = Shape.L(.colour4)
        shape.move(GridReference(4,3))
        XCTAssertFalse(grid.addShape(shape))
    }
        
    func testAddShapeWithColour() throws {
        let grid = try! BlockGrid(
            rows: 7,
            columns: 7)
        
        // add vertical 3 block player shape
        let shape = Shape.I(.colour4)
        shape.move(GridReference(4,3))
        if grid.addShape(shape) {
            let blocks = grid.shapeBlocks
            XCTAssertEqual(blocks[0].block?.colour, BlockColour.colour4)
            XCTAssertEqual(blocks[1].block?.colour, BlockColour.colour4)
            XCTAssertEqual(blocks[1].block?.colour, BlockColour.colour4)
        } else {
            XCTFail()
        }
    }
    
    func testRotateOPlayer() throws {
        let grid = try! BlockGrid(
            rows: 7,
            columns: 7)
        let shape = Shape.O(.colour4)
        shape.move(GridReference(5,3))
        if grid.addShape(shape) {
            XCTAssertTrue(grid.rotateShape())
        } else {
            XCTFail()
        }
        
    }
    
    func testRotate3Player() throws {
        
        let grid = try! BlockGrid(
            rows: 7,
            columns: 7)
        
        let shape = Shape.I(.colour4)
        shape.move(GridReference(4,3))
        if grid.addShape(shape) {
            // starts horizontal
            let shape = grid.shapeBlocks
            let row = shape[0].gridReference.row
            XCTAssertEqual(shape[1].gridReference.row, row)
            XCTAssertEqual(shape[2].gridReference.row, row)
            
            // move down a bit so it can rotate
            let _ = grid.moveShape(.down)
            let _ = grid.moveShape(.down)
            
            // After rotate becomes vertical
            XCTAssertTrue(grid.rotateShape())
            let newShape = grid.shape!.references
            let column = newShape[0].column
            XCTAssertEqual(newShape[1].column, column)
            XCTAssertEqual(newShape[2].column, column)
            
        } else {
            XCTFail()
        }
    }
    
    func testWallKick2() throws {

        let grid = try! BlockGrid([
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "  ", "  ", "  ", "  ", "  ", "  "],
                ["  ", "S1", "S1", "  ", "  ", "  ", "  "],
                ["S1", "s1", "  ", "XB", "  ", "  ", "  "],
                ["  ", "  ", "XB", "  ", "  ", "  ", "  "],
                ["  ", "XB", "XB", "  ", "  ", "  ", "  "],
                ["  ", "XB", "  ", "  ", "  ", "  ", "  "],
            ])
        
//        let shape = Shape.S(.colour1)
//        shape.move(GridReference(3, 1))
//        let result = try! grid.addShape(shape)
//        XCTAssertTrue(result)
        XCTAssertTrue(grid.rotateShape())
    }

}
