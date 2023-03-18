//
//  BaseShapeNode.swift
//  dropper
//
//  Created by Andrew Tokeley on 5/03/23.
//

import Foundation
import SpriteKit

enum ShapeNodeError: Error {
    case InvalidInitialState
    case NoOrigin
}

class ShapeNode: SKSpriteNode {
    
    var blocks = [Block]()
    var references = [GridReference]()
    var blockSize: CGFloat = 0
    
    var blocksNodes = [BlockNode]()
    
    /**
     Initialise a new shape as defined by the blocks and corresponding grid
     
     For example, this code would all an L shape, 3 blocks high and 2 blocks wide
     
     ````
     let shape = ShapeNode(
        colours: Array(repeating: Block(.red, .player), 4),
        references: [GridReference(2,0),
                    GridReference(1,0),
                    GridReference(0,0),
                    GridReference(0,1)]
     ````
     
     - Parameters:
        - blocks: definition of each block in the shape
        - references: location of each block
        - blockSize: size of a single (square) block
     */
    init (blocks: [Block], references: [GridReference], blockSize: CGFloat) throws {
        guard blocks.count != 0 else { throw ShapeNodeError.InvalidInitialState}
        guard blocks.count == references.count else { throw ShapeNodeError.InvalidInitialState}

        super.init(texture: nil, color: .clear, size: CGSize(width: blockSize*3.0, height: blockSize*3.0))
        
        setShape(blocks: blocks, references: references, blockSize: blockSize)
    }
    
    init (shape: Shape, blockSize: CGFloat) {
        super.init(texture: nil, color: .clear, size: CGSize(width: blockSize*3.0, height: blockSize*3.0))
        setShape(shape, blockSize: blockSize)
    }
    
    public func setShape(blocks: [Block], references: [GridReference], blockSize: CGFloat) {
        self.removeAllChildren()
        self.size = CGSize(width: blockSize*3.0, height: blockSize*3.0)
        
        for i in 0..<blocks.count {
            let blockNode = BlockNode(block: blocks[i], size: blockSize)
            blockNode.name = blocks[i].id
            
            // position (0,0), the centre of the node, is the position of the block at GridReference(0,0)
            let x = CGFloat(references[i].column) * blockSize
            let y = CGFloat(references[i].row) * blockSize
            blockNode.position = CGPoint(x: x, y: y)
            
            blocksNodes.append(blockNode)
            addChild(blockNode)
        }
    }
    
    public func setShape(_ shape: Shape, blockSize: CGFloat) {
        var blocks = [Block]()
        for i in 0..<shape.colours.count {
            blocks.append(Block(shape.colours[i], .block))
        }
        setShape(blocks: blocks, references: shape.references, blockSize: blockSize)
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
        super.init(coder: aDecoder)
    }
}
