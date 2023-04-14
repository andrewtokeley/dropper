//
//  JewelNode.swift
//  dropper
//
//  Created by Andrew Tokeley on 9/04/23.
//

import Foundation
import SpriteKit

class JewelNode: GridCellNode {

    init(size: CGSize, name: String?) {
        super.init(dimension: size.width, name: name)
        let jewel = SKSpriteNode(texture: SKTexture(imageNamed: "trophy"), color: .clear, size: size)
        addChild(jewel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     Animate the block to simulate an explosion.
    */
    override func explode(_ completion: ((BlockExplosionState) -> Void)?) {
        
        let pulseUp = SKAction.scale(to: CGFloat.random(in: 1.2..<1.6), duration: 0.05)
        let move = SKAction.moveBy(x: CGFloat.random(in: -45..<45), y: CGFloat.random(in: 50..<200), duration: 1.2)
        move.timingMode = .easeOut
        let fade = SKAction.fadeOut(withDuration: 1.2)
        run(pulseUp) {
            completion?(.started)
        }
        run(move)
        run(fade) {
            completion?(.dustSettled)
            self.removeFromParent()
        }
    }
}
