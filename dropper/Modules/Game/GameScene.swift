//
//  GameScene.swift
//  dropper
//
//  Created by Andrew Tokeley on 19/02/23.
//

import SpriteKit
import CoreMotion

enum Direction: Int {
    case left
    case right
}

enum CollisionTypes: UInt32 {
    case block = 1
    case ground = 2
    case platform = 4
}

struct LayoutDimensions {
    var sceneSize = CGSize.zero
    
    var gridLeft: CGFloat = 0
    var gridRight: CGFloat = 0
    
    var gridTopOffset: CGFloat = 0
    var gridBottomOffset: CGFloat = 0
    var gridBorderWidth: CGFloat = 20
    
    var gridCentre: CGPoint {
        return CGPoint(x: gridSize.width/2 + gridLeft - gridBorderWidth/2, y: gridSize.height/2 + gridBottomOffset - gridBorderWidth/2)
    }
    
    var gridSize: CGSize {
        return CGSize(width: gridRight - gridLeft + gridBorderWidth, height: sceneSize.height - (gridTopOffset+gridBottomOffset-gridBorderWidth))
    }
    
    var labelsRowTopOffset: CGFloat = 100
    var valuesRowTopOffset: CGFloat = 125
    
    var blockSize: CGFloat = 30
    
    var buttonsRowBottomOffset:CGFloat = 40
    
    var spacer: CGFloat = 30
}

protocol GameSceneDelegate {
    func gameScene(_ scene: GameScene, didClickButton withTag: String)
}

class GameScene: SKScene {

    // MARK: - Constants
    var gameSceneDelegate: GameSceneDelegate?
    
    /// The duration between calls to the loopCallback
    private var loopTimeInterval = TimeInterval(0)
    
    /// The callback to call each time the game loop runs
    private var loopCallback: (()->Void)?

    /// How long since the update method last checked whether to call the loopCallback
    private var lastTimeInterval = TimeInterval(0)
    
    /// The duration for move block actions (may make zero)
    private let speedDuration = 0.2
    
    /// The amount of space on both sides of the grid
    private let side_space: CGFloat = 30

    /// The height of the playing area grid
    private var gridHeight: CGFloat {
        return CGFloat(self.rows) * blockSize
    }
    
    /// The height of the ground
    private var groundHeight: CGFloat {
        return 1.0 * blockSize
    }
    
    /// The height for the header (for title, score etc)
    private var headerHeight: CGFloat {
        return self.size.height - (gridHeight + groundHeight)
    }
    
    // MARK: - Variables
    
    private var showGhost: Bool = false
    
    private var layout = LayoutDimensions()
    
    /// The number of rows in the grid
    private var rows: Int = 0
    
    /// The number of columns in the grid
    private var columns: Int = 0
    
    /// Reference to the BlockNodes in the grid
    // private var blockNodes = [[BlockNode?]]()
    private var blockNodes = [BlockNode]()
    
    /// ShapeNode that represents the active shape
    private var shapeNode: ShapeNode?
    
    /// ShapeNode that represents the ghost of the active shape (where it would drop to)
    private var ghostNode: ShapeNode?
    
    /// Dimension of each block - blocks are always square
    public var blockSize: CGFloat {
        return layout.blockSize
    }
    
    // MARK: - Nodes
    
    lazy var pauseButton: ButtonNode = {
        let node = ButtonNode(texture: SKTexture(imageNamed: "pause"), color: .white, size: CGSize(width:40, height: 40))
        node.delegate = self
        node.tag = "pause"
        return node
    }()
    
    lazy var playButton: SKSpriteNode = {
        let node = ButtonNode(texture: SKTexture(imageNamed: "play"), color: .white, size: CGSize(width:40, height: 40))
        node.delegate = self
        node.tag = "play"
        node.alpha = 0
        return node
    }()
    
    lazy var pointLabel: SKLabelNode = {
        let node = SKLabelNode(fontNamed: "Copperplate-Bold")
        node.horizontalAlignmentMode = .center
        node.fontColor = .white
        node.fontSize = 50
        node.text = "888"
        return node
    }()
    
