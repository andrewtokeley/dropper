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
    var timer: Timer?
    
    @objc private func stopRotation() {
        self.presenter.animationComplete()
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
        
        // spin for a few seconds then stop :-)
        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(stopRotation), userInfo: nil, repeats: false)
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
