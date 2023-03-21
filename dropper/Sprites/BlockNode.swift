//
//  Block.swift
//  dropper
//
//  Created by Andrew Tokeley on 19/02/23.
//

import SpriteKit

class BlockNode: SKSpriteNode {
    
    public var colour: UIColor = .red {
        didSet {
            rectangle.fillColor = colour
        }
    }
    
    var block: Block!
    
    var blockColour: UIColor {
        switch block.colour {
            case .colour1: return .gameBlock1
            case .colour2: return .gameBlock2
            case .colour3: return .gameBlock3
            case .colour4: return .gameBlock4
            case .colour5: return .gameBlock5
        default: return .white
        }
    }
    
    private lazy var rectangle: SKShapeNode = {
        let node = SKShapeNode(rect: CGRect(origin: CGPoint(x:-self.size.width/2, y:-self.size.height/2), size: self.size), cornerRadius: 0)
        node.strokeColor = UIColor.gameBackground
        node.lineWidth = 4
        node.fillColor = blockColour
        node.name = "bodyNode"
        if block.isGhost {
            node.fillColor = blockColour.withAlphaComponent(0.5)
        }
        return node
    }()
    
    // MARK: - Functions
    
    /**
     Changes the block's appearance to appear like a ghost or not.
     */
    public func setGhostState(_ isGhost: Bool) {
        let alpha = isGhost ? 0.5 : 1
        rectangle.fillColor = rectangle.fillColor.withAlphaComponent(alpha)
    }
    
    // MARK: - Initializers
    
    init (block: Block, size: CGFloat) {
        super.init(texture: nil, color: .clear, size: CGSize(width: size, height: size))
        self.block = block
        addChild(rectangle)
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: nil, color: .clear, size: CGSize.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    // MARK: - Actions
    
    /**
     Animate the block to simulate an explosion
     */
    public func explode(_ completion: (()->Void)?) {
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