    private func createLabel(_ text: String, _ fontSize: CGFloat, _ colour: UIColor, _ horizontalAlign: SKLabelHorizontalAlignmentMode = .left, _ verticalAlign: SKLabelVerticalAlignmentMode = .center, _ fontName: String = "Helvetica Neue Bold") -> SKLabelNode {
        let node = SKLabelNode()
        node.text = text
        node.horizontalAlignmentMode = horizontalAlign
        node.verticalAlignmentMode = verticalAlign
        node.fontSize = fontSize
        node.fontName = fontName
        node.fontColor = colour
        return node
    }
    
    lazy var levelBlock: SKNode = {
        let node = SKNode()
        node.addChild(levelLabel)
        node.addChild(levelHeadingLabel)
        levelHeadingLabel.autoPositionWithinParent(.centreTop)
        levelLabel.autoPositionWithinParent(.centreTop, yOffSet: levelHeadingLabel.frame.size.height + 10)
        
        return node
    }()
    
    lazy var goalBlock: SKNode = {
        let node = SKNode()
        node.addChild(goalHeadingLabel)
        node.addChild(goalMessageLabel)
        goalHeadingLabel.autoPositionWithinParent(.centreTop)
        goalMessageLabel.autoPositionWithinParent(.centreTop, yOffSet: goalHeadingLabel.frame.size.height + 10)
        
        return node
    }()
    
    lazy var scoreHeadingLabel: SKLabelNode = { return createLabel("SCORE", 18, .white, .right) }()
    lazy var scoreLabel: SKLabelNode = { return createLabel("0", 32, .gameHighlight, .right) }()
    
    lazy var levelHeadingLabel: SKLabelNode = { return createLabel("LEVEL", 18, .white, .center) }()
    lazy var levelLabel: SKLabelNode = { return createLabel("1", 32, .gameHighlight, .center) }()
    
    lazy var nextHeadingLabel: SKLabelNode = { return createLabel("NEXT", 18, .white) }()
    
    lazy var goalHeadingLabel: SKLabelNode = { return createLabel("ROWS", 18, .white, .center) }()
    lazy var goalMessageLabel: SKLabelNode = { return createLabel("0", 32, .gameHighlight, .center) }()

    lazy var nextShape: ShapeNode = {
        let shape = Shape.random(.colour1)
        let node = ShapeNode(shape: shape, blockSize: 15)
        return node
    }()
    
    //MARK: - Initialisers
    
    init(rows: Int, columns: Int, size: CGSize, loopCallback: (()->Void)? = nil) {
        super.init(size: size)
        self.rows = rows
        self.columns = columns
        
        self.layout = getLayout(from: self.size)
        
        self.loopCallback = loopCallback
        
        //self.registerGestures()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func isInGrid(_ point: CGPoint) -> Bool {
        print(point)
        let hOK = point.x > layout.gridLeft && point.x < layout.gridRight
        let vOK = point.y > layout.gridBottomOffset && point.y < (self.size.height - layout.gridTopOffset)
        return vOK && hOK
    }
    
    private func getLayout(from size: CGSize) -> LayoutDimensions {
        
        var layout = LayoutDimensions()
        layout.sceneSize = self.size
        
        layout.gridBottomOffset = 100
        layout.labelsRowTopOffset = 100
        layout.valuesRowTopOffset = 125
        layout.gridTopOffset = layout.valuesRowTopOffset + 50

        
        // Define a block size to gaurantee it will fit in the space.
        layout.blockSize = min(size.width/CGFloat(columns + 2), (size.height-(layout.gridTopOffset+layout.gridBottomOffset))/CGFloat(rows))
        
        // Give to the left and right of the grid an equal amount of space
        layout.gridLeft = (size.width - CGFloat(columns) * layout.blockSize)/2
        layout.gridRight = size.width - layout.gridLeft
        
        layout.buttonsRowBottomOffset = 40
        
        return layout
    }
    
    //MARK: - Overrides
    
    override func update(_ currentTime: TimeInterval) {
        guard loopCallback != nil else { return }
        guard loopTimeInterval > 0 else { return }
        
        if abs(lastTimeInterval - currentTime) > self.loopTimeInterval {
            lastTimeInterval = currentTime
            loopCallback?()
        }
    }
    
