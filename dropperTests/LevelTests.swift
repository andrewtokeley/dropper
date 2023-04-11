//
//  LevelTests.swift
//  dropperTests
//
//  Created by Andrew Tokeley on 26/03/23.
//

import XCTest
@testable import dropper


final class LevelTests: XCTestCase {

    
    func testColourMatchPoints() throws {
        
        let game = ColourMatcherGame()
        game.setLevel(1)
        
        // Standard game is to match 15 or more colours, let's match 20
        let achievements = Achievements()
        achievements.addTo(.colourMatch, 20)
        
        let points = game.currentLevel?.pointsFor(moveAchievements: achievements) ?? 0
        
        // We should get 300 base points plus 5*100 points for the extra 5 blocks
        XCTAssertEqual(points, 800)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
