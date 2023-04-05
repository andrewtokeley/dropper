//
//  GameServiceTests.swift
//  dropperTests
//
//  Created by Andrew Tokeley on 22/03/23.
//

import XCTest
@testable import dropper

final class GameServiceScoreTests: XCTestCase {
    let gameService = ServiceFactory.sharedInstance.gameService
    let TITLE_TETRIS = try! TetrisClassicTitle()
    let TITLE_COLOURS = try! ColourMatcherTitle()

    override func setUp() {
        let expect = expectation(description: "setup")
        gameService.clearScoreState(for: TITLE_TETRIS) { (result) in
            XCTAssertTrue(result)
            self.gameService.clearScoreState(for: self.TITLE_COLOURS) { (result) in
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
        
    func testTestMode() throws {
        XCTAssertTrue(ServiceFactory.sharedInstance.runningInTestMode)
    }
    
    func testClearState() throws {
        let expect = expectation(description: "testClearState")
        
        self.gameService.addScore(for: TITLE_TETRIS, score: 100) { result, error in
            XCTAssertNil(error)
            self.gameService.clearScoreState(for: self.TITLE_TETRIS) { (result) in
                XCTAssertTrue(result)
                self.gameService.getScoreHistory(for: self.TITLE_TETRIS) { scores in
                    XCTAssertEqual(scores.count, 0)
                    expect.fulfill()
                }
            }
            
        }
        waitForExpectations(timeout: 100) { (error) in
            if let e = error {
                XCTFail(e.localizedDescription)
            }
        }
    }
    
    func testGetScores() throws {
        let expect = expectation(description: "testGetScores")
        
        self.gameService.addScore(for: TITLE_COLOURS, score: 200) { _, error in
            self.gameService.getScoreHistory(for: self.TITLE_COLOURS) { scores in
                XCTAssertEqual(scores.count, 1)
                XCTAssertEqual(scores[0], 200)
                expect.fulfill()
            }
        }
        
        waitForExpectations(timeout: 100) { (error) in
            if let e = error {
                XCTFail(e.localizedDescription)
            }
        }
    }
    
    func testSaveScores() throws {
        let expect = expectation(description: "testSaveScores")
        
        gameService.addScore(for: TITLE_COLOURS, score: 100) { isHighScore, error in
            XCTAssertNotNil(isHighScore)
            XCTAssertTrue(isHighScore!)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 100) { (error) in
            if let e = error {
                XCTFail(e.localizedDescription)
            }
        }
    }
    
    func testScoresFull() throws {
        let expect = expectation(description: "testSaveScores")
        
        gameService.addScore(for: TITLE_COLOURS, score: 100) { _, _ in
            self.gameService.addScore(for: self.TITLE_COLOURS, score: 200) { _, _ in
                self.gameService.addScore(for: self.TITLE_COLOURS, score: 300) { _, _ in
                    self.gameService.addScore(for: self.TITLE_COLOURS, score: 400) { isHighScore, _ in
                        XCTAssertTrue(isHighScore!)
                        self.gameService.getScoreHistory(for: self.TITLE_COLOURS) { scores in
                            
                            // should only be 3 not 4
                            XCTAssertEqual(scores.count, 3)
                            
                            // the highscore should be 400
                            XCTAssertEqual(scores.max(), 400)
                            
                            expect.fulfill()
                        }
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
