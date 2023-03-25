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
    let TITLE_TETRIS = TetrisClassicTitle()
    let TITLE_COLOURS = ColourMatcherTitle()
    
    override func setUpWithError() throws {
        let expect = expectation(description: "setUpWithError")
        gameService.clearGameState(for: TITLE_TETRIS) { (result) in
            XCTAssertTrue(result)
            self.gameService.clearGameState(for: self.TITLE_COLOURS) { (result) in
                XCTAssertTrue(result)
                expect.fulfill()
            }
        }
        
        waitForExpectations(timeout: 100) { (error) in
            if let e = error {
                XCTFail(e.localizedDescription)
            }
        }
    }

    func testNoState() throws {
        let expect = expectation(description: "testNoState")
        gameService.getGameState(for: TITLE_TETRIS) { state in
            XCTAssertNil(state)
            self.gameService.getGameState(for: self.TITLE_COLOURS) { state in
                XCTAssertNil(state)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 100) { (error) in
            if let e = error {
                XCTFail(e.localizedDescription)
            }
        }
    }

    func testSaveThenGet() throws {
        let expect = expectation(description: "testSaveThenGet")
        let rows = 10
        let columns = 5
        let state = GameState(blocks: Array(repeating: Array(repeating: Block(.colour1, .block), count: columns), count: rows), score: 123, rows: 4, level: 1)
        gameService.saveGameState(for: TITLE_TETRIS, state: state) { error in
            XCTAssertNil(error)
            self.gameService.getGameState(for: self.TITLE_TETRIS) { state in
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

