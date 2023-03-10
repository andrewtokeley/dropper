//
//  GameInteractor.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/02/23.
//
//

import Foundation
import Viperit

// MARK: - GameInteractor Class
final class GameInteractor: Interactor {
}

// MARK: - GameInteractor API
extension GameInteractor: GameInteractorApi {
    func createNewGame() {
        let grid = try! BlockGrid(rows: 18, columns: 10)
        
//        grid.addBlock(block: Block(.ground,.wall), reference: GridReference(6,3))
//        
//        grid.addBlock(block: Block(.ground,.wall), reference: GridReference(6,5))
//        
//        grid.addBlock(block: Block(.orange,.block), reference: GridReference(5,4))
//        grid.addBlock(block: Block(.ground, .wall), reference: GridReference(4,4))
//        
//
//        grid.addBlock(block: Block(.ground, .wall), reference: GridReference(6,4))
//        grid.addBlock(block: Block(.ground, .wall), reference: GridReference(6,5))
//        grid.addBlock(block: Block(.ground, .wall), reference: GridReference(6,6))
//        grid.addBlock(block: Block(.ground, .wall), reference: GridReference(6,7))
//        grid.addBlock(block: Block(.ground, .wall), reference: GridReference(6,8))
//        
        presenter.didCreateNewGame(grid)
    }
    
}

// MARK: - Interactor Viper Components Api
private extension GameInteractor {
    var presenter: GamePresenterApi {
        return _presenter as! GamePresenterApi
    }
}
