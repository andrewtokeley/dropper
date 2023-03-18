//
//  EffectsRunner.swift
//  dropper
//
//  Created by Andrew Tokeley on 13/03/23.
//

import Foundation

protocol EffectsRunnerDelegate {
    func didFinishEffectsRun(_ runner: EffectsRunner, achievements: Achievements)
}

class EffectsRunner {
    public var delegate: EffectsRunnerDelegate?
    
    private var grid: BlockGrid
    private var effects = [GridEffect]()
    private var requireEffectsCheck: Bool = false
    
    /// The combined achievements of running the effects
    public var achievements: Achievements
    
    public var applyEffectsToView: (EffectResult, (()->Void)?) -> Void
    
    init(grid: BlockGrid, effects: [GridEffect]) {
        self.grid = grid
        self.effects = effects
        self.achievements = Achievements.zero
        
        self.applyEffectsToView = { (effectResult, completion) in
            completion?()
        }
    }
    
    /**
     Runs all the effects and calls delegate once finished
     */
    public func applyEffects(_ resetAchievements: Bool = true) {
        if resetAchievements {
            self.achievements.clear()
        }
        
        if (self.effects.count > 0) {
            self.requireEffectsCheck = false
            
            // recursively run all effects - the requireEffectsCheck will be set to true if any effects result in change. This method will recursively call itself after the view is updated for each effect.
            self.applyEffect(0, grid: grid)
        }
    }
    
    private func applyEffect(_ index: Int, grid: BlockGrid) {
        guard effects.count > 0 else { return }
        
        if index < effects.count {
            let effectResult = self.effects[index].apply(grid)
            
            if effectResult.isMaterial {
                
                // Merge the results into combined achievements
                self.achievements.merge(effectResult.achievments)
                
                // mark material change so we re-run effects
                self.requireEffectsCheck = true
                
                self.applyEffectsToView(effectResult) {
                    
                    // move to next effect after the view has visualised the effect
                    self.applyEffect(index + 1, grid: grid)
                }
            } else {
                // move to next effect
                self.applyEffect(index + 1, grid: grid)
            }
        } else {
            // we've been through all the effects, check if we need to do it again
            if self.requireEffectsCheck {
                // rerun but don't reset the achievenements
                let _ = applyEffects(false)
            } else {
                // we're done!
                delegate?.didFinishEffectsRun(self, achievements: self.achievements)
            }
        }
    }
    
}
