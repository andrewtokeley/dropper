//
//  AchievementsTests.swift
//  dropperTests
//
//  Created by Andrew Tokeley on 13/03/23.
//

import XCTest
@testable import dropper

class AchievementsTests: XCTestCase {

    
    func testInitial() throws {
        let a = Achievements()
        XCTAssertEqual(a.get(.explodedBlock),0)
        XCTAssertEqual(a.get(.threeRows), 0)
        XCTAssertEqual(a.get(.twoRows), 0)
        XCTAssertEqual(a.get(.oneRow), 0)
        XCTAssertEqual(a.get(.match10), 0)
        XCTAssertEqual(a.get(.match20), 0)
    }

    func testAdd() throws {
        let a = Achievements()
        a.set(.twoRows, 1)
        XCTAssertEqual(a.get(.twoRows), 1)
        
        a.addTo(.twoRows, 2)
        XCTAssertEqual(a.get(.twoRows), 3)
    }
    
    func testSum() throws {
        let a = Achievements()
        a.set(.oneRow, 100)
        a.set(.twoRows, 200)
        a.set(.threeRows, 300)
        XCTAssertEqual(a.sum([.oneRow, .twoRows, .threeRows]), 600)
    }

    func testMerge() throws {
        let a = Achievements()
        a.set(.oneRow, 2)
        a.set(.twoRows, 3)
        a.set(.threeRows, 4)
        a.set(.explodedBlock, 5)
        
        let b = Achievements()
        b.set(.oneRow, 2)
        b.set(.twoRows, 3)
        b.set(.threeRows, 4)
        b.set(.explodedBlock, 5)
        
        XCTAssertEqual(a.sum([.explodedBlock,.twoRows,.oneRow,.threeRows]), 14)
        a.merge(b)
        XCTAssertEqual(a.sum([.explodedBlock,.twoRows,.oneRow,.threeRows]), 28)
    }
    
    
}
