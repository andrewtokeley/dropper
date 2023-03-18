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
import SwiftUI

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
        view.backgroundColor = .gameBackground
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
        self.view.backgroundColor = .gameBackground
        
        let settingsButton = UIBarButtonItem(title: NSString(string: "\u{2699}\u{0000FE0E}") as String, style: .plain, target: self, action: #selector(settingsTapped))
        let font = UIFont.systemFont(ofSize: 40)
        let attributes = [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: UIColor.white]
        settingsButton.setTitleTextAttributes(attributes, for: .normal)
    
        let add = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(settingsTapped))
        add.tintColor = .white
        navigationItem.rightBarButtonItems = [settingsButton]
        
        registerSwipes()
        view.addSubview(gameSKView)
        setConstraints()
    }
    
    @objc func settingsTapped(_ sender: UIBarButtonItem) {
        
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

    // MARK: - Swipes

    func registerSwipes() {
        let left = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        left.direction = .left
        let right = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        right.direction = .right
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        //up.direction = .up
        let down = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        down.direction = .down
        self.view.addGestureRecognizer(left)
        self.view.addGestureRecognizer(right)
        self.view.addGestureRecognizer(tap)
        self.view.addGestureRecognizer(down)
    }

    @objc func pan(sender: UIPanGestureRecognizer) {
        presenter.didSelectMove(.left)
    }
    
    @objc func tap(sender: UITapGestureRecognizer) {
        presenter.didSelectRotate()
    }
    
    @objc func swipe(sender: UISwipeGestureRecognizer) {
        //print(sender.direction)
        if sender.direction == .left {
            presenter.didSelectMove(.left)
        }
        if sender.direction == .right {
            presenter.didSelectMove(.right)
        }
        if sender.direction == .down {
            presenter.didSelectDrop()
        }
    }
}


//MARK: - GameView API

/**
 These are the methods that the presenter can call to get the view to present something to the user
 */
extension GameView: GameViewApi {
    
    func updateLevelProgress(_ message: String, progress: Double) {
        gameScene?.updateLevelProgress(message, progress: progress)
    }
    
    func displayLevel(_ level: Level) {
        gameScene?.displayLevel(level)
    }
    func displayNextShape(_ shape: Shape) {
        gameScene?.displayNextShape(shape)
    }
    
    func displayPoints(_ points: Int, from: GridReference) {
        gameScene?.displayPoints(points, from: from)
    }
    
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
        scene.backgroundColor = .gameBackground
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
    
    func movePlayer(_ reference: GridReference, speed: CGFloat, withShake: Bool = false, completion: (()->Void)?) {
        gameScene?.movePlayer(reference, speed: speed) {
            if withShake {
                self.gameScene?.shakeBlocks(completion: {
                    completion?()
                })
            } else {
                completion?()
            }
        }
    }
}

extension GameView: SKSceneDelegate {
    
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
