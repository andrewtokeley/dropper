//
//  Button.swift
//  dropper
//
//  Created by Andrew Tokeley on 19/02/23.
//

import Foundation
import SpriteKit

class Button: SKSpriteNode {
    var delegate: (() -> Void)?
    
    init (size: CGSize, color: UIColor, text: String, delegate: (()->Void)?) {
        
        super.init(texture: nil, color: color, size: size)
        
        self.delegate = delegate
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
        delegate?()
    }
    
}
