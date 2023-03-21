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
    
    private var gameLoopInterval = TimeInterval(1)
    
    private var gamePaused: Bool = true
    
    private var grid: BlockGrid!
    
    private var gridEffects = [GridEffect]()
    
    private var isDropping: Bool = false
    
    override func viewHasLoaded() {
        interactor.createNewGame()
    }
    
}

// MARK: - GamePresenter API
extension GamePresenter: GamePresenterApi {
    
    // MARK: - From Interactor
    
    func didFetchNextLevel(_ level: Level) {
        
        // remember the gameLoopInterval
        self.gameLoopInterval = level.moveDuration
        self.gridEffects = level.effects
        
        // Update the view
        view.displayLevel(level.number)
        
        // Remove all the blocks and the player
        let blocks = grid.getAll().map { $0.block! }
        grid.removeBlocks(grid.getAll().map { $0.gridReference }, suppressDelegateCall: true)
        grid.replacePlayerWithBlocksOfType(.block)
        view.removeBlocks(blocks) {
            self.interactor.didLoadLevel()
        }
    }
    
    func didUpdateTotals(points: Int, score: Int, rows: Int) {
        view.displayPoints(points, from: GridReference(5,10))
        view.updateScore(score)
        view.updateLevelProgress(rows, progress: 0)
    }
    
    func addNewShape(_ shape: Shape, nextShape: Shape, pauseBeforeStarting: Bool = false) {
        view.displayNextShape(nextShape)
        if pauseBeforeStarting {
            self.gamePaused = true
            view.stopGameLoop()
        } else {
            self.gamePaused = false
            view.startGameLoop(gameLoopInterval)
        }
        if let result = try? grid.addShape(shape) {
            if result {
                if let ghostReference = grid.playerCanDropTo {
                    view.showShapeGhost(at: ghostReference)
                }
            } else {
                // can't add a new player because there's no room :-(
                self.lifeLost()
            }
        } else {
            view.stopGameLoop()
        }
    }
    
    func didEndGame() {
        // game completed! no more levels
    }
    
    // MARK: - From View
    
    func didSelectPause() {
        if gamePaused {
            view.startGameLoop(self.gameLoopInterval)
        } else {
            view.stopGameLoop()
        }
        gamePaused = !gamePaused
    }
    
    func didUpdateGameLoop() {
        guard !gamePaused else { return }
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
    
    func didCreateNewGame(_ rows: Int, _ columns: Int) {
        self.grid = try! BlockGrid(rows: rows, columns: columns)
        grid.delegate = self
        let all = grid.getAll()
        view.initialiseGame(rows: grid.rows, columns: grid.columns)
        view.addBlocks(all.map { $0.block! }, references: all.map { $0.gridReference }, completion: nil)
    }
    
    func didSelectMove(_ direction: BlockMoveDirection) {
        if !isDropping && !gamePaused {
            let _ = grid.movePlayer(direction)
        }
    }
    
    func didSelectDrop() {
        if !isDropping && !gamePaused {
            self.isDropping = true
            grid.dropPlayer()
        }
    }
    
    func didSelectRotate() {
        if !isDropping && !gamePaused {
            let _ = grid.rotateShape()
        }
    }
    
    private func lifeLost() {
        view.stopGameLoop()
    }
    
    private func applyEffects() {
        self.grid.replacePlayerWithBlocksOfType(.block)
        self.view.convertShapeToBlocks(.block)
        
        let runner = EffectsRunner(grid: grid, effects: self.gridEffects)
        runner.applyEffectsToView = self.applyEffectsToView
        runner.delegate = self
        
        runner.applyEffects()
    }
    
    private func applyEffectsToView(_ effects: EffectResult, completion: (()->Void)?) {
        let dispatch = DispatchGroup()
        
        // Apply removes
        if effects.blocksRemoved.count > 0 {
            dispatch.enter()
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
    
}

extension GamePresenter: SettingsDelegate {
    func didUpdateSettings(_ settings: Settings) {
        view.showGrid(settings.showGrid)
    }
}

extension GamePresenter: BlockGridDelegate {
    
    func didSelectSettings() {
        router.showSettings()
    }
    
    func shapeRemoved() {
        view.removeShape()
    }
    
    func blockGrid(_ blockGrid: BlockGrid, blocksRemoved blocks: [Block]) {
        // remove the blocks from the view too
        view.removeBlocks(blocks) {
            //self.view.updateScore(self.game.score)
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
        interactor.recordAchievements(achievements, with: self.isDropping)
        self.isDropping = false
        interactor.readyForNewShape()
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
