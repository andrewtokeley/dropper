//
//  Block.swift
//  dropper
//
//  Created by Andrew Tokeley on 19/02/23.
//

import SpriteKit

class BlockNode: SKSpriteNode {
    
    var block: Block!
    var blockColour: UIColor {
        switch block.colour {
            case .orange: return .orange
            case .yellow: return .yellow
            case .red: return .red
            case .blue: return .cyan
            case .ground: return .brown
        default: return .systemPink
        }
    }
    
    
    
    lazy var rectangle: SKShapeNode = {
        let node = SKShapeNode(rect: CGRect(origin: CGPoint(x:-self.size.width/2, y:-self.size.height/2), size: self.size), cornerRadius: 0)
        node.strokeColor = .black
        node.lineWidth = 2
        node.fillColor = blockColour
        
//        if block.type == .player {
//            //parentDot.position = CGPoint(x:-self.size.width/2, y:-self.size.height/2)
//            node.addChild(parentDot)
//        }
        return node
    }()
    
    // MARK: - Initializers
    
    init (block: Block, size: CGFloat) {
        super.init(texture: nil, color: .clear, size: CGSize(width: size, height: size))
        self.block = block
        addChild(rectangle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    public func explode(_ completion: (()->Void)?) {
        let pulseUp = SKAction.scale(to: 1.3, duration: 0.15)
        let pulseDown = SKAction.scale(to: 0.0, duration: CGFloat.random(in: 0.1..<0.8))
        let pause = SKAction.wait(forDuration: 0.02)
        let pulse = SKAction.sequence([pause, pulseUp, pulseDown])
        
        rectangle.run(pulse) {
            completion?()
        }
    }
    
    
//    private func adjustLabelFontSizeToFitRect(labelNode:SKLabelNode, rect:CGRect, scale: CGFloat = 1) {
//        // Determine the font scaling factor that should let the label text fit in the given rectangle.
//        let scalingFactor = min(rect.width / labelNode.frame.width, rect.height / labelNode.frame.height)
//
//        // Change the fontSize.
//        labelNode.fontSize *= scalingFactor * scale
//
//        // Optionally move the SKLabelNode to the center of the rectangle.
//        labelNode.position = CGPoint(x: rect.midX, y: rect.midY - labelNode.frame.height / 2.0)
//    }
}
