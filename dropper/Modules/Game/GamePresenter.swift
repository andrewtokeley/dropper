//
//  GamePresenter.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/02/23.
//
//

import Foundation
import Viperit
import CoreImage

// MARK: - GamePresenter Class
final class GamePresenter: Presenter {
    
    private var nextShape: Shape?
    
    private var game: Game!
    
    private var grid: BlockGrid!
    
    private var didDrop: Bool = false
    
    /// Flag to store whether the grid has changed and requires special effects to be processed.
    private var requireEffectsCheck = false
    
    override func viewHasLoaded() {
        interactor.createNewGame()
    }
    
}

// MARK: - GamePresenter API
extension GamePresenter: GamePresenterApi {
    
    
    func didSelectNewGame() {
        interactor.createNewGame()
    }
    
    func didCreateNewGame(game: Game, grid: BlockGrid) {
        self.grid = grid
        self.game = game
        
        grid.delegate = self
        
        let all = grid.getAll()
        view.initialiseGame(rows: grid.rows, columns: grid.columns)
        view.addBlocks(all.map { $0.block! }, references: all.map { $0.gridReference }, completion: nil)
        view.displayLevel(game.currentLevel)
        view.updateScore(0)
        view.updateLevelProgress(game.currentLevel.goalDescription, progress: 0)
        addNewPlayer()
    }
    
    /**
     Move to the next level
     */
    func nextLevel() {
        // move to next level
        self.game.moveToNextLevel()
        
        // Reset level state
        self.nextShape = nil
        self.game.levelAchievements = Achievements.zero
        
        // Update the view
        view.displayLevel(self.game.currentLevel)
        
        // Remove all the blocsk
        let blocks = grid.getAll().map { $0.block! }
        grid.removeBlocks(grid.getAll().map { $0.gridReference }, suppressDelegateCall: true)
        view.removeBlocks(blocks) {
            // Add a new shape
            self.addNewPlayer()
        }
    }
    
    func didSelectMove(_ direction: BlockMoveDirection) {
        let _ = grid.movePlayer(direction)
    }
    
    func didSelectDrop() {
        dropPlayer()
    }
    
    func didSelectRotate() {
        let _ = grid.rotatePlayer()
    }
    
    /**
     Add a new play to the grid, if we can't it means a life is lost!
     */
    func addNewPlayer() {
        // initialise the next shape if this is the first time
        if nextShape == nil {
            nextShape = game.currentLevel.nextShape()
        }
        if let shape = nextShape {
            nextShape = game.currentLevel.nextShape()
            view.displayNextShape(nextShape!)
            
            if let playerAdded = try? grid.addPlayer(shape) {
                if (playerAdded) {
                    
                    // this will start the player falling
                    let _ = grid.movePlayer(.down)
                    
                } else {
                    // life lost
                    print("Life Lost")
                }
            } else {
                print("Life LOST")
            }
        }
    }
    
    private func applyEffects() {
        
        let runner = EffectsRunner(grid: grid, effects: self.game.currentLevel.effects)
        runner.applyEffectsToView = self.applyEffectsToView
        runner.delegate = self
        
        runner.applyEffects()
    }
    
    private func applyEffectsToView(_ effects: EffectResult, completion: (()->Void)?) {
        let dispatch = DispatchGroup()
        
        // Apply removes
        if effects.blocksRemoved.count > 0 {
            dispatch.enter()
            self.view.displayPoints(self.game.currentLevel.pointsFor(effects.achievments), from: GridReference(5,10))
            self.view.removeBlocks(effects.blocksRemoved) {
                dispatch.leave()
            }
        }
        
        // Apply moves
        if effects.blocksMoved.count > 0 {
            dispatch.enter()
            self.view.moveBlocks(effects.blocksMoved, to: effects.blocksMovedTo) {
                dispatch.leave()
            }
        }
        
        // Wait until the view has finished removing and moving
        dispatch.notify(queue: DispatchQueue.main, execute: {
            completion?()
        })
    }
    
    func dropPlayer() {
        // this will raise a delegate call playerdropped
        self.didDrop = true
        grid.dropPlayer()
    }

}

extension GamePresenter: BlockGridDelegate {
    
    func playerRemoved() {
        view.removePlayer()
    }
    
