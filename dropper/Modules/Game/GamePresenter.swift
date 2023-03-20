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
    
    private var gamePaused: Bool = false
    
    private var game: Game!
    
    private var grid: BlockGrid!
    
    private var isDropping: Bool = false
    
    /// Flag to store whether the grid has changed and requires special effects to be processed.
    private var requireEffectsCheck = false
    
    override func viewHasLoaded() {
        interactor.createNewGame()
    }
    
}

// MARK: - GamePresenter API
extension GamePresenter: GamePresenterApi {
    
    func didSelectPause() {
        if gamePaused {
            view.startGameLoop(self.game.currentLevel.moveDuration)
        } else {
            view.stopGameLoop()
        }
        gamePaused = !gamePaused
    }
    
    func didUpdateGameLoop() {
        if grid.movePlayer(.down) {
            view.moveShape(.down, speed: 0.1, completion: nil)
        } else {
            // you've hit the ground or landed on another block
            applyEffects()
        }
    }
    
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
        view.updateLevelProgress(0, progress: 0)
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
        if !isDropping && !gamePaused {
            let _ = grid.movePlayer(direction)
        }
    }
    
    func didSelectDrop() {
        if !isDropping && !gamePaused {
            dropPlayer()
        }
    }
    
    func didSelectRotate() {
        if !isDropping && !gamePaused {
            let _ = grid.rotateShape()
        }
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
            
            if let result = try? grid.addShape(shape) {
                // all good, start the game loop
                if result {
                    if let ghostReference = grid.playerCanDropTo {
                        print("add \(ghostReference)")  
                        view.showShapeGhost(at: ghostReference)
                    }
                    view.startGameLoop(self.game.currentLevel.moveDuration)
                } else {
                    // can't add a new player because there's no room :-(
                    self.lifeLost()
                }
            } else {
                view.stopGameLoop()
                print("Illegal player add")
            }
        }
    }
    
    private func lifeLost() {
        view.stopGameLoop()
        //view.displayLifeLost(livesLeft: self.game.lives)
    }
    
    private func applyEffects() {
        self.grid.replacePlayerWithBlocksOfType(.block)
        self.view.convertShapeToBlocks(.block)
        
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
        self.isDropping = true
        grid.dropPlayer()
    }

}

extension GamePresenter: BlockGridDelegate {
    
    func shapeRemoved() {
        view.removeShape()
    }
    
    func blockGrid(_ blockGrid: BlockGrid, blocksRemoved blocks: [Block]) {
        // remove the blocks from the view too
        view.removeBlocks(blocks) {
            self.view.updateScore(self.game.score)
        }
    }
    
    func blockGrid(_ blockGrid: BlockGrid, shapeDropedTo reference: GridReference) {
        view.stopGameLoop()
        view.moveShape(reference, speed: 0.1, withShake: true) {
            blockGrid.replacePlayerWithBlocksOfType(.block)
            self.view.convertShapeToBlocks(.block)
            self.applyEffects()
        }
    }
    
    func blockGrid(_ blockGrid: BlockGrid, shapeMovedInDirection direction: BlockMoveDirection) {
        guard direction == .left || direction == .right else { return }
        view.moveShape(direction, speed: 0.0, completion: nil)
        if let ghostReference = grid.playerCanDropTo {
            view.showShapeGhost(at: ghostReference)
        }
    }
    
    func blockGrid(_ blockGrid: BlockGrid, shapeAdded: Shape, to: GridReference) {
        view.addShape(shapeAdded, to: to)
    }
    
    func blockGrid(_ blockGrid: BlockGrid, shapeRotatedBy degrees: CGFloat) {
        view.rotateShape(degrees) {
            if let ghostReference = self.grid.playerCanDropTo {
                self.view.showShapeGhost(at: ghostReference)
            }
        }
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
        view.rotateShape(degrees, completion: nil)
    }
    
}

extension GamePresenter: EffectsRunnerDelegate {
    
    func didFinishEffectsRun(_ runner: EffectsRunner, achievements: Achievements) {
        
        let level = self.game.currentLevel
        self.game.levelAchievements.merge(achievements)
        let points = level.pointsFor(achievements, hardDrop: self.isDropping)
        self.isDropping = false
        
        self.view.displayPoints(points, from: GridReference(5,10))
        self.game.score += points
        self.view.updateScore(self.game.score)
        
        self.view.updateLevelProgress(level.goalProgressValue(self.game.levelAchievements), progress: Double(level.goalProgressValue(self.game.levelAchievements))/Double(level.goalValue))
        
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
