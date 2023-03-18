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

class GameScene: SKScene {

    // MARK: - Constants

    private let speedDuration = TimeInterval(0.2)

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
    
    /// The number of rows in the grid
    private var rows: Int = 0
    
    /// The number of columns in the grid
    private var columns: Int = 0
    
    /// Reference to the BlockNodes in the grid
    // private var blockNodes = [[BlockNode?]]()
    private var blockNodes = [BlockNode]()
    
    private var playerNode: ShapeNode?
    
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
    
    lazy var scoreHeadingLabel: SKLabelNode = { return createLabel("SCORE", 18, .white, .right) }()
    lazy var scoreLabel: SKLabelNode = { return createLabel("0", 32, .gameHighlight, .right) }()
    
    lazy var levelHeadingLabel: SKLabelNode = { return createLabel("LEVEL", 18, .white, .center) }()
    lazy var levelLabel: SKLabelNode = { return createLabel("1", 32, .gameHighlight, .center) }()
    
    lazy var nextHeadingLabel: SKLabelNode = { return createLabel("NEXT", 18, .white) }()
    
    lazy var goalHeadingLabel: SKLabelNode = { return createLabel("GOAL", 18, .white) }()
    lazy var goalMessageLabel: SKLabelNode = { return createLabel("", 18, .gameHighlight, .right) }()

    lazy var nextShape: ShapeNode = {
        let shape = Shape.random(.colour1)
        let node = ShapeNode(shape: shape, blockSize: 15)
        return node
    }()
    
    lazy var progressNode: ProgressNode = {
        let node = ProgressNode(size: CGSize.zero)
        return node
    }()
    
    var sideBar: SKShapeNode {
        let node = SKShapeNode(rect: CGRect(origin: CGPoint(x:0,y:0), size: CGSize(width: side_space, height: self.size.height - headerHeight)))
        node.fillColor = .clear
        node.lineWidth = 2
        node.strokeColor = .clear
        return node
    }
    
    //MARK: - Initialisers
    
    private func initialise(rows: Int, columns: Int, size: CGSize) {
        self.rows = rows
        self.columns = columns
        self.blockSize = (size.width-2*side_space)/CGFloat(columns)
    }
    
