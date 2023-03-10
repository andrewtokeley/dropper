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
        return 3.0 * blockSize
    }
    
    /// The height for the header (for title, score etc)
    private var headerHeight: CGFloat {
        return self.size.height - (gridHeight + groundHeight)
    }
    
    // MARK: - Variables
    
    /// The number of rows in the grid
    private var rows: Int!
    
    /// The number of columns in the grid
    private var columns: Int!
    
    /// Reference to the BlockNodes in the grid
    // private var blockNodes = [[BlockNode?]]()
    private var blockNodes = [BlockNode]()
    
    private var playerNode: ShapeNode?
    
    /// Dimension of each block - blocks are always square
    private var blockSize: CGFloat!
    
    // MARK: - Nodes
    
    lazy var scoreLabel: SKLabelNode = {
        let node = SKLabelNode(fontNamed: "Chalkduster")
        node.text = "0"
        node.horizontalAlignmentMode = .center
        node.fontColor = .white
        return node
    }()
    
    var sideBar: SKShapeNode {
        let node = SKShapeNode(rect: CGRect(origin: CGPoint(x:0,y:0), size: CGSize(width: side_space, height: self.size.height - headerHeight)))
        node.fillColor = .gray
        node.lineWidth = 2
        node.strokeColor = .black
        return node
    }
    
    //MARK: - Initialisers
    
    init(rows: Int, columns: Int, size: CGSize) {
        self.rows = rows
        self.columns = columns
        self.blockSize = (size.width-2*side_space)/CGFloat(columns)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Overrides
    
    override func sceneDidLoad() {
        self.backgroundColor = .gameSkyBlue
        
        drawGrid()
        
        let header = SKShapeNode(rect: CGRect(origin: CGPoint(x:0, y: self.size.height - headerHeight), size: CGSize(width: self.size.width, height: headerHeight)))
        header.fillColor = .darkGray
        header.lineWidth = 2
        header.strokeColor = .black
        addChild(header)
        
        //let score = ScoreNode(0, size: CGSize(width: 100, height: 50))
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height-0.5*headerHeight)
        addChild(scoreLabel)
        
        let leftSideBar = sideBar
        leftSideBar.position = CGPoint(x:0, y:0)
        addChild(leftSideBar)
        
        let rightSideBar = sideBar
        rightSideBar.position = CGPoint(x:self.size.width-side_space, y:0)
        addChild(rightSideBar)
        
        let bottom = SKShapeNode(rect: CGRect(origin: CGPoint(x:side_space,y:0), size: CGSize(width: self.size.width-2*side_space, height: groundHeight)))
        bottom.fillColor = .brown
        bottom.lineWidth = 2
        bottom.strokeColor = .black
        addChild(bottom)
    }
    
    private func drawGrid() {
        for row in 0..<rows {
            let horizontal = UIBezierPath()
            let rowY = CGFloat(row+1)*blockSize + groundHeight
            horizontal.move(to: CGPoint(x: side_space, y: rowY))
            horizontal.addLine(to: CGPoint(x: self.size.width-side_space, y: rowY))
            let line = SKShapeNode(path: horizontal.cgPath)
            line.strokeColor = .gameLightSkyBlue
            self.addChild(line)
            for column in 0..<columns {
                let columnX = side_space + CGFloat(column)*blockSize
                let vertical = UIBezierPath()
                vertical.move(to: CGPoint(x: columnX, y: groundHeight))
                vertical.addLine(to: CGPoint(x: columnX, y: groundHeight + gridHeight))
                let line = SKShapeNode(path: vertical.cgPath)
                line.strokeColor = .gameLightSkyBlue
                self.addChild(line)
            }
        }
    }
    // MARK: - Helpers
    
    /**
     Gets the screen point at the centre of a GridReference
     */
    private func getPosition(_ reference: GridReference) -> CGPoint {
        
        var position = CGPoint.zero
        position.x = CGFloat(reference.column) * blockSize + blockSize/2.0 + side_space
        position.y = CGFloat(reference.row) * blockSize + blockSize/2 + groundHeight
        return position
    }
    
    private func getNode(_ block: Block) -> BlockNode? {
        blockNodes.first(where: { $0.block == block })
    }
        
    // MARK: - Score Methods
    public func updateScore(_ score: Int) {
        self.scoreLabel.text = "\(score)"
    }
    
    // MARK: - Player Methods

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