    func blockGrid(_ blockGrid: BlockGrid, playerBlockRemoved block: Block) {
    }
    
    func blockGrid(_ blockGrid: BlockGrid, blocksRemoved blocks: [Block]) {
        // remove the blocks from the view too
        view.removeBlocks(blocks) {
            self.view.updateScore(self.game.score)
        }
    }
    
    func blockGrid(_ blockGrid: BlockGrid, playerDropedTo reference: GridReference) {
        view.movePlayer(reference, speed: 0.2, withShake: true) {
            blockGrid.replacePlayerWithBlocksOfType(.block)
            self.view.convertPlayerToBlocks(.block)
            self.applyEffects()
        }
    }
    
    func blockGrid(_ blockGrid: BlockGrid, playerMovedInDirection direction: BlockMoveDirection) {
        var speed:CGFloat = game.currentLevel.moveDuration
        if direction != .down {
            // left and right moves are faster than down
            speed = 0.1
        }
        
        view.movePlayer(direction, speed: speed) {
            if (direction == .down) {
                // check if the player has landed on something
                if (!blockGrid.canMovePlayer(.down)) {
                    blockGrid.replacePlayerWithBlocksOfType(.block)
                    self.view.convertPlayerToBlocks(.block)
                    
                    // when all the effects have been run the delegate will be called
                    self.applyEffects()
                    
                } else {
                    // just keep things moving
                    let _ = blockGrid.movePlayer(.down)
                }
            }
        }
    }
    
    func blockGrid(_ blockGrid: BlockGrid, playerAdded playerBlockResults: [BlockResult]) {
        let blocks = playerBlockResults.map { $0.block! }
        let references = playerBlockResults.map { $0.gridReference }
        if let origin = blockGrid.playerOrigin {
            try? view.addPlayer(blocks, references: references, to: origin)
        } else {
            print("no origin")
        }
    }
    
    func blockGrid(_ blockGrid: BlockGrid, playerRotatedBy degrees: CGFloat) {
        view.rotatePlayer(degrees, completion: nil)
    }

    func blockGrid(_ blockGrid: BlockGrid, blockMoved block: Block, to: GridReference) {
        view.moveBlock(block, to: to) {
            // just in case this move created a match
            //self.removeMatches()
        }
    }
    
    func blockGrid(_ blockGrid: BlockGrid, blocksMoved blocks: [Block], to: [GridReference]) {
        view.moveBlocks(blocks, to: to) {
            // whenever we move blocks, we check for any colour matches
            //self.removeMatches()
        }
    }
    
    func blockGrid(_ blockGrid: BlockGrid, blockAdded block: Block, reference: GridReference) {
        view.addBlock(block, reference: reference, completion: nil)
    }
    
    func blockGrid(_ blockGrid: BlockGrid, blockRemoved block: Block) {
        view.removeBlock(block) {
            // drop any suspended blocks
            //self.applyGravity()
        }
    }
    
    func blockGrid(_ blockGrid: BlockGrid, blocksRotated blocks: [Block], degrees: CGFloat) {
        view.rotatePlayer(degrees, completion: nil)
    }
    
}

extension GamePresenter: EffectsRunnerDelegate {
    
    func didFinishEffectsRun(_ runner: EffectsRunner, achievements: Achievements) {
        
        let level = self.game.currentLevel
        // append the achievements to the level
        self.game.levelAchievements.merge(achievements)
        
        let points = level.pointsFor(achievements, hardDrop: self.didDrop)
        self.didDrop = false
        
        self.view.displayPoints(points, from: GridReference(5,10))
        self.game.score += points
        self.view.updateScore(self.game.score)
        
        self.view.updateLevelProgress(level.goalProgressDescription(self.game.levelAchievements), progress: Double(level.goalProgressValue(self.game.levelAchievements))/Double(level.goalValue))
        
        // see if level complete
        if game.currentLevel.goalAchieved(self.game.levelAchievements) {
            nextLevel()
        } else {
            self.addNewPlayer()
        }
    }
}

// MARK: - Game Viper Components
private extension GamePresenter {
    var view: GameViewApi {
        return _view as! GameViewApi
    }
    var interactor: GameInteractorApi {
        return _interactor as! GameInteractorApi
    }
    var router: GameRouterApi {
        return _router as! GameRouterApi
    }
}
