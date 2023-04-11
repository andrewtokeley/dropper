//
//  Block.swift
//  dropper
//
//  Created by Andrew Tokeley on 19/02/23.
//

import SpriteKit

class BlockNode: GridCellNode {
    
    var isGhost: Bool = false
    
    var blockColour: BlockColour = .colour1 {
        didSet {
            rectangle.fillColor = UIColor.from(blockColour)
        }
    }
    
    private lazy var rectangle: SKShapeNode = {
        let node = SKShapeNode(rect: CGRect(origin: CGPoint(x:-self.size.width/2, y:-self.size.height/2), size: self.size), cornerRadius: 0)
        node.strokeColor = UIColor.white
        node.lineWidth = 2
        node.fillColor = UIColor.from(blockColour)
        node.name = "bodyNode"

        return node
    }()
    
    // MARK: - Functions
    
    /**
     Changes the block's appearance to appear like a ghost or not.
     */
    public func setGhostState(_ isGhost: Bool) {
        self.isGhost = isGhost
        let alpha = isGhost ? 0.5 : 1
        rectangle.fillColor = rectangle.fillColor.withAlphaComponent(alpha)
    }
    
    // MARK: - Initializers
    
    init(colour: BlockColour, size: CGFloat, name: String? = nil) {
        super.init(dimension: size, name: name)
        self.blockColour = colour
        addChild(rectangle)
    }
    
    convenience init (block: Block, size: CGFloat) {
        self.init(colour: block.colour, size: size, name: block.id)
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(dimension: size.width, name: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Actions
    
    /**
     Animate the block to simulate an explosion
     */
    override func explode(_ completion: (()->Void)?) {
        let pulseDown = SKAction.scale(to: CGFloat.random(in: 0.2..<0.6), duration: 0.05)
        let move = SKAction.moveBy(x: CGFloat.random(in: -45..<45), y: CGFloat.random(in: 50..<200), duration: 1.2)
        move.timingMode = .easeOut
        let fade = SKAction.fadeOut(withDuration: 1.2)
        rectangle.run(move)
        rectangle.run(fade) {
            self.removeFromParent()
        }
        rectangle.run(pulseDown) {
            completion?()
        }
        
    }
    
}
