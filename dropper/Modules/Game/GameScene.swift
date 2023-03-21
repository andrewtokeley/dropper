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
    var gridLeft: CGFloat = 0
    var gridRight: CGFloat = 0
    var gridTop: CGFloat = 0
    var gridBottom: CGFloat = 0
    
    var spacer: CGFloat = 30
}

class GameScene: SKScene {

    // MARK: - Constants

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
    private var blockSize: CGFloat = 10
    
    // MARK: - Nodes
    
    lazy var pointLabel: SKLabelNode = {
        let node = SKLabelNode(fontNamed: "Copperplate-Bold")
        node.horizontalAlignmentMode = .center
        node.fontColor = .white
        node.fontSize = 50
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
    
//    lazy var progressNode: ProgressNode = {
//        let node = ProgressNode(size: CGSize.zero)
//        return node
//    }()
    
    var sideBar: SKShapeNode {
        let node = SKShapeNode(rect: CGRect(origin: CGPoint(x:0,y:0), size: CGSize(width: side_space, height: self.size.height - headerHeight)))
        node.fillColor = .clear
        node.lineWidth = 2
        node.strokeColor = .clear
        return node
    }
    
    //MARK: - Initialisers
    
    init(rows: Int, columns: Int, size: CGSize, loopCallback: (()->Void)? = nil) {
        super.init(size: size)
        self.rows = rows
        self.columns = columns
        
        // calculate a block size that gaurantees the grid will fit the visible screen and have at least a blocksize to the left and right.
        
        // Reserve this much space above the grid, for headings/scores etc.
        let gridTop: CGFloat = 150
        self.blockSize = min(self.size.width/CGFloat(columns + 2), (self.size.height-gridTop)/CGFloat(rows + 3))
        let gridLeftRight = (self.size.width - CGFloat(columns) * self.blockSize)/2
        self.layout = LayoutDimensions(
            gridLeft: gridLeftRight,
            gridRight: gridLeftRight,
            gridTop: gridTop,
            gridBottom: 2.0 * blockSize)
        
        self.loopCallback = loopCallback
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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

        addChild(scoreLabel)
        addChild(scoreHeadingLabel)
//        addChild(levelLabel)
//        addChild(levelHeadingLabel)
        addChild(levelBlock)
//        addChild(goalMessageLabel)
//        addChild(goalHeadingLabel)
        addChild(goalBlock)
        addChild(nextHeadingLabel)
        addChild(nextShape)
        //addChild(progressNode)
        self.columns = 10
        //self.blockSize = (self.size.width-2*side_space)/CGFloat(self.columns)
        
        // TODO - calculate this
        let headerHeight: CGFloat = 300.0
        self.rows = Int((self.size.height-headerHeight-side_space)/self.blockSize)
        
        
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
        let textLevel1_OffSet: CGFloat = 100
        let textLevel2_OffSet: CGFloat = 125
        
        nextHeadingLabel.autoPositionWithinParent(.leftTop, xOffSet: layout.spacer, yOffSet: textLevel1_OffSet)
        nextShape.autoPositionWithinParent(.leftTop, xOffSet: layout.spacer, yOffSet: textLevel2_OffSet)
        goalBlock.autoPositionWithinParent(.leftTop, xOffSet: 0.35*size.width, yOffSet: textLevel1_OffSet)
        scoreHeadingLabel.autoPositionWithinParent(.rightTop, xOffSet: layout.spacer, yOffSet: textLevel1_OffSet)
        scoreLabel.autoPositionWithinParent(.rightTop, xOffSet: layout.spacer, yOffSet: textLevel2_OffSet)
        levelBlock.autoPositionWithinParent(.rightTop, xOffSet: 0.40*size.width, yOffSet: textLevel1_OffSet)
    }
    /**
     Gets the screen point at the centre of a GridReference
     */
    private func getPosition(_ reference: GridReference, centre: Bool = true) -> CGPoint {
        
        var position = CGPoint.zero
        position.x = CGFloat(reference.column) * blockSize + layout.gridLeft
        if centre {
            position.x += blockSize/2.0
        }
        position.y = CGFloat(reference.row) * blockSize + layout.gridBottom
        if centre {
            position.y += blockSize/2.0
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
    
    
    public func showGrid(_ show: Bool) {
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
        pointLabel.text = "\(points)"
        let move = SKAction.move(to: CGPoint(x:self.size.width/2, y:groundHeight + 0.5 * gridHeight), duration: 0)
        move.timingMode = SKActionTimingMode.easeInEaseOut
        let scale = SKAction.scale(by: 2, duration: 0.2)
        scale.timingMode = SKActionTimingMode.easeInEaseOut
        
        pointLabel.run(SKAction.moveBy(x: 40, y: 40, duration: 1.0))
        pointLabel.run(scale)
        let sequence = SKAction.sequence([
            move,
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.wait(forDuration: 0.5),
            SKAction.scale(by: -2, duration: 3),
            SKAction.fadeOut(withDuration: 0.2),
        ])
        pointLabel.run(sequence)
    }
    
    // MARK: - User Interface
    
    public func displayLevel(_ levelNumber: Int) {
        levelLabel.text = "\(levelNumber)"
    }
    
    func updateLevelProgress(_ progressValue: Int, progress: Double) {
        goalMessageLabel.text = "\(progressValue)"
        //progressNode.updateProgress(progress)
    }
    
    public func displayNextShape(_ shape: Shape) {
        nextShape.setShape(shape, blockSize: 15)
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
        self.ghostNode?.removeFromParent()
        self.ghostNode = self.shapeNode?.ghostShapeNode
        if let node = self.ghostNode {
            node.position = getPosition(at)
            print("ghost pos = \(node.position)")
            print("ghost ref = \(at)")
            addChild(node)
        }
    }
    
    public func rotateShape(_ degrees: Float, completion: (()->Void)? = nil) {
        self.shapeNode?.run(SKAction.rotate(byAngle: -CGFloat(GLKMathDegreesToRadians(degrees)), duration: 0)) {
            completion?()
        }
    }
    
    public func moveShape(_ direction: BlockMoveDirection, speed: CGFloat, completion: (()->Void)? = nil) {
        if let playerNode = shapeNode {
            playerNode.run(SKAction.moveBy(
                x: CGFloat(direction.gridDirection.gridDelta.columnDelta)*blockSize,
                y: CGFloat(direction.gridDirection.gridDelta.rowDelta)*blockSize,
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
    
//    func removePlayerBlock(_ block: Block, completion: (()->Void)? = nil) {
//        if let playerNode = playerNode {
//            playerNode.removeBlock(block) { (remainingBlocks) in
//                if remainingBlocks == 0 {
//                    self.removeShape()
//                }
//                completion?()
//                return
//            }
//        } else {
//            completion?()
//        }
//    }
    
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

