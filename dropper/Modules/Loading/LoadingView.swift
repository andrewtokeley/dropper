//
//  LoadingView.swift
//  dropper
//
//  Created by Andrew Tokeley on 3/04/23.
//
//

import UIKit
import Viperit

//MARK: LoadingView Class
final class LoadingView: UserInterface {
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageLeftConstraint: NSLayoutConstraint!
    
    private func doAnimation() {
        imageLeftConstraint.constant = 30
        imageTopConstraint.constant = 30
        self.view.layoutIfNeeded()
    }
    
    private func getLoadingText(_ iteration: Int) -> String {
        switch iteration {
        case 0: return "Loading."
        case 1: return "Loading.."
        case 2: return "Loading..."
        case 3: return "Loading."
        case 4: return "Loading.."
        case 5: return "Loading..."
        default: return "Loading."
        }
    }
}

//MARK: - LoadingView API
extension LoadingView: LoadingViewApi {
    
    func animateImage() {
        let dispatch = DispatchGroup()
        
        for i in 0..<6 {
            dispatch.enter()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.loadingLabel.text = self.getLoadingText(i)
                print("it \(i)")
                dispatch.leave()
            }
        }
        dispatch.notify(queue: DispatchQueue.main, execute: {
            UIView.animate(
                withDuration: 1.0,
                delay:0,
                options: .transitionCrossDissolve,
                animations: self.doAnimation) { resut in
                self.presenter.animationComplete()
            }
        })
    }
}

// MARK: - LoadingView Viper Components API
private extension LoadingView {
    var presenter: LoadingPresenterApi {
        return _presenter as! LoadingPresenterApi
    }
    var displayData: LoadingDisplayData {
        return _displayData as! LoadingDisplayData
    }
}
