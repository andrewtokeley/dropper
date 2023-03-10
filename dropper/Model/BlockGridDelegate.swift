//
//  BlockGridDelegate.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/02/23.
//

import Foundation
import SpriteKit

protocol BlockGridDelegate {
    
    // MARK: - Player
    func blockGrid(_ blockGrid: BlockGrid, playerAdded playerBlockResults: [BlockResult])
    func blockGrid(_ blockGrid: BlockGrid, playerRotatedBy degrees: CGFloat)
    func blockGrid(_ blockGrid: BlockGrid, playerMovedInDirection direction: BlockMoveDirection)
    func blockGrid(_ blockGrid: BlockGrid, playerBlockRemoved block: Block)
    func playerRemoved()
    
    // MARK: - Blocks
    func blockGrid(_ blockGrid: BlockGrid, blockMoved block: Block, to: GridReference)
    func blockGrid(_ blockGrid: BlockGrid, blocksMoved blocks: [Block], to: [GridReference])
    func blockGrid(_ blockGrid: BlockGrid, blockAdded block: Block, reference: GridReference)
    func blockGrid(_ blockGrid: BlockGrid, blockRemoved block: Block)
    func blockGrid(_ blockGrid: BlockGrid, blocksRemoved blocks: [Block])
    
    
    
}
