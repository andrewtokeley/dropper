//
//  ModalDialogView.swift
//  dropper
//
//  Created by Andrew Tokeley on 29/03/23.
//
//

import UIKit
import Viperit

enum ModalDialogButtonType {
    case primary
    case secondary
}

//MARK: ModalDialogView Class
final class ModalDialogView: UserInterface {
    
    @IBOutlet weak var primaryButton: UIButton!
    @IBOutlet weak var secondaryButton: UIButton!
    
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var dialogView: UIView!
    
    // MARK: - Handlers
    @IBAction func handleSecondaryButtonClick(_ sender: UIButton) {
        presenter.didSelectButton(.secondary)
    }
    
    @IBAction func handlePrimaryButtonClick(_ sender: UIButton) {
        presenter.didSelectButton(.primary)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.alpha = 0
        dialogView.layer.cornerRadius = 25
    }
}

//MARK: - ModalDialogView API
extension ModalDialogView: ModalDialogViewApi {
    func display(_ heading: String, message: String, primaryButtonText: String, secondaryButtonText: String?) {
        headingLabel.text = heading
        bodyLabel.text = message
        primaryButton.titleLabel?.text = primaryButtonText
        if let secondaryButtonText = secondaryButtonText {
            secondaryButton.titleLabel?.text = secondaryButtonText
            secondaryButton.alpha = 1
        } else {
            secondaryButton.alpha = 0
        }
    }
}

// MARK: - ModalDialogView Viper Components API
private extension ModalDialogView {
    var presenter: ModalDialogPresenterApi {
        return _presenter as! ModalDialogPresenterApi
    }
    var displayData: ModalDialogDisplayData {
        return _displayData as! ModalDialogDisplayData
    }
}
