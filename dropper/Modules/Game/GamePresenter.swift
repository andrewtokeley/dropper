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
    
    private var isRotating = false
    
    private var nextShape: Shape?
    
    private var gameLoopInterval = TimeInterval(1)
    
    private var gamePaused: Bool = true
    
    private var grid: BlockGrid!
    
    private var gridEffects = [GridEffect]()
    
    private var isDropping: Bool = false
    
    private var setup: GameSetupData?
    
    /**
     This is the entry point for the Module and kicks of the Interactor's first call to create a new Game instance for the given genre.
     */
    override func setupView(data: Any) {
        self.setup = data as? GameSetupData
    }
    
    override func viewIsAboutToAppear() {
        if let setup = self.setup {
            if let state = self.setup?.state {
                interactor.restoreFromState(state)
            } else {
                interactor.createNewGame(setup.title)
            }
        }
    }

    private func gameOver() {
        view.stopGameLoop()
        
        self.interactor.clearState()
        self.interactor.saveScores { (highscore) in
            
            let title = highscore ? "Highscore!" : "Oh No!"
            let message = highscore ? "The blocks beat you, but that's a great score!" : "The blocks beat you this time!"
            let action = ModalDialogAction(title: "Close", style: .default) { _ in
                self.router.navigateHome()
            }
            self.view.displayModalDialog(title: title, message: message, actions: [action])
            
//            self.router.showPopup(title: title, message: message, primaryButtonText: closeButtonText, secondaryButtonText: nil) { buttonText in
//                    self.router.navigateHome()
//            }
        }
    }
    
}

// MARK: - GamePresenterApi

extension GamePresenter: GamePresenterApi {
    
    // MARK: - From Interactor
    
    func didRestoreState(_ state: GameState, settings: Settings) {
        //didCreateNewGame(rows: state.rows, columns: state.columns, settings: settings)
    }
    
    func didCreateNewGame(game: Game, settings: Settings) {
        
        self.grid = game.grid
        self.grid.delegate = self
        
        // create the initial ui interface
        view.initialiseGame(rows: game.rows, columns: game.columns, showGrid: settings.showGrid)
        
        // add the blocks
        let all = grid.getAll()
        view.addBlocks(all.map { $0.block! }, references: all.map { $0.gridReference }, completion: nil)
        view.showGrid(settings.showGrid)
        view.showGhost(settings.showGhost)
    }
    
    func didFetchNextLevel(_ level: Level, fromState: Bool = false) {
        
        // pause the game play until we're ready.
        self.view.stopGameLoop()
        
        // set the level specific attributes
        self.gameLoopInterval = level.moveDuration
        self.gridEffects = level.effects
        
        // Update the level number
        self.view.displayLevel(level.number)
        
        // Remove all the blocks and the player
        
        let title = level.number == 1 ? "Get Ready!" : "Next Level!"
        let primaryButton = level.number == 1 ? "Start!" : "Let's Go!"
        let message = level.goalDescription
        let startGameAction = ModalDialogAction(title: primaryButton, style: .default, handler: { _ in
            self.interactor.didLoadLevel()
        })
        let goHomeAction =  ModalDialogAction(title: "Cancel", style: .cancel, handler: { _ in
            self.router.navigateHome()
        })
        
        if !fromState {
            let blocks = self.grid.getAll().map { $0.block! }
            self.grid.removeBlocks(self.grid.getAll().map { $0.gridReference }, suppressDelegateCall: true)
            self.grid.replacePlayerWithBlocksOfType(.block)
            
            self.view.removeBlocks(blocks) {
                self.view.displayModalDialog(title: title, message: message, actions: [startGameAction])
            }
        } else {
            // The user is continuing a game from state.
            startGameAction.title = "OK"
            self.view.displayModalDialog(title: "Continue", message: "Right, let's keep going!", actions: [startGameAction, goHomeAction])
        }
    }
    
    func didUpdateTotals(points: Int? = nil, score: Int? = nil, goalProgressValue: Int? = nil, goalUnit: String?) {
        if let points = points {
            view.displayPoints(points, from: GridReference(5,10))
        }
        if let score = score {
            view.updateScore(score)
        }
        if let goalProgressValue = goalProgressValue {
            view.updateLevelProgress(goalProgressValue, goalUnit: goalUnit)
        }
    }
    
    func addNewShape(_ shape: Shape, nextShape: Shape, pauseBeforeStarting: Bool = false) {
        view.displayNextShape(nextShape)
        if let result = try? grid.addShape(shape) {
            if result {
                self.gamePaused = false 
                view.startGameLoop(gameLoopInterval)
            } else {
                // can't add a new player because there's no room :-(
                self.gameOver()
            }
        } else {
            view.stopGameLoop()
        }
    }
    
    func didWinGame() {
        interactor.clearState()
        let action = ModalDialogAction(title: "Close", style: .cancel) { _ in
            self.router.navigateHome()
        }
        view.displayModalDialog(title: "You Won!", message: "Nice one :-)", actions: [action])
    }
    
    // MARK: - From View
    
    func willCloseView(completion: @escaping (Bool)->Void) {
        view.stopGameLoop()
        interactor.saveState()
        router.navigateHome()
    }
    
    func didSelectSettings() {
        didSelectPause()
        if let title = setup?.title {
            router.showSettings(title)
        }
    }
    
    func didSelectPause() {
        view.setPauseState(true)
        gamePaused = true
        view.stopGameLoop()
    }
    
    func didSelectUnPause() {
        view.setPauseState(false)
        gamePaused = false
        view.startGameLoop(self.gameLoopInterval)
    }
    
    func didSelectPauseToggle() {
        if gamePaused {
            didSelectUnPause()
        } else {
            didSelectPause()
        }
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
        if !isDropping && !gamePaused && !isRotating {
            isRotating = true
            let result = grid.rotateShape()
            if !result {
                isRotating = false
            }
        }
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
        view.showGhost(settings.showGhost)
    }
}

// MARK: - BlockGridDelegate

extension GamePresenter: BlockGridDelegate {
    
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
//            blockGrid.replacePlayerWithBlocksOfType(.block)
//            self.view.convertShapeToBlocks(.block)
            self.applyEffects()
        }
    }
    
    func blockGrid(_ blockGrid: BlockGrid, shapeMovedInDirection direction: BlockMoveDirection) {
        if let ghostReference = grid.playerCanDropTo {
            view.showShapeGhost(at: ghostReference)
        }
        if direction == .left || direction == .right {
            view.moveShape(direction, speed: 0.0, completion: nil)
        }
        
    }
    
    func blockGrid(_ blockGrid: BlockGrid, shapeAdded: Shape, to: GridReference) {
        view.addShape(shapeAdded, to: to)
        if let ghostReference = grid.playerCanDropTo {
            view.showShapeGhost(at: ghostReference)
        }
    }
    
    func blockGrid(_ blockGrid: BlockGrid, shapeRotatedBy degrees: CGFloat, withKick moveTo: GridReference) {
        view.moveShape(moveTo, speed: 0, withShake: false) {
            self.isRotating = false
            self.view.rotateShape(degrees) {
                if let ghostReference = self.grid.playerCanDropTo {
                    self.view.showShapeGhost(at: ghostReference)
                }
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
    
}

extension GamePresenter: EffectsRunnerDelegate {
    
    func didFinishEffectsRun(_ runner: EffectsRunner, achievements: Achievements) {
        
        interactor.recordAchievements(achievements, with: self.isDropping)
        self.isDropping = false
        
        interactor.saveState()
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
