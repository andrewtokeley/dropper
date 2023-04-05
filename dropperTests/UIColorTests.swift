//
//  UIColorTests.swift
//  dropperTests
//
//  Created by Andrew Tokeley on 5/04/23.
//

import XCTest
@testable import dropper

final class UIColorTests: XCTestCase {

    func testHexConversion() throws {
        let colour: UIColor = .gameBlock1
        
        let hex = colour.asHex()
        
        let sameColour = UIColor.fromHex(hexString: hex)
        
        XCTAssertEqual(sameColour, colour)
    }
}
