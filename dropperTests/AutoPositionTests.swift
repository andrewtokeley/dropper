//
//  AutoPositionTests.swift
//  dropperTests
//
//  Created by Andrew Tokeley on 15/03/23.
//

import XCTest
@testable import dropper
import SpriteKit

class AutoPositionTests: XCTestCase {

    func testSpriteNodePosition() throws {
        let node = SKSpriteNode(texture: nil, color: .red, size: CGSize(width: 100, height: 100))
        let view = SKView(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
        let scene = SKScene(size: CGSize(width:1000, height:2000))
        scene.scaleMode = .resizeFill
        view.presentScene(scene)
        
        scene.addChild(node)
        XCTAssertTrue(node.position.equalTo(CGPoint(x: 0, y: 0)))
        
        let top = scene.size.height - node.size.height/2
        let left = node.size.width/2
        let right = scene.size.width - node.size.width/2
        let bottom = node.size.height/2
        let midX = scene.size.width/2
        let midY = scene.size.height/2
        
        node.autoPositionWithinParent(.centreTop)
        XCTAssertTrue(node.position.equalTo(CGPoint(x: midX, y: top)))
                      
        node.autoPositionWithinParent(.leftTop)
        XCTAssertTrue(node.position.equalTo(CGPoint(x: left, y: top)))
        
        node.autoPositionWithinParent(.centreTop)
        XCTAssertTrue(node.position.equalTo(CGPoint(x: midX, y: top)))
        
        node.autoPositionWithinParent(.leftBottom)
        XCTAssertTrue(node.position.equalTo(CGPoint(x: left, y: bottom)))
        
        node.autoPositionWithinParent(.rightBottom)
        XCTAssertTrue(node.position.equalTo(CGPoint(x: right, y: bottom)))
        
        node.autoPositionWithinParent(.centreBottom)
        XCTAssertTrue(node.position.equalTo(CGPoint(x: midX, y: bottom)))
        
        node.autoPositionWithinParent(.leftCentre)
        XCTAssertTrue(node.position.equalTo(CGPoint(x: left, y: midY)))

        node.autoPositionWithinParent(.rightCentre)
        XCTAssertTrue(node.position.equalTo(CGPoint(x: right, y: midY)))
    }

    func testLabelNodePosition() throws {
        let node = SKLabelNode(text: "TEXT")
        let view = SKView(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
        let scene = SKScene(size: CGSize(width:1000, height:2000))
        scene.scaleMode = .resizeFill
        view.presentScene(scene)
        
        scene.addChild(node)
        XCTAssertTrue(node.position.equalTo(CGPoint(x: 0, y: 0)))
        
        let left = node.frame.size.width/2
        let midX = scene.size.width/2
        let midY = scene.size.height/2
        
        // when label is centred it behaves like spriteNodes as is positioned at an anchor of (0,0)
        node.verticalAlignmentMode = .baseline
        node.horizontalAlignmentMode = .center
        node.autoPositionWithinParent(.leftCentre)
        XCTAssertTrue(node.position.equalTo(CGPoint(x: left, y: midY)))
        
        // when label is left aligned, it's anchor is at (-0.5, 0.5), so it's position should be hard up against the left edge.
        node.verticalAlignmentMode = .baseline
        node.horizontalAlignmentMode = .left
        node.autoPositionWithinParent(.leftCentre)
        XCTAssertTrue(node.position.equalTo(CGPoint(x: 0, y: midY)))
        
        // similarly for right aligned labels
        node.verticalAlignmentMode = .baseline
        node.horizontalAlignmentMode = .right
        node.autoPositionWithinParent(.rightCentre)
        XCTAssertTrue(node.position.equalTo(CGPoint(x: scene.size.width, y: midY)))
        
        node.verticalAlignmentMode = .top
        node.horizontalAlignmentMode = .center
        node.autoPositionWithinParent(.centreTop)
        XCTAssertTrue(node.position.equalTo(CGPoint(x: midX, y: scene.size.height)))
        
        node.verticalAlignmentMode = .bottom
        node.horizontalAlignmentMode = .center
        node.autoPositionWithinParent(.centreBottom)
        XCTAssertTrue(node.position.equalTo(CGPoint(x: midX, y: 0)))
    }

    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
