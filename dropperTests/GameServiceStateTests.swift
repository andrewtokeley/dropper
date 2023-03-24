//
//  GameServiceStateTests.swift
//  dropperTests
//
//  Created by Andrew Tokeley on 23/03/23.
//

import XCTest
@testable import dropper

final class GameServiceStateTests: XCTestCase {
    let gameService = ServiceFactory.sharedInstance.gameService
    
    override func setUpWithError() throws {
        let expect = expectation(description: "setUpWithError")
        gameService.clearGameState { (result) in
            XCTAssertTrue(result)
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { (error) in
            if let e = error {
                XCTFail(e.localizedDescription)
            }
        }
    }

    func testNoState() throws {
        gameService.getGameState { state in
            XCTAssertNil(state)
        }
    }

    func testSaveThenGet() throws {
        let expect = expectation(description: "testSaveThenGet")
        let rows = 10
        let columns = 5
        let state = GameState(blocks: Array(repeating: Array(repeating: Block(.colour1, .block), count: columns), count: rows), score: 123, rows: 4, level: 1)
        gameService.saveGameState(state) { error in
            XCTAssertNil(error)
            self.gameService.getGameState { state in
                XCTAssertEqual(state?.score, 123)
                XCTAssertEqual(state?.rows, 4)
                XCTAssertEqual(state?.level, 1)
                XCTAssertEqual(state?.blocks.count, rows)
                XCTAssertEqual(state?.blocks[0].count, columns)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 100) { (error) in
            if let e = error {
                XCTFail(e.localizedDescription)
            }
        }
    }

}
