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

    lazy var settingsButton: UIBarButtonItem = {
        
        let view = UIBarButtonItem(title: NSString(string: "\u{2699}\u{0000FE0E}") as String, style: .plain, target: self, action: #selector(handleSettings))
        let font = UIFont.systemFont(ofSize: 40)
        let attributes = [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: UIColor.white]
        view.setTitleTextAttributes(attributes, for: .normal)
        return view
    }()
    
    lazy var closeButton: UIBarButtonItem = {
        let view = UIBarButtonItem(title: NSString(string: "\u{2715}\u{0000FE0E}") as String, style: .plain, target: self, action: #selector(handleClose))
        let font = UIFont.systemFont(ofSize: 25)
        let attributes = [
            NSAttributedString.Key.font : font,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        let pressedAttributes = [
            NSAttributedString.Key.font : font,
            NSAttributedString.Key.foregroundColor: UIColor.gameHighlight
        ]
        view.setTitleTextAttributes(attributes, for: .normal)
        view.setTitleTextAttributes(pressedAttributes, for: .highlighted)
        view.setTitleTextAttributes(pressedAttributes, for: .selected)
        view.setTitleTextAttributes(pressedAttributes, for: .focused)
        return view
    }()
    
    override func viewDidLoad() {
        self.view.backgroundColor = .gameBackground

        navigationItem.rightBarButtonItems = [settingsButton]
        navigationItem.leftBarButtonItems = [closeButton]
        
        registerSwipes()
        view.addSubview(gameSKView)
        setConstraints()
    }
    
    @objc func handleSettings(_ sender: UIBarButtonItem) {
        presenter.didSelectSettings()
    }
    
    @objc func handleClose(_ sender: UIBarButtonItem) {
        
        self.presenter.willCloseView { allow in
            if allow {
                self.presentingViewController?.dismiss(animated: true)
            } else {
                // don't need to do anything
            }
        }
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
                presenter.didSelectPauseToggle()
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
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan))
        self.view.addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.view.addGestureRecognizer(tap)
        
    }

    private var lastPanPoint = CGPoint(x:0, y:0)
    @objc func pan(sender: UIPanGestureRecognizer) {
        guard let blockSize = gameScene?.blockSize else { return }
        let panVelocity = sender.velocity(in: self.view)
        let panPoint = sender.location(in: self.view)
        
        let sensitivity: CGFloat = 0.8
        let swipeVelocityThreshold:CGFloat = 300
        
        if sender.state == .began {
            lastPanPoint = panPoint
        } else if sender.state == .changed {
            
            if abs(panPoint.y - lastPanPoint.y) > blockSize && panVelocity.y > swipeVelocityThreshold {
                presenter.didSelectDrop()
            } else if abs(panPoint.x - lastPanPoint.x) > sensitivity  * blockSize {
                if panPoint.x > lastPanPoint.x {
                    presenter.didSelectMove(.right)
                } else {
                    presenter.didSelectMove(.left)
                }
                lastPanPoint = panPoint
            }
        }
    }
    
    @objc func tap(sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.view)
        let skViewPoint = CGPoint(x: point.x, y: self.view.frame.height - point.y)
        if let isInGrid = gameScene?.isInGrid(skViewPoint) {
            if isInGrid {
                print("rotate")
                presenter.didSelectRotate()
            }
        }
    }
    
    @objc func swipe(sender: UISwipeGestureRecognizer) {
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
    
    func showGrid(_ show: Bool) {
        gameScene?.showGrid(show)
    }
    
    func showGhost(_ show: Bool) {
        gameScene?.showGhost(show)
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
    
    func updateLevelProgress(_ progressValue: Int, goalUnit: String? = nil) {
        gameScene?.updateLevelProgress(progressValue, goalUnit: goalUnit)
    }
    
    func displayLevel(_ levelNumber: Int) {
        gameScene?.displayLevel(levelNumber)
    }
    
    
    func displayPoints(_ points: Int, from: GridReference) {
        gameScene?.displayPoints(points, from: from)
    }
    
    func updateScore(_ score: Int) {
        gameScene?.updateScore(score)
    }
    
    func setPauseState(_ pause: Bool) {
        gameScene?.setPauseState(pause)
    }
    
    func displayModalDialog(title: String, message: String, actions: [ModalDialogAction]) {
        let modal = ModalDialogView.fromStoryboard("ModalDialog", identifier: "ModalDialogView", bundle: nil)
        modal.show(from: self, title: title, message: message, actions: actions)
    }
    
    //MARK: - Init Game
    
    func initialiseGame(rows: Int, columns: Int, showGrid: Bool = false) {
        let scene = GameScene(rows: rows, columns: columns, size: self.view.bounds.size, loopCallback: gameLoopCallback)
        scene.scaleMode = .resizeFill
        scene.gameSceneDelegate = self
        scene.backgroundColor = .gameBackground
        gameSKView.presentScene(scene)
        
        self.showGrid(showGrid)
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

extension GameView: GameSceneDelegate {
    func gameScene(_ scene: GameScene, didClickButton withTag: String) {
        presenter.didSelectPauseToggle()
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
