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
}
