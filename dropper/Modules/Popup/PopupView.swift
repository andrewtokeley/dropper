//
//  PopupView.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/03/23.
//
//

import UIKit
import Viperit

fileprivate struct Layout {
    var parentFrame: CGRect
    var numberOfButtons: Int
    
    init(numberOfButtons: Int = 1, parentFrame: CGRect) {
        self.parentFrame = parentFrame
        self.numberOfButtons = numberOfButtons
    }

    let spacer: CGFloat = 20
    let buttonHeight: CGFloat = 50
    
    var buttonWidth: CGFloat {
        return popUpWidth - 2 * spacer
    }
    var bodyWidth: CGFloat {
        return popUpWidth - 2 * spacer
    }
    var bodyHeight: CGFloat {
        return 2 * self.buttonHeight
    }
    var titleHeight: CGFloat {
        return self.buttonHeight
    }
    var popUpWidth: CGFloat {
        return 0.8 * parentFrame.width
    }
    var popUpHeight: CGFloat {
        return titleHeight + bodyHeight + buttonHeight * CGFloat(numberOfButtons)
    }
}

//MARK: PopupView Class
final class PopupView: UserInterface {
    
    var delegate: PopupDelegate?
    
    fileprivate var layout: Layout?
    
    lazy var background: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.6
        return view
    }()
    
    lazy var popup: UIView = {
       let view = UIView()
        view.layer.cornerRadius = 20
        view.backgroundColor = .white
        return view
    }()
    
    lazy var heading: UILabel = {
       let view = UILabel()
        view.textColor = .black
        view.font = UIFont.boldSystemFont(ofSize: 20)
        return view
    }()
    
    lazy var message: UILabel = {
       let view = UILabel()
        view.textAlignment = .center
        view.textColor = .gray
        view.numberOfLines = 4
        view.font = UIFont.systemFont(ofSize: 14)
        
        return view
    }()
    
    lazy var primaryButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .gameBackground
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        view.layer.cornerRadius = 25
        view.addTarget(self, action: #selector(handleButtonClick), for: .touchUpInside)
        return view
    }()
    
    lazy var secondaryButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .gameLightGray
        view.setTitleColor(.gray, for: .normal)
        view.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        view.layer.cornerRadius = 25
        view.addTarget(self, action: #selector(handleButtonClick), for: .touchUpInside)
        return view
    }()
    
    override func viewDidLoad() {
        view.addSubview(background)
        view.addSubview(popup)
        view.addSubview(primaryButton)
        view.addSubview(heading)
        view.addSubview(message)
        view.addSubview(secondaryButton)
        
        //setConstraints()
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    private func setConstraints(numberOfButtons: Int = 1) {
        let layout = Layout(numberOfButtons: numberOfButtons, parentFrame: self.view.frame)
        
        background.autoPinEdgesToSuperviewEdges()
        
        popup.autoSetDimension(.width, toSize: layout.popUpWidth)
        popup.autoSetDimension(.height, toSize: layout.popUpHeight)
        popup.autoCenterInSuperview()
        
        heading.autoAlignAxis(.vertical, toSameAxisOf: popup)
        heading.autoPinEdge(.top, to: .top, of: popup, withOffset: layout.spacer)
        
        message.autoAlignAxis(.vertical, toSameAxisOf: popup)
        message.autoSetDimension(.width, toSize: layout.bodyWidth)
        message.autoPinEdge(.top, to: .bottom, of: heading, withOffset: layout.spacer)
        
        primaryButton.autoSetDimension(.width, toSize: layout.buttonWidth)
        primaryButton.autoSetDimension(.height, toSize: layout.buttonHeight)
        primaryButton.autoAlignAxis(.vertical, toSameAxisOf: popup)
        primaryButton.autoPinEdge(.top, to: .bottom, of: message, withOffset: layout.spacer)
        
        if layout.numberOfButtons == 2 {
            secondaryButton.alpha = 1
            secondaryButton.autoSetDimension(.width, toSize: layout.buttonWidth)
            secondaryButton.autoSetDimension(.height, toSize: layout.buttonHeight)
            secondaryButton.autoAlignAxis(.vertical, toSameAxisOf: popup)
            secondaryButton.autoPinEdge(.bottom, to: .bottom, of: popup, withOffset: -layout.spacer)
        } else {
            secondaryButton.alpha = 0
        }
        
        
    }
    
    @objc func handleButtonClick(_ sender: UIButton) {
        if let buttonText = sender.title(for: .normal) {
            presenter.didSelectButton(buttonText)
        }
        self.dismiss(animated: true)
    }
}

//MARK: - PopupView API
extension PopupView: PopupViewApi {
    func display(_ title: String, message: String, buttonText: String, secondaryButtonText: String? = nil) {
        self.heading.text = title
        self.message.text = message
        self.primaryButton.setTitle(buttonText, for: .normal)
        
        if let secondaryButtonText = secondaryButtonText {
            self.secondaryButton.setTitle(secondaryButtonText, for: .normal)
            self.setConstraints(numberOfButtons: 2)
        } else {
            self.setConstraints(numberOfButtons: 1)
        }
        self.view.setNeedsLayout()
    }
    
}

// MARK: - PopupView Viper Components API
private extension PopupView {
    var presenter: PopupPresenterApi {
        return _presenter as! PopupPresenterApi
    }
    var displayData: PopupDisplayData {
        return _displayData as! PopupDisplayData
    }
}