    init(rows: Int, columns: Int, size: CGSize) {
        super.init(size: size)
        initialise(rows: rows, columns: columns, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Overrides
    
    override func sceneDidLoad() {

        addChild(scoreLabel)
        addChild(scoreHeadingLabel)
        addChild(levelLabel)
        addChild(levelHeadingLabel)
        addChild(goalMessageLabel)
        addChild(goalHeadingLabel)
        addChild(nextHeadingLabel)
        addChild(nextShape)
        addChild(progressNode)
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
        let topSpacer: CGFloat = 100
        let textLevel1_OffSet = topSpacer + 0
        let textLevel2_OffSet = topSpacer + 25
        let textLevel3_OffSet = topSpacer + 120
        
        let spacer: CGFloat = 15

        // next
        nextHeadingLabel.autoPositionWithinScene(.leftTop, xOffSet: spacer, yOffSet: textLevel1_OffSet)
 
        // next Shape
        nextShape.autoPositionWithinScene(.leftTop, xOffSet: spacer, yOffSet: textLevel2_OffSet)
        
        // goal
        goalHeadingLabel.autoPositionWithinScene(.leftTop, xOffSet: spacer, yOffSet:textLevel3_OffSet)
        goalMessageLabel.autoPositionWithinScene(.rightTop, xOffSet: spacer, yOffSet: textLevel3_OffSet)

        // score
        scoreHeadingLabel.autoPositionWithinScene(.rightTop, xOffSet: spacer, yOffSet: textLevel1_OffSet)
        scoreLabel.autoPositionWithinScene(.rightTop, xOffSet: spacer, yOffSet: textLevel2_OffSet)
        
        // level
        levelHeadingLabel.autoPositionWithinScene(.centreTop, yOffSet: textLevel1_OffSet)
        levelLabel.autoPositionWithinScene(.centreTop, yOffSet: textLevel2_OffSet)
        
        // progess
        progressNode.size.width = self.size.width * 0.85
        progressNode.size.height = 10
        progressNode.autoPositionWithinScene(.centreTop, yOffSet: textLevel3_OffSet - 25)
        progressNode.buildNode()
    }
    /**
     Gets the screen point at the centre of a GridReference
     */
    private func getPosition(_ reference: GridReference, centre: Bool = true) -> CGPoint {
        
        var position = CGPoint.zero
        position.x = CGFloat(reference.column) * blockSize + side_space
        if centre {
            position.x += blockSize/2.0
        }
        position.y = CGFloat(reference.row) * blockSize + side_space
        if centre {
            position.y += blockSize/2.0
        }
        return position
    }
    
    private func getNode(_ block: Block) -> BlockNode? {
        blockNodes.first(where: { $0.block == block })
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
    
    // MARK: - Player Methods

    public func displayLevel(_ level: Level) {
        levelLabel.text = "\(level.number)"
        goalMessageLabel.text = level.goalDescription
        progressNode.updateProgress(0)
    }
    
    func updateLevelProgress(_ message: String, progress: Double) {
        goalMessageLabel.text = message
        progressNode.updateProgress(progress)
    }
    
    public func displayNextShape(_ shape: Shape) {
        nextShape.setShape(shape, blockSize: 15)
    }
    
    public func addPlayer(_ blocks: [Block], references: [GridReference], to: GridReference) throws {

        // convert the references to be relative to the origin
        let relativeReferences = references.map { GridReference($0.row-to.row, $0.column-to.column) }
        self.playerNode = try ShapeNode(blocks: blocks, references:relativeReferences, blockSize: blockSize)

        if let playerNode = playerNode {
            // add the player's nodes to the blockNodes array
            self.blockNodes.append(contentsOf: playerNode.blocksNodes)

            playerNode.position = getPosition(to)

            addChild(playerNode)
        }
    }
    
    public func addPlayer(_ blocks: [Block], to: GridReference) throws {
        
//        self.playerNode = try ShapeNode(blocks: blocks, references: <#T##[GridReference]#>, blockSize: <#T##CGFloat#>)
//        if let playerNode = playerNode {
//
//            // add the player's nodes to the blockNodes array
//            self.blockNodes.append(contentsOf: playerNode.blocksNodes)
//
//            playerNode.position = getPosition(to)
//            addChild(playerNode)
//        }
    }
    
    public func rotatePlayer(_ degrees: Float, completion: (()->Void)? = nil) {
        self.playerNode?.run(SKAction.rotate(byAngle: -CGFloat(GLKMathDegreesToRadians(degrees)), duration: speedDuration)) {
            completion?()
        }
    }
    
    public func movePlayer(_ direction: BlockMoveDirection, speed: CGFloat, completion: (()->Void)? = nil) {
        print("move player \(direction)")
        if let playerNode = playerNode {
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
    
    public func movePlayer(_ reference: GridReference, speed: CGFloat, completion: (()->Void)? = nil) {
        if let playerNode = playerNode {
            let newPosition = getPosition(reference)
            playerNode.removeAllActions()
            playerNode.run(SKAction.move(to: newPosition, duration: speed)) {
                completion?()
            }
        } else {
            completion?()
        }
    }
    
    func removePlayer() {
        if let playerBlockNode = playerNode?.blocksNodes {
            for playerBlockNode in playerBlockNode {
                self.blockNodes.removeAll(where: {$0 == playerBlockNode })
            }
            playerNode?.removeFromParent()
        }
    }
    
    func removePlayerBlock(_ block: Block, completion: (()->Void)? = nil) {
        if let playerNode = playerNode {
            playerNode.removeBlock(block) { (remainingBlocks) in
                if remainingBlocks == 0 {
                    self.removePlayer()
                }
                completion?()
                return
            }
        } else {
            completion?()
        }
    }
    
    /**
     Removes the player and replaces it with blocks of the given type
     */
    func convertPlayerToType(_ type: BlockType) {
        if let playerNode = playerNode {
            for node in playerNode.blocksNodes {
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
        removePlayer()
    }
    
    // MARK: - Block Methods
    
    public func shakeBlocks(completion: (()->Void)?) {
        
        let jumpUp = SKAction.moveBy(x: 0, y: -5, duration: 0.08)
        let dropBack = SKAction.moveBy(x: 0, y: 5, duration: 0.08)
        dropBack.timingMode = .easeOut
        let shake = SKAction.sequence([jumpUp, dropBack])
        
        let dispatch = DispatchGroup()
        for node in blockNodes {
            if !(playerNode?.blocksNodes.contains(node) ?? false) {
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
        if let node = getNode(block) {
            
            let toPos = getPosition(to)
            let duration = (node.position.y - toPos.y)/blockSize * speedDuration
            node.run(SKAction.move(to: CGPoint(x: toPos.x, y: toPos.y), duration: duration)) {
                completion?()
            }
        }
    }

    public func removeBlock(_ block: Block, completion: (()->Void)? = nil) {
        if let node = getNode(block) {
            node.explode {
                node.removeFromParent()
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
            if block.type == .player {
                removePlayerBlock(block) {
                    dispatchGroup.leave()
                }
            } else {
                removeBlock(block) {
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.main, execute: {
            completion?()
        })
    }
}

