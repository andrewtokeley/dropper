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
    let TITLE_JEWEL = try! JewelTitle()
    
    override func setUp() async throws {
        let _ = await gameService.clearScoreState(for: TITLE_JEWEL)
        let _ = await gameService.clearScoreState(for: TITLE_TETRIS)
        let _ = await gameService.clearScoreState(for: TITLE_COLOURS)
    }
        
    func testTestMode() throws {
        XCTAssertTrue(ServiceFactory.sharedInstance.runningInTestMode)
    }
    
    func testClearState() async throws {
        let score = Score(points: 100)
        
        var result = try await gameService.addScore(for: TITLE_TETRIS, score: score)
        XCTAssertTrue(result)
        
        result = await gameService.clearScoreState(for: self.TITLE_TETRIS)
        XCTAssertTrue(result)
        
        let scores = await gameService.getScoreHistory(for: self.TITLE_TETRIS)
        XCTAssertEqual(scores.count, 0)
    }
    
    func testGetScores() async throws {
        
        let achievements = Achievements()
        achievements.addTo(.jewel, 3)
        achievements.addTo(.explodedBlock, 10)
        let score = Score(points: 200, gameAchievements: achievements)
        let result = try await self.gameService.addScore(for: TITLE_JEWEL, score: score)
        XCTAssertTrue(result)
        
        let scores = await self.gameService.getScoreHistory(for: self.TITLE_JEWEL)
        XCTAssertEqual(scores.count, 1)
        XCTAssertEqual(scores[0].points, 200)
        XCTAssertEqual(scores[0].gameAchievements.get(.jewel), 3)
        XCTAssertEqual(scores[0].gameAchievements.get(.explodedBlock), 10)

    }
    
    func testSaveScores() async throws {
        let score = Score(points: 100)
        let isHighScore = try await gameService.addScore(for: TITLE_COLOURS, score: score)
        XCTAssertTrue(isHighScore)
    }
    
    func testScoresFull() async throws {
        let score1 = Score(points: 100)
        let score2 = Score(points: 200)
        let score3 = Score(points: 300)
        let score4 = Score(points: 400)
        
        let _ = try await gameService.addScore(for: TITLE_COLOURS, score: score1)
        let _ = try await gameService.addScore(for: TITLE_COLOURS, score: score2)
        let _ = try await gameService.addScore(for: TITLE_COLOURS, score: score3)
        let isHighScore = try await gameService.addScore(for: TITLE_COLOURS, score: score4)
        XCTAssertTrue(isHighScore)

        let scores = await self.gameService.getScoreHistory(for: self.TITLE_COLOURS)
        XCTAssertEqual(scores.count, 3)
        XCTAssertEqual(scores.map({$0.points}).max(), 400)
    }

}
