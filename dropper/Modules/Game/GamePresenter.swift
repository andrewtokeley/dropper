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

/**
 The Presenter coordinates the messages between the Interactor and the View. The basic game loop looks like;
 
 - interactor.createNewGame
    - presenter.didCreateNewGame
        - view.initialiseGame
        - view.displayTitle
    - presenter.didFetchNextLevel
        - view.stopGameLoop
        - view.displayLevel
        - view.updateLevelProgress
        - interactor.didLoadLevel()
            - presenter.addNewShape
                - view.displayNextShape(nextShape)
                - view.startGameLoop
 - presenter.didUpdateGameLoop
    - view.moveShape
    - (when you can't move anymore) applyEffects
        - view.convertShapeToBlocks
 - didFinishEffectsRun (after all effects processed)
    - interactor.recordAchievements
    - interactor.saveState
    - interactor.readyForNextShape
        - presenter.addNewShape (if goal not yet achieved)
        - presenter.didFetchNextLevel (if goal achieved, continue as above)
*/
final class GamePresenter: Presenter {
    
    private var isRotating = false
    
    private var nextShape: Shape?
    
    private var gameLoopInterval = TimeInterval(1)
    
    private var gamePaused: Bool = true
    
    private var grid: BlockGrid!
    
    private var gridEffects = [GridEffect]()
    
    private var isDropping: Bool = false
    
    private var setup: GameSetupData?
    
    private var hapticsEnabled: Bool = false
    
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
            let action = ModalDialogAction(title: "Close", style: .standard) { _ in
                self.router.navigateHome()
            }
            self.view.displayModalDialog(title: title, message: message, actions: [action])
        }
    }
    
}

// MARK: - GamePresenterApi

extension GamePresenter: GamePresenterApi {
    
    // MARK: - From Interactor
    
    func enableHaptics(_ enabled: Bool) {
        hapticsEnabled = enabled
    }
    
    func didRestoreState(_ state: GameState, settings: Settings) {
        //didCreateNewGame(rows: state.rows, columns: state.columns, settings: settings)
    }
    
    func didCreateNewGame(game: Game, settings: Settings) {
        
        self.grid = game.grid
        self.grid.delegate = self
        
        // create the initial ui interface
        view.initialiseGame(rows: game.rows, columns: game.columns, showGrid: settings.showGrid)
        
        view.displayTitle(game.title.title)
        
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
        let startGameAction = ModalDialogAction(title: primaryButton, style: .standard, handler: { _ in
            if (!fromState) {
                self.view.updateLevelProgress(0, goalUnit: nil)
                if let initialBlocks = level.initialBlocks {
                    let _ = self.grid.addBlocks(blocks: initialBlocks.0, references: initialBlocks.1)
                }
            }
            self.interactor.didLoadLevel()
        })
        
        if !fromState {
            let blocks = self.grid.getAll().map { $0.block! }
            self.grid.removeBlocks(self.grid.getAll().map { $0.gridReference }, suppressDelegateCall: true)
            self.grid.replaceShapeWithBlocksOfType(.block)
            
            self.view.removeBlocks(blocks) {
                self.view.displayModalDialog(title: title, message: message, actions: [startGameAction])
            }
        } else {
            // The user is continuing a game from state.
            startGameAction.title = "OK"
            self.view.displayModalDialog(title: "Continue", message: "Right, let's keep going!", actions: [startGameAction])
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
        // some edge case where you're rotating when you land but we don't
        self.isRotating = false
        
        // update the next shape
        view.displayNextShape(nextShape)
        
        //
        if grid.addShapeTopCentre(shape) {
            self.gamePaused = false
            view.startGameLoop(gameLoopInterval)
        } else {
            // can't add a new player because there's no room :-(
            self.gameOver()
            view.stopGameLoop()
        }
    }
    
    func didWinGame() {
        self.interactor.clearState()
        self.interactor.saveScores { (highscore) in
            
            let title = "Completed!"
            let message = highscore ? "You completed all the levels and got a new high score!" : "You completed all the levels - great effort!"
            let action = ModalDialogAction(title: "Close", style: .standard) { _ in
                self.router.navigateHome()
            }
            self.view.displayModalDialog(title: title, message: message, actions: [action])
        }
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

        if grid.moveShape(.down) {
            view.moveShape(.down, speed: 0.1, completion: nil)
        } else {
            // you've hit the ground or landed on another block
            view.stopGameLoop()
            applyEffects()
        }
    }
    
    func didSelectMove(_ direction: BlockMoveDirection) {
        if !isDropping && !gamePaused {
            let _ = grid.moveShape(direction)
        }
    }
    
    func didSelectDrop() {
        if !isDropping && !gamePaused {
            self.isDropping = true
            grid.dropShape()
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
        self.grid.replaceShapeWithBlocksOfType(.block)
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
            self.view.removeBlocks(effects.blocksRemoved.map { $0.block! }) {
                if self.hapticsEnabled {
                    print("haptics!")
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
                dispatch.leave()
            }
        }
        
        // Apply moves
        if effects.blocksMoved.count > 0 {
            dispatch.enter()
            self.view.moveBlocks(effects.blocksMoved.map { $0.block! }, to: effects.blocksMovedTo) {
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
        enableHaptics(settings.enableHaptics)
    }
}

// MARK: - BlockGridDelegate

extension GamePresenter: BlockGridDelegate {
    
    func shapeRemoved() {
        view.removeShape()
    }
    
    func blockGrid(_ blockGrid: BlockGrid, blocksRemoved blocks: [Block]) {
        view.removeBlocks(blocks) {
            // should we wait?
        }
    }
    
    func blockGrid(_ blockGrid: BlockGrid, shapeDropedTo reference: GridReference) {
        view.stopGameLoop()
        view.moveShape(reference, speed: 0.1, withShake: true) {
            self.applyEffects()
        }
    }
    
    func blockGrid(_ blockGrid: BlockGrid, shapeMovedInDirection direction: BlockMoveDirection) {
        if let ghostReference = grid.shapeCanDropTo {
            view.showShapeGhost(at: ghostReference)
        }
        if direction == .left || direction == .right {
            view.moveShape(direction, speed: 0.0, completion: nil)
        }
        
    }
    
    func blockGrid(_ blockGrid: BlockGrid, shapeAdded: Shape, to: GridReference) {
        view.addShape(shapeAdded, to: to)
        if let ghostReference = grid.shapeCanDropTo {
            view.showShapeGhost(at: ghostReference)
        }
    }
    
    func blockGrid(_ blockGrid: BlockGrid, shapeRotatedBy degrees: CGFloat, withKickMove moveTo: GridReference) {
        view.moveShape(moveTo, speed: 0, withShake: false) {
            self.view.rotateShape(degrees) {
                self.isRotating = false
                if let ghostReference = self.grid.shapeCanDropTo {
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
    func blockGrid(_ blockGrid: BlockGrid, blocksAdded blocks: [Block], references: [GridReference]) {
        view.addBlocks(blocks, references: references) {
            //
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
    
}

extension GamePresenter: EffectsRunnerDelegate {
    
    func didFinishEffectsRun(_ runner: EffectsRunner, achievements: Achievements) {
        self.isRotating = false
        
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
