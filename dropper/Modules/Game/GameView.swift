//
//  GameView.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/02/23.
//
//

import UIKit
import Viperit
import SpriteKit
import PureLayout

//MARK: GameView Class
final class GameView: UserInterface {
    
    private var rows: Int = 10
    private var columns: Int = 10
    
    //MARK: - Subviews
    
    /**
     The scene that will present the game
     */
    var gameScene: GameScene? {
        return gameSKView.scene as? GameScene
    }
    
    /**
     The SKView that will host our scene
     */
    lazy var gameSKView: SKView = {
        let view = SKView()
        view.allowsTransparency = true
        view.ignoresSiblingOrder = true
        
        #if DEBUG
            view.showsFPS = true
            view.showsNodeCount = true
        #endif
        
        return view
    }()

    override func loadView() {
        super.loadView()
        view.addSubview(gameSKView)
        setConstraints()
    }
    
    private func setConstraints() {
        gameSKView.autoPinEdgesToSuperviewEdges()
    }
    
    // MARK: - Key Presses
    
    override var keyCommands: [UIKeyCommand]? {
        
        let left = UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(keyPress))
        
        let right = UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [], action: #selector(keyPress))
        
        let up = UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(keyPress))
        
        let down = UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(keyPress))
        
        let n = UIKeyCommand(action: #selector(keyPress), input: "n")
        let space = UIKeyCommand(action: #selector(keyPress), input: " ")
        
        return [left, right, up, down, n, space]
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc private func keyPress(sender: UIKeyCommand) {
        if let input = sender.input {
            switch input {
            case " ":
                if let gameScene = gameScene {
                    gameScene.isPaused = !gameScene.isPaused
                }
            case "n":
                presenter.didSelectNewGame()
            case UIKeyCommand.inputLeftArrow:
                presenter.didSelectMove(.left)
                return
            case UIKeyCommand.inputRightArrow:
                presenter.didSelectMove(.right)
                return
            case UIKeyCommand.inputDownArrow:
                presenter.didSelectDrop()
                return
            case UIKeyCommand.inputUpArrow:
                presenter.didSelectRotate()
            default: return
            }
        }
    }
    
}

//MARK: - GameView API

/**
 These are the methods that the presenter can call to get the view to present something to the user
 */
extension GameView: GameViewApi {
    
    func updateScore(_ score: Int) {
        gameScene?.updateScore(score)
    }
    func addPlayer(_ blocks: [Block], references: [GridReference], to: GridReference) throws {
        //
        try gameScene?.addPlayer(blocks, references: references, to: to)
    }
    
    
    func initialiseGame(rows: Int, columns: Int) {
        let scene = GameScene(rows: rows, columns: columns, size: self.view.bounds.size)
        scene.scaleMode = .resizeFill
        gameSKView.presentScene(scene)
    }
    
    func addBlocks(_ blocks: [Block], references: [GridReference], completion: (()->Void)? = nil) {
        gameScene?.addBlocks(blocks: blocks, to: references) {
            completion?()
        }
    }
    
    func addBlock(_ block: Block, reference: GridReference, completion: (()->Void)? = nil) {
        gameScene?.addBlock(block: block, to: reference) {
            completion?()
        }
    }
    
    func moveBlock(_ block: Block, to: GridReference, completion: (()->Void)? = nil) {
        gameScene?.moveBlock(block, to: to) {
            completion?()
        }
    }
    
    func moveBlocks(_ blocks: [Block], to: [GridReference], completion: (()->Void)? = nil) {
        gameScene?.moveBlocks(blocks, to: to) {
            completion?()
        }
    }
    
    func removeBlock(_ block: Block, completion: (()->Void)? = nil) {
        gameScene?.removeBlock(block) {
            completion?()
        }
    }
    
    func removeBlocks(_ blocks: [Block], completion: (()->Void)?) {
        gameScene?.removeBlocks(blocks) {
            completion?()
        }
    }
    
    func addPlayer(_ blocks: [Block], to: GridReference) throws {
        try gameScene?.addPlayer(blocks, to: to)
    }
    
    func convertPlayerToBlocks(_ type: BlockType) {
        gameScene?.convertPlayerToType(type)
    }
    
    func removePlayer() {
        gameScene?.removePlayer()
    }
    
    func removePlayerBlock(_ block: Block, completion: (()->Void)? = nil) {
        gameScene?.removePlayerBlock(block) {
            completion?()
        }
    }
    
    func rotatePlayer(_ degrees: CGFloat, completion: (()->Void)? = nil) {
        gameScene?.rotatePlayer(Float(degrees)) {
            completion?()
        }
    }
    
    func movePlayer(_ direction: BlockMoveDirection, speed: CGFloat, completion: (()->Void)?) {
        gameScene?.movePlayer(direction, speed: speed) {
            completion?()
        }
    }
}

// MARK: - GameView Viper Components API
private extension GameView {
    var presenter: GamePresenterApi {
        return _presenter as! GamePresenterApi
    }
    var displayData: GameDisplayData {
        return _displayData as! GameDisplayData
    }
}
