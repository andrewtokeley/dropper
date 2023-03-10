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
    func addPlayer(_ blocks: [Block], to: GridReference) throws
    func addPlayer(_ blocks: [Block], references: [GridReference], to: GridReference) throws
    func rotatePlayer(_ degrees: CGFloat, completion: (()->Void)?)
    func movePlayer(_ direction: BlockMoveDirection, speed: CGFloat, completion: (()->Void)?)
    func removePlayerBlock(_ block: Block, completion: (()->Void)?)
    func removePlayer()
    func convertPlayerToBlocks(_ type: BlockType)
    
    func addBlocks(_ blocks: [Block], references: [GridReference], completion: (()->Void)?)
    func addBlock(_ block: Block, reference: GridReference, completion: (()->Void)?)
    func moveBlock(_ block: Block, to: GridReference, completion: (()->Void)?)
    func moveBlocks(_ blocks: [Block], to: [GridReference], completion: (()->Void)?)
    func removeBlock(_ block: Block, completion: (()->Void)?)
    func removeBlocks(_ blocks: [Block], completion: (()->Void)?)
    
    func updateScore(_ score: Int)
}

//MARK: - GamePresenter API
protocol GamePresenterApi: PresenterProtocol {
    func didSelectMove(_ direction: BlockMoveDirection)
    func didSelectDrop()
    func didSelectRotate()
    func didCreateNewGame(_ grid: BlockGrid)
    func didSelectNewGame()
}

//MARK: - GameInteractor API
protocol GameInteractorApi: InteractorProtocol {
    func createNewGame()
}
