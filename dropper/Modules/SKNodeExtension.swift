//
//  SceneLayout.swift
//  dropper
//
//  Created by Andrew Tokeley on 15/03/23.
//

import Foundation
import SpriteKit

enum APEdge {
    case top
    case bottom
    case left
    case right
    case verticalCentre
    case horizontalCentre
}

enum APPosition {
    case leftTop
    case leftBottom
    case leftCentre
    case rightTop
    case rightCentre
    case rightBottom
    case centreTop
    case centre
    case centreBottom
}

extension SKNode {
    
    private func autoAdjustForLabel() -> CGPoint {
        var offSet = CGPoint.zero
        if let label = self as? SKLabelNode {
            let width = self.frame.size.width
            let height = self.frame.size.height
            if label.horizontalAlignmentMode == .left {
                offSet.x = -width/2
            } else if label.horizontalAlignmentMode == .right {
                offSet.x = width/2
            }
            if label.verticalAlignmentMode == .top {
                offSet.y = height/2
            } else if label.verticalAlignmentMode == .bottom {
                offSet.y = -height/2
            }
            
        }
        return offSet
    }
//
//    func autoDistanceToEdge(_ edge: APEdge, fromEdge: APEdge, ofNode node: SKNode) -> CGFloat {
//        var distance: CGFloat = 0
//
//        return distance
//    }
//
//    func autoAlignEdge(_ edge: APEdge, withSameEdgeOfNode node: SKNode) {
//        // distance of node from withEdge
//        var distance: CGFloat = 0
//        let nodeWidth = self.frame.size.width
//        let nodeHeight = self.frame.size.height
//
//        switch edge {
//        case .top:
//            distance = height - node.position.y + 0.5 * node.frame.size.height
//        case .bottom:
//            <#code#>
//        case .left:
//            <#code#>
//        case .right:
//            <#code#>
//        case .verticalCentre:
//            <#code#>
//        case .horizontalCentre:
//            <#code#>
//        }
//    }
//
    func autoPositionWithinScene(_ position: APPosition, xOffSet: CGFloat = 0, yOffSet: CGFloat = 0) {
        switch position {
        case .leftTop:
            autoPositionWithinScene(.left, offSet: xOffSet)
            autoPositionWithinScene(.top, offSet: yOffSet)
            break
        case .leftBottom:
            autoPositionWithinScene(.left, offSet: xOffSet)
            autoPositionWithinScene(.bottom, offSet: yOffSet)
            break
        case .leftCentre:
            autoPositionWithinScene(.left, offSet: xOffSet)
            autoPositionWithinScene(.verticalCentre, offSet: yOffSet)
            break
        case .rightTop:
            autoPositionWithinScene(.right, offSet: xOffSet)
            autoPositionWithinScene(.top, offSet: yOffSet)
            break
        case .rightCentre:
            autoPositionWithinScene(.right, offSet: xOffSet)
            autoPositionWithinScene(.verticalCentre, offSet: yOffSet)
            break
        case .rightBottom:
            autoPositionWithinScene(.right, offSet: xOffSet)
            autoPositionWithinScene(.bottom, offSet: yOffSet)
            break
        case .centreTop:
            autoPositionWithinScene(.horizontalCentre, offSet: xOffSet)
            autoPositionWithinScene(.top, offSet: yOffSet)
            break
        case .centre:
            autoPositionWithinScene(.horizontalCentre, offSet: xOffSet)
            autoPositionWithinScene(.verticalCentre, offSet: yOffSet)
            break
        case .centreBottom:
            autoPositionWithinScene(.horizontalCentre, offSet: xOffSet)
            autoPositionWithinScene(.bottom, offSet: yOffSet)
            break
        }
    }
    
    /**
     Repositions the node to an edge of the view.
     */
    private func autoPositionWithinScene(_ edge: APEdge, offSet: CGFloat = 0) {
        guard let scene = self.scene else { return }
        
        // To simplify calculations, the new position is calculated assuming the node has a centre anchor, then adjusted based on the actual anchor.
        var newPosition = position
        let nodeWidth = self.frame.size.width
        let nodeHeight = self.frame.size.height
        
        switch edge {
        case .left:
            newPosition.x = nodeWidth/2 + offSet
            newPosition.x += self.autoAdjustForLabel().x
            break
        case .right:
            newPosition.x = scene.size.width - (nodeWidth/2 + offSet)
            newPosition.x += self.autoAdjustForLabel().x
            break
        case .top:
            newPosition.y = scene.size.height - (nodeHeight/2 + offSet)
            newPosition.y += self.autoAdjustForLabel().y
            break
        case .bottom:
            newPosition.y = nodeHeight/2 + offSet
            newPosition.y += self.autoAdjustForLabel().y
            break
        case .verticalCentre:
            newPosition.y = scene.size.height/2 + offSet
            newPosition.y += self.autoAdjustForLabel().y
        case .horizontalCentre:
            newPosition.x = scene.size.width/2 + offSet
            newPosition.x += self.autoAdjustForLabel().x
        }
        
        position = newPosition
    }
    
}
