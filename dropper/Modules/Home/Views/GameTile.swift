//
//  GameTile.swift
//  dropper
//
//  Created by Andrew Tokeley on 28/03/23.
//

import Foundation
import UIKit

protocol GameTileDelegate {
    func didSelectContinueGame(state: GameState)
    func didSelectNewGame(title: GameTitle)
}
class GameTile: UIView {
    
    public var delegate: GameTileDelegate?
    private var state: GameState?
    private var title: GameTitle?
    
    //MARK: - Outletes
    
    @IBOutlet weak var highScoreSubText: UILabel!
    @IBOutlet weak var highscoreLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var primaryButton: UIButton!
    @IBOutlet weak var secondaryButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    //MARK: - Event Handlers

    @IBAction func handlePrimaryClick(_ sender: UIButton) {
        guard let title = self.title else { return }
        if state != nil {
            delegate?.didSelectContinueGame(state: state!)
        } else {
            delegate?.didSelectNewGame(title: title)
        }
    }
    
    @IBAction func handleSecondaryClick(_ sender: UIButton) {
        guard let title = self.title else { return }
        if state != nil {
            delegate?.didSelectNewGame(title: title)
        }
    }
    
    //MARK - Initialisers
    
    public func configureView(title: GameTitle, state: GameState?) {
        self.state = state
        self.title = title
        
        titleLabel.text = title.title
        if title.highScore > 0 {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            if let formattedNumber = numberFormatter.string(from: NSNumber(integerLiteral: title.highScore)) {
                highscoreLabel.text = "\(formattedNumber)"
                highScoreSubText.text = title.highScoreDescription
            }
        } else {
            highscoreLabel.text = "-"
            highScoreSubText.text = ""
        }
        if state != nil {
            primaryButton.setTitle("Continue Game", for: .normal)
            secondaryButton.alpha = 1
            secondaryButton.setTitle("New Game", for: .normal)
            
            var scoreMessage: String = ""
            if state!.score > 0 {
                scoreMessage = "\nYour current score is \(state!.score)"
                if let _ = title as? JewelTitle {
                    if let jewels = state?.gameAchievements.get(.jewel) {
                        if jewels > 1 {
                            scoreMessage += " and you've get \(jewels) jewels!"
                        }
                    }
                }
            }
            
            messageLabel.text = "Continue to keep the game alive! \(scoreMessage)"
        } else {
            secondaryButton.alpha = 0
            primaryButton.setTitle("New Game", for: .normal)
            messageLabel.text = ""
        }
    }
    
    override func awakeFromNib() {
        primaryButton.layer.shadowColor = UIColor.black.cgColor
        primaryButton.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        primaryButton.layer.shadowRadius = 6
        primaryButton.layer.shadowOpacity = 0.1
        
        secondaryButton.layer.shadowColor = UIColor.black.cgColor
        secondaryButton.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        secondaryButton.layer.shadowRadius = 6
        secondaryButton.layer.shadowOpacity = 0.1
    }
}
