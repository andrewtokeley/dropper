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
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .gameBackground
        self.view.addSubview(button)
        self.navigationController?.navigationBar.backgroundColor = .gameBackground
        self.navigationController?.navigationBar.tintColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setConstraints()
    }
    
    lazy var button: UIButton = {
        let action = UIAction { action in
            self.presenter.didSelectPlay()
        }
        let view = UIButton(primaryAction: action)
        view.setTitle("Play", for: UIControl.State.normal)
        return view
    }()
    
    private func setConstraints() {
        button.autoCenterInSuperview()
    }
    
    @objc func settingsTapped(_ sender: UIBarButtonItem) {
        
    }
}

//MARK: - HomeView API
extension HomeView: HomeViewApi {
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