    override func sceneDidLoad() {
        let offScreen = CGPoint(x:-100, y:-100)
        pointLabel.position = offScreen
        pauseButton.position = offScreen
        playButton.position = offScreen
        addChild(pointLabel)
        addChild(scoreLabel)
        addChild(scoreHeadingLabel)
        addChild(levelBlock)
        addChild(goalBlock)
        addChild(nextHeadingLabel)
        addChild(nextShape)
        addChild(pauseButton)
        addChild(playButton)
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        guard self.size != CGSize.zero else { return }
        repositionNodes()
    }
    
    // MARK: - Helpers
    
    /**
     Whenever the scene size changes we need to manually reposition nodes.
     */
    private func repositionNodes() {
        
        nextHeadingLabel.autoPositionWithinParent(.leftTop, xOffSet: layout.spacer, yOffSet: layout.labelsRowTopOffset)
        
        nextShape.autoPositionWithinParent(.leftTop, xOffSet: layout.spacer, yOffSet: layout.valuesRowTopOffset)
        goalBlock.autoPositionWithinParent(.leftTop, xOffSet: 0.35*size.width, yOffSet: layout.labelsRowTopOffset)
        scoreHeadingLabel.autoPositionWithinParent(.rightTop, xOffSet: layout.spacer, yOffSet: layout.labelsRowTopOffset)
        scoreLabel.autoPositionWithinParent(.rightTop, xOffSet: layout.spacer, yOffSet: layout.valuesRowTopOffset)
        levelBlock.autoPositionWithinParent(.rightTop, xOffSet: 0.40*size.width, yOffSet: layout.labelsRowTopOffset)
        
        pauseButton.autoPositionWithinParent(.centreBottom, yOffSet: layout.buttonsRowBottomOffset)
        playButton.autoPositionWithinParent(.centreBottom, yOffSet: layout.buttonsRowBottomOffset)
    }
    /**
     Gets the screen point at the centre of a GridReference
     */
    private func getPosition(_ reference: GridReference, centre: Bool = true) -> CGPoint {
        
        var position = CGPoint.zero
        position.x = CGFloat(reference.column) * layout.blockSize + layout.gridLeft
        if centre {
            position.x += layout.blockSize/2.0
        }
        position.y = CGFloat(reference.row) * layout.blockSize + layout.gridBottomOffset
        if centre {
            position.y += layout.blockSize/2.0
        }
        return position
    }
    
    private func getNode(_ block: Block) -> BlockNode? {
        blockNodes.first(where: { $0.block == block })
    }
        
    public func startGameLoop(_ loopTimeInterval: TimeInterval) {
        self.loopTimeInterval = loopTimeInterval
        self.lastTimeInterval = TimeInterval(0)
    }
    
    public func stopGameLoop() {
        self.loopTimeInterval = TimeInterval(0)
    }
    
    public func showGhost(_ show: Bool) {
        self.showGhost = show
        self.ghostNode?.alpha = show ? 1 : 0
    }
    
    public func showGrid(_ show: Bool) {
        // always show a border around the grid
        if let border = self.childNode(withName: "border") {
            border.removeFromParent()
        }
        let border = SKShapeNode(rectOf: layout.gridSize)
        border.name = "border"
        border.lineWidth = layout.gridBorderWidth/4
        border.strokeColor = .white
        border.position = layout.gridCentre
        self.addChild(border)
        
        if !show {
            let lines = self.children.filter({$0.name?.starts(with: "_line") ?? false })
            for line in lines {
                line.removeFromParent()
            }
        } else {
            for row in 0..<rows + 1 {
                let horizontal = UIBezierPath()
                let rowHeight = getPosition(GridReference(row, 0), centre: false).y
                let left = getPosition(GridReference(0, 0), centre: false).x
                let right = getPosition(GridReference(0, columns), centre: false).x
                horizontal.move(to: CGPoint(x: left, y: rowHeight))
                horizontal.addLine(to: CGPoint(x: right, y: rowHeight))
                let line = SKShapeNode(path: horizontal.cgPath)
                line.strokeColor = show ? .white : .gameBackground
                line.name = "_line\(left)-\(right)"
                line.zPosition = -100
                self.addChild(line)
                for column in 0..<columns + 1 {
                    let columnWidth = getPosition(GridReference(0, column), centre: false).x
                    let bottom = getPosition(GridReference(0, 0), centre: false).y
                    let top = getPosition(GridReference(rows, 0), centre: false).y
                    
                    let vertical = UIBezierPath()
                    vertical.move(to: CGPoint(x: columnWidth, y: bottom))
                    vertical.addLine(to: CGPoint(x: columnWidth, y: top))
                    let line = SKShapeNode(path: vertical.cgPath)
                    line.name = "_line\(top)-\(bottom)"
                    line.zPosition = -100
                    line.strokeColor = show ? .white : .gameBackground
                    self.addChild(line)
                }
            }
        }
    }
    
