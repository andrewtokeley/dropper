//
//  Button.swift
//  dropper
//
//  Created by Andrew Tokeley on 19/02/23.
//

import Foundation
import SpriteKit

protocol ButtonNodeDelegate {
    func buttonClicked(sender: ButtonNode)
}

class ButtonNode: SKSpriteNode {
    var delegate: ButtonNodeDelegate?
    var tag: String?
    
    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        isUserInteractionEnabled = true
    }
    
    convenience init (text: String, size: CGSize, color: UIColor) {
        self.init(texture: nil, color: color, size: size)
        isUserInteractionEnabled = true
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.position = CGPoint(x: 0, y: -label.calculateAccumulatedFrame().height/2)
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.buttonClicked(sender: self)
    }

}
