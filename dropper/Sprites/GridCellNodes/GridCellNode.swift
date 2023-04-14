//
//  GridCellNode.swift
//  dropper
//
//  Created by Andrew Tokeley on 9/04/23.
//

import Foundation
import SpriteKit

enum BlockExplosionState {
    // initial state when the block disappears and the sparks start flying
    case started
    
    // final state when the dust has settled and there's no trace of the block
    case dustSettled
}
/**
 Represents a sprite that can be rendered inside a cell of the grid.
 */
class GridCellNode: SKSpriteNode {

    var cellDimension: CGFloat = 0
    var cellSize: CGSize {
        return CGSize(width: cellDimension, height: cellDimension)
    }
    
    init(dimension: CGFloat, name: String?) {
        self.cellDimension = dimension
        super.init(texture: nil, color: .clear, size: CGSize(width: cellDimension, height: cellDimension))
        self.name = name
    }
    
    public func explode(_ completion: ((_ state: BlockExplosionState)->Void)?) {
        // with no explosion animation, the states happen simultaneously
        self.removeFromParent()
        completion?(.started)
        completion?(.dustSettled)
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
