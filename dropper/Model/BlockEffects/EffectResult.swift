//
//  EffectResult.swift
//  dropper
//
//  Created by Andrew Tokeley on 12/03/23.
//

import Foundation

/**
 A ``EffectResult`` describes the impact of an effect on a grid.
 */
class EffectResult {
    
    var isMaterial: Bool {
        return blocksRemoved.count > 0 || (blocksMoved.count > 0 && blocksMovedTo.count > 0)
    }
    
    /// BlockResult array for each block that's been removed.
    var blocksRemoved = [BlockResult]()
    
    /// BlockResult array for each block that's been moved. For each block there will be a corresponding ``blocksMovedTo`` element
    var blocksMoved = [BlockResult]()
    
    /// Array of references for each block moved by the effect.
    var blocksMovedTo = [GridReference]()
    
    // Achievements gained after applying the effect
    var achievments = Achievements.zero
    
    func clear() {
        blocksMoved = [BlockResult]()
        blocksRemoved = [BlockResult]()
        blocksMovedTo = [GridReference]()
        achievments = Achievements.zero
    }
    
    static var noEffect: EffectResult {
        let result = EffectResult()
        result.clear()
        return result
    }
}
