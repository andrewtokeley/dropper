//
//  HomeView.swift
//  dropper
//
//  Created by Andrew Tokeley on 14/03/23.
//
//

import UIKit
import Viperit

//MARK: HomeView Class
final class HomeView: UserInterface {
    
    var titles = [GameTitle]()
    
    override func viewDidLoad() {
        self.view.backgroundColor = .gameBackground
        
        self.navigationController?.navigationBar.backgroundColor = .gameBackground
        self.navigationController?.navigationBar.tintColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.view.addSubview(titleLabel)
        //self.view.addSubview(collectionView)
        self.view.addSubview(stackView)
        
        setConstraints()
        
        super.viewDidLoad()
    }
    
    func playView(_ title: GameTitle) -> UIButton {
        
        let action = UIAction { action in
            self.presenter.didSelectPlay(gameTitle: title)
        }
        let view = UIButton(primaryAction: action)
        
        //view.backgroundColor = .gameBackground
        view.backgroundColor = .white
        view.setTitleColor(.gameBackground, for: .normal)
        view.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        view.setTitle(title.title, for: .normal)
        view.layer.cornerRadius = 25

        return view
    }
    
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.text = "TETRIS"
        view.font = UIFont.boldSystemFont(ofSize: 80)
        view.textColor = .white
        view.textAlignment = .center
        
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 40
        view.alignment = .center
        return view
    }()
    
    private func setConstraints() {
        
        titleLabel.autoSetDimension(.height, toSize: 150)
        titleLabel.autoPinEdge(toSuperviewMargin: .top)
        titleLabel.autoPinEdge(toSuperviewMargin: .left)
        titleLabel.autoPinEdge(toSuperviewMargin: .right)
        
        stackView.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 0)
        stackView.autoPinEdge(toSuperviewEdge: .left)
        stackView.autoPinEdge(toSuperviewEdge: .right)
        stackView.autoPinEdge(toSuperviewEdge: .bottom)
        stackView.autoSetDimension(.height, toSize: 300)
        
    }
    
    @objc func settingsTapped(_ sender: UIBarButtonItem) {
        
    }
}

//MARK: - HomeView API
extension HomeView: HomeViewApi {
    func displayGameTitles(titles: [GameTitle]) {
        
        // remove all arranged views
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
            stackView.removeArrangedSubview(view)
        }
        
        self.titles = titles
        
        for title in titles {
            let view = UIView()
            
            let button = self.playView(title)
            view.addSubview(button)
            
            button.autoSetDimension(.height, toSize: 50)
            button.autoPinEdge(.left, to: .left, of: view)
            button.autoPinEdge(.right, to: .right, of: view)
            
            if title.highScore > 0 {
                let label = UILabel()
                label.textColor = .white
                label.font = UIFont.systemFont(ofSize: 18)
                label.textAlignment = .center
                label.text = "Highscore \(title.highScore)"
                view.addSubview(label)
                label.autoPinEdge(.top, to: .bottom, of: button, withOffset: 10)
                label.autoPinEdge(.left, to: .left, of: view, withOffset: 30)
                label.autoPinEdge(.right, to: .right, of: view, withOffset: -30)
            }
            
            stackView.addArrangedSubview(view)
            view.autoPinEdge(.left, to: .left, of: stackView, withOffset: 30)
            view.autoPinEdge(.right, to: .right, of: stackView, withOffset: -30)
            view.autoSetDimension(.height, toSize: 100)
        }
        
    }
}

// MARK: - HomeView Viper Components API
private extension HomeView {
    var presenter: HomePresenterApi {
        return _presenter as! HomePresenterApi
    }
    var displayData: HomeDisplayData {
        return _displayData as! HomeDisplayData
    }
}
