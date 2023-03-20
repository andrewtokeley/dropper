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

    func autoPositionWithinParent(_ position: APPosition, xOffSet: CGFloat = 0, yOffSet: CGFloat = 0) {
        switch position {
        case .leftTop:
            autoPositionWithinParent(.left, offSet: xOffSet)
            autoPositionWithinParent(.top, offSet: yOffSet)
            break
        case .leftBottom:
            autoPositionWithinParent(.left, offSet: xOffSet)
            autoPositionWithinParent(.bottom, offSet: yOffSet)
            break
        case .leftCentre:
            autoPositionWithinParent(.left, offSet: xOffSet)
            autoPositionWithinParent(.verticalCentre, offSet: yOffSet)
            break
        case .rightTop:
            autoPositionWithinParent(.right, offSet: xOffSet)
            autoPositionWithinParent(.top, offSet: yOffSet)
            break
        case .rightCentre:
            autoPositionWithinParent(.right, offSet: xOffSet)
            autoPositionWithinParent(.verticalCentre, offSet: yOffSet)
            break
        case .rightBottom:
            autoPositionWithinParent(.right, offSet: xOffSet)
            autoPositionWithinParent(.bottom, offSet: yOffSet)
            break
        case .centreTop:
            autoPositionWithinParent(.horizontalCentre, offSet: xOffSet)
            autoPositionWithinParent(.top, offSet: yOffSet)
            break
        case .centre:
            autoPositionWithinParent(.horizontalCentre, offSet: xOffSet)
            autoPositionWithinParent(.verticalCentre, offSet: yOffSet)
            break
        case .centreBottom:
            autoPositionWithinParent(.horizontalCentre, offSet: xOffSet)
            autoPositionWithinParent(.bottom, offSet: yOffSet)
            break
        }
    }
    
    /**
     Repositions the node to an edge of the view.
     */
    private func autoPositionWithinParent(_ edge: APEdge, offSet: CGFloat = 0) {
        guard let parent = self.parent else { return }
        
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
            newPosition.x = parent.frame.size.width - (nodeWidth/2 + offSet)
            newPosition.x += self.autoAdjustForLabel().x
            break
        case .top:
            newPosition.y = parent.frame.size.height - (nodeHeight/2 + offSet)
            newPosition.y += self.autoAdjustForLabel().y
            break
        case .bottom:
            newPosition.y = nodeHeight/2 + offSet
            newPosition.y += self.autoAdjustForLabel().y
            break
        case .verticalCentre:
            newPosition.y = parent.frame.size.height/2 + offSet
            newPosition.y += self.autoAdjustForLabel().y
        case .horizontalCentre:
            newPosition.x = parent.frame.size.width/2 + offSet
            newPosition.x += self.autoAdjustForLabel().x
        }
        
        position = newPosition
    }
    
}
