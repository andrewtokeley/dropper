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
    
    private var grid: BlockGrid!
    private var score: Int = 0
    
    override func viewHasLoaded() {
        interactor.createNewGame()
    }
    
}

// MARK: - GamePresenter API
extension GamePresenter: GamePresenterApi {
    
    func didSelectNewGame() {
        interactor.createNewGame()
    }
    
    func didCreateNewGame(_ grid: BlockGrid) {
        self.grid = grid
        grid.delegate = self
        
        let all = grid.getAll()
        view.initialiseGame(rows: grid.rows, columns: grid.columns)
        
        view.addBlocks(all.map { $0.block! }, references: all.map { $0.gridReference }, completion: nil)
        
        addNewPlayer()
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
        if let playerAdded = try? grid.addPlayer(Shape.random(BlockColour.random)) {
            if (playerAdded) {
                
                // this will start the player falling
                let result = grid.movePlayer(.down)
                if result {
                    //removeMatches()
                }
                
            } else {
                // life lost
                print("Life Lost")
            }
        } else {
            print("Life LOST")
        }
    }
 
    /**
     Remove matched blocks, resulting in ``blockGrid(_:blocksRemoved:)`` being called to allow the view to replicate the removals.
     
     - Parameter stopIfNoEffect: if applying the effect results in no change and this flag is set to true, it can be assumed that we can stop running other effects and another player can be added to the board. The default is ``False``
     */
    func removeMatches(stopIfNoEffect: Bool = false) {
        let match = RemoveRowsEffect(grid: grid)
        if !match.apply() {
            // nothing was removed, can we stop?
            if !stopIfNoEffect {
                // keep going with other effects
                applyGravity(stopIfNoEffect: true)
            } else {
                // either add a new player or keep moving the player
                let didMove = grid.movePlayer(.down)
                if !didMove {
                    addNewPlayer()
                }
            }
        }
    }
    
    /**
     Apply gravity to drop any suspended blocks. If any blocks need dropping the ``blockGrid(_:blocksMoved:to:)`` method will be called to allow the view to respond accordingly.
     
     - Parameter stopIfNoEffect: if applying the effect results in no change and this flag is set to true, it can be assumed that we can stop running other effects and another player can be added to the board. The default is ``False``
     */
    func applyGravity(stopIfNoEffect: Bool = false) {
        let drop = DropIntoEmptyRowsEffect	(grid: grid)
        if !drop.apply() {
            // nothing was removed, can we stop?
            if !stopIfNoEffect {
                // keep going with the remove effect, but let it know that since nothing dropped it can stop calling back here if nothing is matched
                removeMatches(stopIfNoEffect: true)
            } else {
                // all the effects have run and no changes happened, so if the player can still move, otherwise set up a new player
                let didMove = grid.movePlayer(.down)
                if !didMove {
                    grid.replacePlayerWithBlocksOfType(.block)
                    view.convertPlayerToBlocks(.block)
                    addNewPlayer()
                }
            }
        }
    }
    
    func dropPlayer() {
        let _ = grid.movePlayer(.down)
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
            self.score += 15 * blocks.count
            self.view.updateScore(self.score)
            
            // whenever blocks are removed, we want to apply gravity to drop blocks into the spaces created
            self.applyGravity(stopIfNoEffect: true)
            
        }
    }
    
    func blockGrid(_ blockGrid: BlockGrid, playerMovedInDirection direction: BlockMoveDirection) {
        var speed:CGFloat = 0.2
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
                    
                    // check if the player has connected with blocks to make a match
                    self.removeMatches()
                } else {
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
            self.removeMatches()
        }
    }
    
    func blockGrid(_ blockGrid: BlockGrid, blocksMoved blocks: [Block], to: [GridReference]) {
        view.moveBlocks(blocks, to: to) {
            // whenever we move blocks, we check for any colour matches
            self.removeMatches()
        }
    }
    
    func blockGrid(_ blockGrid: BlockGrid, blockAdded block: Block, reference: GridReference) {
        view.addBlock(block, reference: reference, completion: nil)
    }
    
    func blockGrid(_ blockGrid: BlockGrid, blockRemoved block: Block) {
        view.removeBlock(block) {
            // drop any suspended blocks
            self.applyGravity()
        }
    }
    
    func blockGrid(_ blockGrid: BlockGrid, blocksRotated blocks: [Block], degrees: CGFloat) {
        view.rotatePlayer(degrees, completion: nil)
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
