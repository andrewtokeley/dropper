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
        view.distribution = .equalSpacing
        view.spacing = 30
        view.alignment = .center
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        // make sure that there is a slightly larger gap at the top of each row
        layout.sectionInset = UIEdgeInsets(top: 20, left: 30, bottom: 10, right: 30)
        // set a standard item size of 60 * 60
        layout.itemSize = CGSize(width: self.view.frame.width - 60, height: 100)
        // the layout scrolls horizontally
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CELL")
        return view
    }()
    
    
    private func setConstraints() {
        
        titleLabel.autoSetDimension(.height, toSize: 200)
        titleLabel.autoPinEdge(toSuperviewMargin: .top)
        titleLabel.autoPinEdge(toSuperviewMargin: .left)
        titleLabel.autoPinEdge(toSuperviewMargin: .right)
        
        stackView.autoPinEdge(.top, to: .bottom, of: titleLabel)
        stackView.autoPinEdge(toSuperviewEdge: .left)
        stackView.autoPinEdge(toSuperviewEdge: .right)
        stackView.autoSetDimension(.height, toSize: 200)
        
//        collectionView.autoPinEdge(.top, to: .bottom, of: titleLabel)
//        collectionView.autoPinEdge(toSuperviewEdge: .left)
//        collectionView.autoPinEdge(toSuperviewEdge: .right)
//        collectionView.autoPinEdge(toSuperviewEdge: .bottom)
    }
    
    @objc func settingsTapped(_ sender: UIBarButtonItem) {
        
    }
}

//MARK: - CollectionView Delegate
extension HomeView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.titles.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

extension HomeView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath)
        let title = self.titles[indexPath.row]
        let action = UIAction { action in
            self.presenter.didSelectPlay(gameTitle: title)
        }
        let view = UIButton(primaryAction: action)
        view.setTitle("\(title.title.uppercased())", for: UIControl.State.normal)
        view.setTitleColor(.white, for: .normal)
        cell.contentView.addSubview(view)
        view.autoPinEdgesToSuperviewEdges()
        cell.backgroundColor = .gameBackground
        cell.layer.cornerRadius = 20
        return cell
    }
    
    
}


//MARK: - HomeView API
extension HomeView: HomeViewApi {
    
    func displayGameTitles(_ titles: [GameTitle]) {
        self.titles = titles
        
        for title in titles {
            let button = self.playView(title)
            stackView.addArrangedSubview(button)
            button.autoPinEdge(toSuperviewEdge: .left, withInset: 30)
            button.autoPinEdge(toSuperviewEdge: .right, withInset: 30)
            button.autoSetDimension(.height, toSize: 50)
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
