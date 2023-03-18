//
//  GroundNode.swift
//  dropper
//
//  Created by Andrew Tokeley on 19/02/23.
//

import Foundation
import SpriteKit

class Ground: SKSpriteNode {
    init (color: UIColor) {
        
        super.init(texture: nil, color: color, size: CGSize(width: 500, height: 10))
        
        let node = SKShapeNode(rect: CGRect(origin: CGPoint(x:-250,y:-5), size: CGSize(width: 500, height: 10)), cornerRadius: 0)
        node.strokeColor = color
        node.fillColor = color
        addChild(node)
        
        physicsBody = SKPhysicsBody(rectangleOf: frame.size)
        physicsBody?.isDynamic = false
        physicsBody?.restitution = 0.0
        
        physicsBody?.categoryBitMask = CollisionTypes.ground.rawValue
        physicsBody?.contactTestBitMask = CollisionTypes.block.rawValue
        physicsBody?.collisionBitMask = CollisionTypes.block.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
