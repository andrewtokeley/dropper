//
//  GameStatus.swift
//  dropper
//
//  Created by Andrew Tokeley on 8/03/23.
//

import Foundation
import SpriteKit

class ScoreNode: SKSpriteNode {
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    lazy var scoreLabel: SKLabelNode = {
        let node = SKLabelNode()        
        node.fontSize = 30
        node.fontColor = .white
        return node
    }()
    
    init(_ score: Int, size: CGSize) {
        super.init(texture: nil, color: .clear, size: size)
        addChild(scoreLabel)
        self.score = score
    }
    
    public func incrementScore(by: Int) {
        self.score += by
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
