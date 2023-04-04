//
//  ModalDialogView.swift
//  dropper
//
//  Created by Andrew Tokeley on 29/03/23.
//
//

import UIKit
import Viperit

//MARK: ModalDialogView Class

final class ModalDialogView: UIViewController {
    
    // MARK: - Private Properties
    
    private let buttonHeight:CGFloat = 50
    private let buttonSpacing:CGFloat = 10
    
    private var presentFrom: UIViewController?
    public var actions = [ModalDialogAction]()
    private var heading: String = ""
    private var body: String = ""

    // MARK: - Outlets
    @IBOutlet weak var backgroundMask: UIView!
    @IBOutlet weak var actionsStackView: UIStackView!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    
    // MARK: - UIViewController
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.modalPresentationStyle = .overCurrentContext
        //
    }
    
    override func viewDidLoad() {
        dialogView.layer.cornerRadius = 25
        
        self.headingLabel.text = self.heading
        self.bodyLabel.text = self.body
        
        for action in actions {
            addAction(action)
        }
        
        registerTapEvent()
    }
    
    
    // MARK: - Controls
    
    private func getButton(_ action: ModalDialogAction) -> UIButton? {
        
        let button = UIButton()

        // Rounded corners
        button.setTitle(action.title, for: UIControl.State.normal)
        button.layer.cornerRadius = 0.5 * self.buttonHeight
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        // Drop Shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.1
        // Font
        switch action.style {
        case .standard:
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            break
        case .cancel:
            button.backgroundColor = .white
            button.setTitleColor(.systemBlue, for: .normal)
            break
        case .destructive:
            button.backgroundColor = .systemRed
            button.setTitleColor(.white, for: .normal)
            break
        }
        
        // Action
        let uiAction = UIAction { _ in
            self.presentingViewController?.dismiss(animated: true)
            action.handler?(action)
        }
        button.addAction(uiAction , for: .touchUpInside)
        
        return button
    }
    
    // MARK: - Public Methods
    
    public func show(from viewController: UIViewController, title: String, message: String, actions: [ModalDialogAction]) {
         
        self.heading = title
        self.body = message
        self.actions = actions
        viewController.present(self, animated: false)
    }
    
    // MARK: - Private Methods

    private func addAction(_ action: ModalDialogAction) {
        if let button = getButton(action) {
            
            self.actionsStackView.addArrangedSubview(button)
            
            // for each action button we add the stackview needs to grow
            // button
            // buttonSpacing
            // button
            let n = CGFloat(self.actions.count)
            let stackHeight:CGFloat = n * self.buttonHeight + (n - 1) * self.buttonSpacing
            self.stackViewHeight.constant = stackHeight
        }
    }
    
    private func registerTapEvent() {
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(handleTap))
        self.backgroundMask.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            // find a cancel action
            if let cancel = self.actions.first(where: { $0.style == .cancel }) {
                self.presentingViewController?.dismiss(animated: true)
                cancel.handler?(cancel)
            }
            
        }
    }
}
