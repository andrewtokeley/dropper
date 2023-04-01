//
//  ShapeTests.swift
//  dropperTests
//
//  Created by Andrew Tokeley on 1/04/23.
//

import XCTest
@testable import dropper

final class ShapeTests: XCTestCase {

    func testShapeMove() throws {
        let shape = Shape.L(.colour1)
        
        XCTAssertEqual(shape.origin, GridReference.zero)
        
        // Move it
        shape.move(GridReference(10,10))
        XCTAssertEqual(shape.origin, GridReference(10,10))
        
        XCTAssertTrue(shape.references.contains(GridReference(10,9)))
        XCTAssertTrue(shape.references.contains(GridReference(10,10)))
        XCTAssertTrue(shape.references.contains(GridReference(10,11)))
        XCTAssertTrue(shape.references.contains(GridReference(11,11)))
                                                  
    }
    
    func testRotate() throws {
        let shape = Shape.L(.colour1)
        
        XCTAssertEqual(shape.origin, GridReference.zero)
        XCTAssertEqual(shape.orientation, .up)
        
        // Move it
        shape.move(GridReference(10,10))
        
        // Rotate once clockwise
        shape.rotate()
        
        XCTAssertEqual(shape.orientation, .right)
        
        XCTAssertTrue(shape.references.contains(GridReference(9,10)))
        XCTAssertTrue(shape.references.contains(GridReference(9,11)))
        XCTAssertTrue(shape.references.contains(GridReference(10,10)))
        XCTAssertTrue(shape.references.contains(GridReference(11,10)))
    }
    
    func testOrientation() throws {
        let shape = Shape.L(.colour1)
        
        XCTAssertEqual(shape.orientation, .up)
        shape.rotate()
        XCTAssertEqual(shape.orientation, .right)
        shape.rotate()
        XCTAssertEqual(shape.orientation, .down)
        shape.rotate()
        XCTAssertEqual(shape.orientation, .left)
        shape.rotate()
        XCTAssertEqual(shape.orientation, .up)
    }
    
    func testRotateWithKick() throws {
        let shape = Shape.L(.colour1)
        
        XCTAssertEqual(shape.origin, GridReference.zero)
        
        // Rotate once clockwise, but kick it first
        shape.rotate(with: GridOffset(10,10))
        
        XCTAssertTrue(shape.references.contains(GridReference(9,10)))
        XCTAssertTrue(shape.references.contains(GridReference(9,11)))
        XCTAssertTrue(shape.references.contains(GridReference(10,10)))
        XCTAssertTrue(shape.references.contains(GridReference(11,10)))
                                                  
    }

    func testRotateReferencesWithKick() throws {
        let shape = Shape.L(.colour1)
        
        XCTAssertEqual(shape.origin, GridReference.zero)
        
        // Get where the rotation would take the shape with a kick
        let references = shape.getRotationWithKick(GridOffset(10,10))
        
        XCTAssertTrue(references.contains(GridReference(9,10)))
        XCTAssertTrue(references.contains(GridReference(9,11)))
        XCTAssertTrue(references.contains(GridReference(10,10)))
        XCTAssertTrue(references.contains(GridReference(11,10)))
        
        // original shape hasn't moved
        XCTAssertEqual(shape.origin, GridReference.zero)
                                                  
    }
    
    func testOrigin() {
        let shape = Shape.L(.colour4)
        shape.move(GridReference(3,3))
        XCTAssertEqual(shape.origin, GridReference(3,3))
    }
}
