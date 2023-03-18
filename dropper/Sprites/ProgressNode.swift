//
//  ProgressNode.swift
//  dropper
//
//  Created by Andrew Tokeley on 14/03/23.
//

import Foundation
import SpriteKit

class ProgressNode: SKSpriteNode {

    private var progress = CGFloat(0)
    private var maxProgress = CGFloat(9)
    
    private var progressBar = SKSpriteNode()
    private var progressBarContainer = SKSpriteNode()
    
    init(size: CGSize) {
        super.init(texture: nil, color: .clear, size: size)
        buildNode()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildNode()
    }
    
    func buildNode() {
        progressBarContainer = SKSpriteNode(color: .white, size: self.frame.size)
        //progressBarContainer.anchorPoint = CGPoint(x:0, y:0.5)
        progressBar = SKSpriteNode(color: .gameHighlight, size: CGSize.zero)
        progressBar.size.width = progressBarContainer.size.width*0.7
        progressBar.size.height = progressBarContainer.size.height
        progressBar.position = CGPoint(x: -(progressBarContainer.size.width - progressBar.size.width)/2, y: 0)
        progressBarContainer.addChild(progressBar)
        
        addChild(progressBarContainer)
    }
    
    public func updateProgress(_ progress: Double) {
        progressBar.size.width = progressBarContainer.size.width * progress
        progressBar.position = CGPoint(x: -(progressBarContainer.size.width - progressBar.size.width)/2, y: 0)
    }
    
}
