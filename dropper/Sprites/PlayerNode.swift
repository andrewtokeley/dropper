//
//  PlayerNode.swift
//  dropper
//
//  Created by Andrew Tokeley on 25/02/23.
//

import Foundation
import SpriteKit

enum PlayerNodeError: Error {
    case NoOrigin
}

class PlayerNode: SKSpriteNode {
    
    var blocksNodes = [BlockNode]()
    
    init (blocks: [Block], blockSize: CGFloat) throws {
        guard let origin = blocks.first(where: { $0.isOrigin }) else { throw PlayerNodeError.NoOrigin }
        
        super.init(texture: nil, color: .clear, size: CGSize(width: blockSize*CGFloat(blocks.count), height: blockSize))
        
        if let originIndex = blocks.firstIndex(of: origin) {
                
            let leftMostPosition = CGPoint(x: -(CGFloat(originIndex) * blockSize) , y: 0)
            for i in 0..<blocks.count {
                let blockNode = BlockNode(block: blocks[i], size: blockSize)
                blockNode.position = CGPoint(x: leftMostPosition.x + CGFloat(i) * blockSize, y: 0)
                blockNode.name = blocks[i].id
                blocksNodes.append(blockNode)
                addChild(blockNode)
            }
        }
    }
    
    /**
     Removes one of the blocks from a player block and once completed, calls the completion handler passing in the number of remaining blocks
     
     - Parameters:
        - block: the Block instance to remove
        - completion: a closure that will be passed the number of remaining blocks in the player
     */
    func removeBlock(_ block: Block, completion: ((Int) -> Void)?) {
        if let node = self.childNode(withName: block.id) {
            node.run(SKAction.fadeOut(withDuration: 0.5)) {
                node.removeFromParent()
                self.blocksNodes.removeAll(where: { $0.block.id == block.id})
                
                // if this was the last block let the completion handler know
                completion?(self.blocksNodes.count)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
