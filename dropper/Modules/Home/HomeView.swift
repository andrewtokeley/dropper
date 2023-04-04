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
        self.collectionView.alpha = 1
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = .white

        self.navigationController?.navigationBar.backgroundColor = .gameBackground
        self.navigationController?.navigationBar.tintColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        //self.view.addSubview(titleLabel)
        self.view.addSubview(headerImage)
        self.view.addSubview(collectionView)
        
        setConstraints()
        
        super.viewDidLoad()
    }
    
    lazy var headerImage: UIImageView = {
        let view = UIImageView(image: UIImage(named: "tiles"))
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.text = "TETRIS"
        view.font = UIFont.boldSystemFont(ofSize: 80)
        view.textColor = .black
        view.textAlignment = .center
        
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.delegate = self
        view.dataSource = self
        
        view.register(UINib(nibName: "GameTile", bundle: .main), forCellWithReuseIdentifier: "cell")
        
        view.alpha = 0
        return view
    }()
    
    private func setConstraints() {
        
        headerImage.autoPinEdge(toSuperviewEdge: .top, withInset: 30)
        headerImage.autoAlignAxis(toSuperviewAxis: .vertical)
        headerImage.autoPinEdge(toSuperviewEdge: .left, withInset: 30)
        
        
        
//        titleLabel.autoSetDimension(.height, toSize: 150)
//        titleLabel.autoPinEdge(toSuperviewMargin: .top)
//        titleLabel.autoPinEdge(toSuperviewMargin: .left)
//        titleLabel.autoPinEdge(toSuperviewMargin: .right)
        
        collectionView.autoPinEdge(.top, to: .bottom, of: headerImage, withOffset: 40)
        collectionView.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        collectionView.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        collectionView.autoPinEdge(toSuperviewEdge: .bottom)
        
    }
    
}

extension HomeView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = collectionView.frame.size.width *  0.85
        return CGSize(width: size , height: 240)
    }
}

extension HomeView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GameTile
        
        cell.delegate = self
        let title = titles[indexPath.row]
        let state = states[indexPath.row]
        
        cell.configureView(title: title, state: state)
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
        self.collectionView.reloadData()
        
        if self.collectionView.alpha == 0 {
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
