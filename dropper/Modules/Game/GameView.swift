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
                presenter.didSelectPause()
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

    //MARK: - Game Loop
    
    func gameLoopCallback() {
        presenter.didUpdateGameLoop()
    }
}

//MARK: - GameView API

/**
 These are the methods that the presenter can call to get the view to present something to the user
 */
extension GameView: GameViewApi {
    
    func displayNextShape(_ shape: Shape) {
        gameScene?.displayNextShape(shape)
    }
    
    // MARK: - Shape Methods
    
    func addShape(_ shape: Shape, to: GridReference) {
        gameScene?.addShape(shape, to: to)
    }
    
    func showShapeGhost(at: GridReference) {
        gameScene?.showShapeGhost(at)
    }
    
    func convertShapeToBlocks(_ type: BlockType) {
        gameScene?.convertShapeToType(type)
    }
    
    func removeShape() {
        gameScene?.removeShape()
    }
    
    func rotateShape(_ degrees: CGFloat, completion: (()->Void)? = nil) {
        gameScene?.rotateShape(Float(degrees)) {
            completion?()
        }
    }
    
    func moveShape(_ direction: BlockMoveDirection, speed: CGFloat, completion: (()->Void)?) {
        gameScene?.moveShape(direction, speed: speed) {
            completion?()
        }
    }
    
    func moveShape(_ reference: GridReference, speed: CGFloat, withShake: Bool = false, completion: (()->Void)?) {
        gameScene?.moveShape(reference, speed: speed) {
            if withShake {
                self.gameScene?.shakeBlocks(completion: {
                    completion?()
                })
            } else {
                completion?()
            }
        }
    }
    
    // MARK: - UI Methods
    
    func startGameLoop(_ loopTimeInterval: TimeInterval) {
        gameScene?.startGameLoop(loopTimeInterval)
    }
    
    func stopGameLoop() {
        gameScene?.stopGameLoop()
    }
    
    func updateLevelProgress(_ progressValue: Int, progress: Double) {
        gameScene?.updateLevelProgress(progressValue, progress: progress)
    }
    
    func displayLevel(_ level: Level) {
        gameScene?.displayLevel(level)
    }
    
    
    func displayPoints(_ points: Int, from: GridReference) {
        gameScene?.displayPoints(points, from: from)
    }
    
    func updateScore(_ score: Int) {
        gameScene?.updateScore(score)
    }
    
    //MARK: - Init Game
    
    func initialiseGame(rows: Int, columns: Int) {
        let scene = GameScene(rows: rows, columns: columns, size: self.view.bounds.size, loopCallback: gameLoopCallback)
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .gameBackground
        gameSKView.presentScene(scene)
    }
    
    // MARK: - Block Methods
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
