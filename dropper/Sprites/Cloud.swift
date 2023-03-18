//
//  Cloud.swift
//  dropper
//
//  Created by Andrew Tokeley on 10/03/23.
//

import Foundation
import SpriteKit

class Cloud: SKSpriteNode {
    
    var scale: CGFloat = 1 {
        didSet {
            self.setScale(scale)
        }
    }
    
    init(_ scale: Double) {
        self.scale = scale
        super.init(texture: SKTexture(imageNamed: "cloud2"), color: .clear, size: CGSize(width: 512, height: 512))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.texture = SKTexture(imageNamed: "cloud2")
    }
}
