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
    var states = [GameState?]()
    
    private func showCollectionView() {
        self.gamesCollectionView.alpha = 1
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = .white

        self.navigationController?.navigationBar.backgroundColor = .gameBackground
        self.navigationController?.navigationBar.tintColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        //self.view.addSubview(titleLabel)
        self.view.addSubview(gamesCollectionView)
        self.view.addSubview(selectedGameView)
        
        setConstraints()
        
        super.viewDidLoad()
    }
    
    lazy var selectedGameView: GameTile = {
        let view: GameTile = UIView.fromNib()
        view.delegate = self
        return view
    }()
    
    lazy var gamesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        view.delegate = self
        view.dataSource = self
        
        view.register(UINib(nibName: "SmallGameTile", bundle: .main), forCellWithReuseIdentifier: "cell")
        
        view.alpha = 0
        return view
    }()
    
    private func setConstraints() {
        
        gamesCollectionView.autoPinEdge(toSuperviewEdge: .top, withInset: 60)
        gamesCollectionView.autoPinEdge(toSuperviewEdge: .left, withInset: 30)
        gamesCollectionView.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        gamesCollectionView.autoSetDimension(.height, toSize: 120)
        
        selectedGameView.autoPinEdge(.top, to: .bottom, of: gamesCollectionView, withOffset: 40)
        selectedGameView.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        selectedGameView.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        selectedGameView.autoPinEdge(toSuperviewEdge: .bottom)
        
    }
    
}

extension HomeView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //let size = collectionView.frame.size.width *  0.85
        return CGSize(width: 150 , height: 150)
    }
}

extension HomeView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let title = titles[indexPath.row]
        let state = states[indexPath.row]
        selectedGameView.configureView(title: title, state: state)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SmallGameTile
        
        //cell.delegate = self
        let title = titles[indexPath.row]
        cell.gameTitleLabel.text = title.title
        if let accentColour = title.accentColorAsHex {
            cell.background.backgroundColor = UIColor.fromHex(hexString: accentColour)
        }
        
//        let state = states[indexPath.row]
//
//        cell.configureView(title: title, state: state)
        return cell
    }
    
    
}

extension HomeView: GameTileDelegate {
    func didSelectContinueGame(state: GameState) {
        presenter.didSelectContinueGame(state: state)
    }
    
    func didSelectNewGame(title: GameTitle) {
        presenter.didSelectPlay(gameTitle: title)
    }
}

//MARK: - HomeView API
extension HomeView: HomeViewApi {
    func displayGameTitles(titles: [GameTitle], states: [GameState?]) {
        self.titles = titles
        self.states = states
        self.gamesCollectionView.reloadData()
        
        // see if one of the games is marked as isLastPlayed
        let index = self.titles.firstIndex { $0.isLastPlayed } ?? 0
        self.selectedGameView.configureView(title: self.titles[index], state: self.states[index])
        
        if self.gamesCollectionView.alpha == 0 {
            UIView.animate(
                withDuration: 1.4,
                delay:0,
                options: .transitionCrossDissolve,
                animations: {
                    self.showCollectionView()
                })
        }
    }
    
    func displayConfirmation(title: String, confirmationButtonText: String, confirmationText: String, completion: ((Bool)->Void)?) {
        
        let modal = ModalDialogView.fromStoryboard("ModalDialog", identifier: "ModalDialogView", bundle: nil)
        
        var actions = [ModalDialogAction]()
        actions.append(ModalDialogAction(title: confirmationButtonText, style: .standard, handler: { action in
            completion?(true)
        }))
        actions.append(ModalDialogAction(title: "Cancel", style: .cancel, handler: { action in
            completion?(false)
        }))
        
        modal.show(from: self, title: title, message: confirmationText, actions: actions)
        
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
