//
//  BaseShapeNode.swift
//  dropper
//
//  Created by Andrew Tokeley on 5/03/23.
//

import Foundation
import SpriteKit

/**
 Errors raised during initialisation of a new Shape
 */
enum ShapeNodeError: Error {
    case InvalidInitialState
    case NoOrigin
}

/**
 SpriteNode implementation of a shape and its blocks
 */
class ShapeNode: SKSpriteNode {
    
    /**
     The blocks that make up the shape. Each block can be a different colour.
     */
    var blocks = [Block]()
    
    /**
     The grid references of each block in the shape.
     */
    var references = [GridReference]()
    
    /**
     The size of each block. Blocks are always square.
     */
    var blockSize: CGFloat = 0
    
    /**
     Reference to the shape's block nodes
     */
    var blockNodes = [BlockNode]()
    
    /**
     Returns a ShapeNode that is a copy of the current ShapeNode, but looks ghostlike.
     
     Note, the position of the Ghost ShapeNode will be the same as the current ShapeNode.
     */
    var ghostShapeNode: ShapeNode? {
        // copy doesn't copy any of the custom properties, just the node stuff
        if let node = self.copy() as? ShapeNode {
            node.removeAllActions()
            for child in node.children {
                if let blockNode = child as? BlockNode {
                    if let bodyNode = blockNode.childNode(withName: "bodyNode") as? SKShapeNode {
                        bodyNode.fillColor = bodyNode.fillColor.withAlphaComponent(0.5)
                    }
                }
            }
            return node
        }
        return nil
    }
    
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
//    init (blocks: [Block], references: [GridReference], blockSize: CGFloat) throws {
//        guard blocks.count != 0 else { throw ShapeNodeError.InvalidInitialState}
//        guard blocks.count == references.count else { throw ShapeNodeError.InvalidInitialState}
//
//        super.init(texture: nil, color: .clear, size: CGSize(width: blockSize*3.0, height: blockSize*3.0))
//
//        setShape(blocks: blocks, references: references, blockSize: blockSize)
//    }
    
    /**
     Initialise a new shape based on the Shape definition and size.
     */
    init (shape: Shape, blockSize: CGFloat) {
        super.init(texture: nil, color: .clear, size: CGSize(width: blockSize*3.0, height: blockSize*3.0))
        setShape(shape, blockSize: blockSize)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     Need this for copy() to work for ghost
     */
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    //MARK: - Set Shape
    
    /**
     (Re)Sets the shape
     */
    private func setShape(blocks: [Block], references: [GridReference], blockSize: CGFloat) {
        self.removeAllChildren()
        self.size = CGSize(width: blockSize*3.0, height: blockSize*3.0)

        for i in 0..<blocks.count {
            let blockNode = BlockNode(block: blocks[i], size: blockSize)
            blockNode.name = blocks[i].id

            // position (0,0), the centre of the node, is the position of the block at GridReference(0,0)
            let x = CGFloat(references[i].column) * blockSize
            let y = CGFloat(references[i].row) * blockSize
            blockNode.position = CGPoint(x: x, y: y)

            blockNodes.append(blockNode)
            addChild(blockNode)
        }
    }
    
    public func setShape(_ shape: Shape, blockSize: CGFloat) {
        let blocks = shape.blocks.map { $0.block! }
        
        // normalise the shape references about the origin
        let references = shape.references.map { $0.offSet(GridOffset(-shape.origin.row, -shape.origin.column))}
        setShape(blocks: blocks, references: references, blockSize: blockSize)
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
                self.blockNodes.removeAll(where: { $0.block.id == block.id})
                
                // if this was the last block let the completion handler know
                completion?(self.blockNodes.count)
            }
        }
    }
    
    
}
