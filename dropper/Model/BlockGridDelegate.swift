//
//  BlockGridDelegate.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/02/23.
//

import Foundation
import SpriteKit

protocol BlockGridDelegate {
    
    // MARK: - Shape Methods
    func blockGrid(_ blockGrid: BlockGrid, shapeAdded: Shape, to: GridReference)
    func blockGrid(_ blockGrid: BlockGrid, shapeRotatedBy degrees: CGFloat, withKickMove moveTo: GridReference)
    func blockGrid(_ blockGrid: BlockGrid, shapeMovedInDirection direction: BlockMoveDirection)
    func blockGrid(_ blockGrid: BlockGrid, shapeDropedTo reference: GridReference)
    func shapeRemoved()
    
    // MARK: - Blocks
    func blockGrid(_ blockGrid: BlockGrid, blockMoved block: Block, to: GridReference)
    func blockGrid(_ blockGrid: BlockGrid, blocksMoved blocks: [Block], to: [GridReference])
    func blockGrid(_ blockGrid: BlockGrid, blockAdded block: Block, reference: GridReference)
    func blockGrid(_ blockGrid: BlockGrid, blocksAdded blocks: [Block], references: [GridReference])
    func blockGrid(_ blockGrid: BlockGrid, blocksRemoved blocks: [Block])
    
}
