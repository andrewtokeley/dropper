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
    func showSettings()
}

//MARK: - GameView API
protocol GameViewApi: UserInterfaceProtocol {
    func initialiseGame(rows: Int, columns: Int)
    
    /**
     Adds a new shape to the grid, where the shape's origin will be located at the specified reference.
     */
    func addShape(_ shape: Shape, to: GridReference)
    
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
    
    func updateScore(_ score: Int)
    func displayPoints(_ points: Int, from: GridReference)
    func displayNextShape(_ shape: Shape)
    func displayLevel(_ levelNumber: Int)
    func updateLevelProgress(_ progressValue: Int, progress: Double)
    
    func showGrid(_ show: Bool)
    
    func startGameLoop(_ loopTimeInterval: TimeInterval)
    func stopGameLoop()
}

//MARK: - GamePresenter API
protocol GamePresenterApi: PresenterProtocol {
    func didSelectMove(_ direction: BlockMoveDirection)
    func didSelectPause()
    func didSelectDrop()
    func didSelectRotate()
    func didSelectNewGame()
    func didSelectSettings()
    func didUpdateGameLoop()
    
    // from interactor
    
    /**
     Called by Interactor when a new grid, game and levels have been created
     */
    func didCreateNewGame(_ rows: Int, _ columns: Int)
    
    /**
     Called by Interactor to let Presenter know to load a new level
     */
    func didFetchNextLevel(_ level: Level)
    
    /**
     Called by Interactor to let the presenter know to add a new shape and display the next shape
     */
    func addNewShape(_ shape: Shape, nextShape: Shape, pauseBeforeStarting: Bool)
    
    /**
     Called by interactor to let the presenter know some points/progress has been made
     
     */
    func didUpdateTotals(points: Int, score: Int, rows: Int)
        
    /**
     Called by the Interactor when the game is over.
     */
    func didEndGame()
}

//MARK: - GameInteractor API
protocol GameInteractorApi: InteractorProtocol {
    func createNewGame()
    
    /**
     Record when some achievements have been gained.
     
     Achievements are earned whenever effects are run and the shape has stopped dropping
     */
    func recordAchievements(_ achievements: Achievements, with hardDrop: Bool)
    
    /**
     Called by the Presenter to let the Interactor know the grid and level have been loaded and it's time to play the level.
     */
    func didLoadLevel()
    
    /**
     Called by the Presenter to let the Interactor know all the UI effects have been done and a new shape can be added, or a new level started in the case of enough rows being exploded.
     */
    func readyForNewShape()
}
