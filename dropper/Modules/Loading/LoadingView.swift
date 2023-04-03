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
    
    @IBOutlet weak var spinner: UIView!
    @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageLeftConstraint: NSLayoutConstraint!
    
    var timer: Timer?
    
    @objc private func doAnimation() {
        UIView.animate(
            withDuration: 1.1,
            delay:0,
            options: .transitionCrossDissolve,
            animations: {
                self.spinner.alpha = 0
                self.imageLeftConstraint.constant = 30
                self.imageTopConstraint.constant = 30
                self.view.layoutIfNeeded()
            }) { resut in
                self.presenter.animationComplete()
        }
    }
    
//    var count: Int = 0
//    @objc private func updateProgress() {
//        loadingLabel.text = getLoadingText(count)
//        count += 1
//        if count > 6 {
//            self.timer?.invalidate()
//            self.timer = nil
//            UIView.animate(
//                withDuration: 1.1,
//                delay:0,
//                options: .transitionCrossDissolve,
//                animations: self.doAnimation) { resut in
//                    self.presenter.animationComplete()
//            }
//        }
//    }
    
//    private func getLoadingText(_ iteration: Int) -> String {
//        switch iteration {
//        case 0: return "loading.  "
//        case 1: return "loading.. "
//        case 2: return "loading..."
//        case 3: return "loading.. "
//        case 4: return "loading.  "
//        case 5: return "loading   "
//        case 6: return ""
//        default: return ""
//        }
//    }
}

//MARK: - LoadingView API
extension LoadingView: LoadingViewApi {
    
    func animateImage() {
        self.spinner.rotate(3)
        //self.count = 0
        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(doAnimation), userInfo: nil, repeats: false)
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
