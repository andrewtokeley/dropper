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
    func displayLevel(_ level: Level)
    func updateLevelProgress(_ progressValue: Int, progress: Double)
    
    func startGameLoop(_ loopTimeInterval: TimeInterval)
    func stopGameLoop()
}

//MARK: - GamePresenter API
protocol GamePresenterApi: PresenterProtocol {
    func didSelectMove(_ direction: BlockMoveDirection)
    func didSelectPause()
    func didSelectDrop()
    func didSelectRotate()
    func didCreateNewGame(game: Game, grid: BlockGrid)
    func didSelectNewGame()
    
    func didUpdateGameLoop()
}

//MARK: - GameInteractor API
protocol GameInteractorApi: InteractorProtocol {
    func createNewGame()
}