    // MARK: - Score Methods
    public func updateScore(_ score: Int) {
        self.scoreLabel.text = "\(score)"
    }
    
    public func displayPoints(_ points: Int, from: GridReference) {
        guard points > 0 else { return }
        
        pointLabel.text = "\(points)"
        pointLabel.alpha = 1
        pointLabel.autoPositionWithinParent(.centre)
        
        let move = SKAction.moveBy(x: CGFloat.random(in: -30..<30), y: CGFloat.random(in: 30..<90), duration: 2.0)
        move.timingMode = .easeOut
        
        let fade = SKAction.fadeOut(withDuration: 2.0)
        
        pointLabel.run(move)
        pointLabel.run(fade)

    }
    
    // MARK: - User Interface
    
    public func displayLevel(_ levelNumber: Int) {
        levelLabel.text = "\(levelNumber)"
    }
    
    func updateLevelProgress(_ progressValue: Int, goalUnit: String? = nil) {
        goalMessageLabel.text = "\(progressValue)"
        if let goalUnit = goalUnit {
            goalHeadingLabel.text = "\(goalUnit.uppercased())"
        }
    }
    
    public func displayNextShape(_ shape: Shape) {
        nextShape.setShape(shape, blockSize: 15)
    }
    
    public func setPauseState(_ paused: Bool) {
        pauseButton.alpha = paused ? 0 : 1
        playButton.alpha = paused ? 1 : 0
    }
    
    // MARK: - Shape Methods
    
    public func addShape(_ shape: Shape, to: GridReference) {
        self.shapeNode = ShapeNode(shape: shape, blockSize: blockSize)
        if let shapeNode = shapeNode {
            // add the player's nodes to the blockNodes array
            self.blockNodes.append(contentsOf: shapeNode.blockNodes)
            shapeNode.position = getPosition(to)
            addChild(shapeNode)
        }
    }
    
    func showShapeGhost(_ at: GridReference) {
        guard self.showGhost else { return }
        
        self.ghostNode?.removeFromParent()
        self.ghostNode = self.shapeNode?.ghostShapeNode
        self.ghostNode?.alpha = self.showGhost ? 1 : 0
        if let node = self.ghostNode {
            node.position = getPosition(at)
            addChild(node)
        }
    }
    
    public func rotateShape(_ degrees: Float, completion: (()->Void)? = nil) {
        self.shapeNode?.run(SKAction.rotate(byAngle: -CGFloat(GLKMathDegreesToRadians(degrees)), duration: 0.1)) {
            completion?()
        }
    }
    
    public func moveShape(_ direction: BlockMoveDirection, speed: CGFloat, completion: (()->Void)? = nil) {
        if let playerNode = shapeNode {
            let x = CGFloat(direction.gridDirection.offset.columnOffset)*blockSize
            let y = CGFloat(direction.gridDirection.offset.rowOffset)*blockSize
            playerNode.run(SKAction.moveBy(
                x: x,
                y: y,
                duration: speed)) {
                    completion?()
                }
        } else {
            completion?()
        }
    }
    
    public func moveShape(_ reference: GridReference, speed: CGFloat, completion: (()->Void)? = nil) {
        if let playerNode = shapeNode {
            let newPosition = getPosition(reference)
            playerNode.removeAllActions()
            playerNode.run(SKAction.move(to: newPosition, duration: speed)) {
                completion?()
            }
        } else {
            completion?()
        }
    }
    
