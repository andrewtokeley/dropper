//
//  GameModuleApi.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/02/23.
//
//

import Viperit

//MARK: - GameRouter API
protocol GameRouterApi: RouterProtocol {
    func showSettings(_ title: GameTitle)
    func navigateHome()
}

//MARK: - GameView API
protocol GameViewApi: UserInterfaceProtocol {
    
    //MARK: - Presenter -> View
    
    /**
     Called by the Presenter to get the View to render and empty state, with an empty grid and display elements, but before any Shapes are added.
     */
    func initialiseGame(rows: Int, columns: Int, showGrid: Bool)
    
    /**
     Adds a new shape to the grid, where the shape's origin will be located at the specified reference.
     */
    func addShape(_ shape: Shape, to: GridReference)
    
    /**
     Called by the Presenter to get the View to start the game loop. Once set the View will call the Presenter's ``didUpdateGameLoop`` method every ``loopTimeInterval`` seconds.
     */
    func startGameLoop(_ loopTimeInterval: TimeInterval)
    
    /**
     Called by the Presenter to stop the game loop from firing. Essentially pausing the game.
     */
    func stopGameLoop()
    
    //MARK: Display/Move Shapes and Blocks
    /**
     Adds a new Ghost shape to the grid, where the shape's origin will be located at the specified reference.
     */
    func showShapeGhost(at: GridReference)
    
    
    /**
     Rotates the active shape clockwise by the specified number of degress
     */
    func rotateShape(_ degrees: CGFloat, completion: (()->Void)?)
    
    /**
     Moves the active shape in the given direction, by one block
     */
    func moveShape(_ direction: BlockMoveDirection, speed: CGFloat, completion: (()->Void)?)
    
    /**
     Moves the active shape to a new location and optionally applies a shaking motion to other blocks in the grid. This is typically the result of a player selecting to drop the shape.
     */
    func moveShape(_ reference: GridReference, speed: CGFloat, withShake: Bool, completion: (()->Void)?)
    
    /**
     Removes the active shape from the grid
     */
    func removeShape()
    
    /**
     Converts the active shape to be regular blocks. This typically happens when a shape lands and can't move anymore and before effects are run on the grid.
     */
    func convertShapeToBlocks(_ type: BlockType)
    
    func addBlocks(_ blocks: [Block], references: [GridReference], completion: (()->Void)?)
    func addBlock(_ block: Block, reference: GridReference, completion: (()->Void)?)
    func moveBlock(_ block: Block, to: GridReference, completion: (()->Void)?)
    func moveBlocks(_ blocks: [Block], to: [GridReference], completion: (()->Void)?)
    func removeBlock(_ block: Block, completion: (()->Void)?)
    func removeBlocks(_ blocks: [Block], completion: (()->Void)?)

    //MARK: Display update methods
    
    func updateScore(_ score: Int)
    func displayPoints(_ points: Int, from: GridReference)
    func displayNextShape(_ shape: Shape)
    func displayLevel(_ levelNumber: Int)
    func updateLevelProgress(_ progressValue: Int, goalUnit: String?)
    func showGrid(_ show: Bool)
    func showGhost(_ show: Bool)
    func setPauseState(_ pause: Bool)
    
    func displayModalDialog(title: String, message: String, actions: [ModalDialogAction]) 
}

//MARK: - GamePresenter API
protocol GamePresenterApi: PresenterProtocol {
    
    //MARK: - View -> Presenter
    /**
     Called by the View just before it's about to close itself. The View will use the completionThe Presenter can call the completion closure passing in a flag to cancel the close.
     
     If there is no competion handler, the View will close.
     */
    func willCloseView(completion: @escaping (Bool)->Void)
    
    /**
     Called by the View when the play selects to move the active Shape in the given direction
     */
    func didSelectMove(_ direction: BlockMoveDirection)
    
    /**
     Called by the View when the play selects to (un)pause the game
     */
    func didSelectPauseToggle()
    
    /**
     Called by the View when the player selects to drop the active Shape
     */
    func didSelectDrop()
    
    /**
     Called by the View when the player wants to rotate the active Shape
     */
    func didSelectRotate()
    
    /**
     Called by the View when the player selects to view the settings page
     */
    func didSelectSettings()
    
    /**
     Called by the View to let the Presenter know the game loop has made another pass and it's time to move the active Shape down
     */
    func didUpdateGameLoop()

    //MARK: - Interactor -> Presenter
    
    /**
     Called by Interactor when a game has been restored from state. The Presenter will work with the View to update levels and scores and add the blocks back to the grid.
     */
    func didRestoreState(_ state: GameState, settings: Settings)
    
    /**
     Called by Interactor when a ``Game`` instance has been created the Presenter can now communicate with the View to put stuff on the screen ready to play.
     */
    func didCreateNewGame(game: Game, settings: Settings)
    
    /**
     Called by the Interactor whenever a new level is ready to be played. The Presenter will reset the UI, update the level description and initiate a new player by calling back to the Interactor via the ``didLoadLevel`` method.
     */
    func didFetchNextLevel(_ level: Level, fromState: Bool)
    
    /**
     Called by Interactor to let the presenter know to add a new shape and display the next shape
     */
    func addNewShape(_ shape: Shape, nextShape: Shape, pauseBeforeStarting: Bool)
    
    /**
     Called by interactor to let the Presenter know some points/progress has been made. Each value can be set to nil, if there is no change.
     */
    func didUpdateTotals(points: Int?, score: Int?, goalProgressValue: Int?, goalUnit: String?)
        
    /**
     Called by the Interactor when all the levels have been completed
     */
    func didWinGame()
}

//MARK: - GameInteractor API
protocol GameInteractorApi: InteractorProtocol {
    
    //MARK: - Presenter -> Interactor
    
    func restoreFromState(_ state: GameState)
    
    /**
     The first call made by the Presenter when the module loads and we know what game genre we're playing.
     
     Calls back to the following Presenter methods;
     - ``didCreateNewGame(rows:columns:columnssettings)``
     - ``didFetchNextLevel(level)``
     -  ``didUpdateTotals(score:level:rows)``
     */
    func createNewGame(_ title : GameTitle)
    
    /**
     Record when some achievements have been gained. Achievements are earned whenever effects are run and the shape has stopped dropping
     
     Calls back to the following Presenter method(s);
     -  ``didUpdateTotals(score:level:rows)``
     */
    func recordAchievements(_ achievements: Achievements, with hardDrop: Bool)
    
    /**
     Called by the Presenter to let the Interactor know a new level has been loaded, blocks cleared, level number updated and the user is ready to continue.
     */
    func didLoadLevel()
    
    /**
     Called by the Presenter to let the Interactor know all the UI effects have been done and a new shape can be added, or a new level started in the case of enough rows being exploded.
     */
    func readyForNewShape()
    
    /**
     Saves the score at the end of the game and returns whether it was a highscore
     */
    func saveScores(completion: ((Bool)->Void)?)
    
    func saveState()
    func clearState()
}
