//
//  BlockTests.swift
//  dropperTests
//
//  Created by Andrew Tokeley on 19/02/23.
//

import XCTest
@testable import dropper

class BlockTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEquality() throws {
        let block1 = Block(.colour3, .shape)
        let block2 = Block(.colour3, .shape)
        XCTAssertNotEqual(block1, block2)
        XCTAssertEqual(block1, block1)
    }

    
   

}