    func removeShape() {
        if let playerBlockNode = shapeNode?.blockNodes {
            for playerBlockNode in playerBlockNode {
                self.blockNodes.removeAll(where: {$0 == playerBlockNode })
            }
            shapeNode?.removeFromParent()
        }
    }
    
    /**
     Removes the player and replaces it with blocks of the given type
     */
    func convertShapeToType(_ type: BlockType) {
        if let playerNode = shapeNode {
            for node in playerNode.blockNodes {
                if let block = node.block {
                    block.type = type
                    // get the nodes postion in the scene's coordinate system
                    if let parent = node.parent {
                        if let positionInScene = node.scene?.convert(node.position,
                                                                     from: parent) {
                            self.addBlock(block: block, position: positionInScene)
                        }
                    }
                    
                }
            }
        }
        removeShape()
    }
    
    // MARK: - Block Methods
    
    public func shakeBlocks(completion: (()->Void)?) {
        
        let jumpUp = SKAction.moveBy(x: 0, y: -5, duration: 0.08)
        let dropBack = SKAction.moveBy(x: 0, y: 5, duration: 0.08)
        dropBack.timingMode = .easeOut
        let shake = SKAction.sequence([jumpUp, dropBack])
        
        let dispatch = DispatchGroup()
        for node in blockNodes {
            if !(shapeNode?.blockNodes.contains(node) ?? false) {
                dispatch.enter()
                node.run(shake) {
                    dispatch.leave()
                }
            }
        }
        dispatch.notify(queue: DispatchQueue.main, execute: {
            completion?()
        })
    }
    
    public func addBlocks(blocks: [Block], to: [GridReference], completion: (()->Void)? = nil) {
        guard blocks.count == to.count else { return }
        
        let dispatchGroup = DispatchGroup()
        
        for i in 0..<blocks.count {
            dispatchGroup.enter()
            addBlock(block: blocks[i], to: to[i]) {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main, execute: {
            completion?()
        })
    }
    
    private func addBlock(block: Block, position: CGPoint, completion: (()->Void)? = nil) {
        let node = BlockNode(block: block, size: blockSize)
        node.position = position
        addChild(node)
        blockNodes.append(node)
        completion?()
    }
    
    public func addBlock(block: Block, to: GridReference, completion: (()->Void)? = nil) {
        addBlock(block: block, position: getPosition(to), completion: completion)
    }
    
    public func moveBlocks(_ blocks: [Block], to: [GridReference], completion: (()->Void)?) {
        
        if (blocks.count != to.count) || blocks.count == 0 {
            completion?()
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        for i in 0..<blocks.count {
            dispatchGroup.enter()
            moveBlock(blocks[i], to: to[i]) {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main, execute: {
            completion?()
        })
    }
    
    public func moveBlock(_ block: Block, to: GridReference, completion: (()->Void)?) {
        let speed = 0.05
        if let node = getNode(block) {
            
            let toPos = getPosition(to)
            let duration = (node.position.y - toPos.y)/blockSize * speed
            node.run(SKAction.move(to: CGPoint(x: toPos.x, y: toPos.y), duration: duration)) {
                completion?()
            }
        }
    }

    public func removeBlock(_ block: Block, completion: (()->Void)? = nil) {
        if let node = getNode(block) {
            node.explode {
                self.blockNodes.removeAll(where: { $0 == node })
                completion?()
            }
        }
    }
    
    public func removeBlocks(_ blocks: [Block], completion: (()->Void)? = nil) {
        
        if blocks.count == 0 {
            completion?()
            return
        }
        
        let dispatchGroup = DispatchGroup()
        for block in blocks {
            dispatchGroup.enter()
            removeBlock(block) {
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.main, execute: {
            completion?()
        })
    }
}

extension GameScene: ButtonNodeDelegate {
    func buttonClicked(sender: ButtonNode) {
        
        if let tag = sender.tag {
            if tag == "pause" {
                setPauseState(true)
            } else if tag == "play" {
                setPauseState(false)
            }
            gameSceneDelegate?.gameScene(self, didClickButton: tag)
        }
    }
}

