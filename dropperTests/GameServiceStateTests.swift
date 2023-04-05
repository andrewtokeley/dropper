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
    let TITLE_TETRIS = try! TetrisClassicTitle()
    let TITLE_COLOURS = try! ColourMatcherTitle()
    
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
        
        try! gameService.createGame(for: try! TetrisClassicTitle()) { result in
            if let game = result {
                game.score = 123
                let state = GameState(game: game)
                self.gameService.saveGameState(state: state) { error in
                    XCTAssertNil(error)
                    self.gameService.getGameState(for: self.TITLE_TETRIS) { state in
                        XCTAssertEqual(state?.score, 123)
                        XCTAssertEqual(state?.rows, game.rows)
                        XCTAssertEqual(state?.columns, game.columns)
                        XCTAssertEqual(state?.level, 1)
                        XCTAssertEqual(state?.blocks.count, game.rows)
                        XCTAssertEqual(state?.blocks[0].count, game.columns)
                        expect.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 100) { (error) in
            if let e = error {
                XCTFail(e.localizedDescription)
            }
        }
    }

}

