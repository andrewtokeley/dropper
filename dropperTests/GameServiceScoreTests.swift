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
    
    override func setUp() {
        let expect = expectation(description: "setup")
        gameService.clearScoreState { (result) in
            XCTAssertTrue(result)
            expect.fulfill()
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
        
        self.gameService.addScore(100) { result, error in
            XCTAssertNil(error)
            self.gameService.clearScoreState { (result) in
                XCTAssertTrue(result)
                self.gameService.getScoreHistory { scores in
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
        
        self.gameService.addScore(200) { _, error in
            self.gameService.getScoreHistory { scores in
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
        
        gameService.addScore(100) { isHighScore, error in
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
        
        gameService.addScore(100) { _, _ in
            self.gameService.addScore(200) { _, _ in
                self.gameService.addScore(300) { _, _ in
                    self.gameService.addScore(400) { isHighScore, _ in
                        XCTAssertTrue(isHighScore!)
                        self.gameService.getScoreHistory { scores in
                            
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
