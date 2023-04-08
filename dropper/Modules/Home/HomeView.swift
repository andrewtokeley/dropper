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
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = .white

        self.navigationController?.navigationBar.backgroundColor = .gameBackground
        self.navigationController?.navigationBar.tintColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
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
        
        return view
    }()
    
    private func setConstraints() {
        
        gamesCollectionView.autoPinEdge(toSuperviewEdge: .top, withInset: 120)
        gamesCollectionView.autoPinEdge(toSuperviewEdge: .left, withInset: 30)
        gamesCollectionView.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        gamesCollectionView.autoSetDimension(.height, toSize: 150)
        
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
        //collectionView.performBatchUpdates {
            // reorder collection view so the
        
        titles.move(fromOffsets: IndexSet(integer: indexPath.row), toOffset: 0)
        collectionView.moveItem(at: indexPath, to: IndexPath(item: 0, section: 0))

        // Assuming you have a UICollectionView instance named "collectionView"
        let firstIndexPath = IndexPath(item: 0, section: 0) // Assumes you have only one section
        collectionView.scrollToItem(at: firstIndexPath, at: .left, animated: true)

            //collectionView.reloadData()
        //}
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SmallGameTile
        
        let title = titles[indexPath.row]
        
        cell.gameTitleLabel.text = title.title
        
        if let accentColour = title.accentColorAsHex {
            let backgroundColour = UIColor.fromHex(hexString: accentColour)
            cell.background.backgroundColor = backgroundColour
            
            // add a grid
            let grid = try! BlockGrid(title.gridHeroLayout)
            let highlighted = title.gridHeroHighlight
            let gridView:GridView = GridView(grid, gridLinesColour: backgroundColour, highlighted: highlighted)
            cell.background.subviews.forEach( {$0.removeFromSuperview()} )
            cell.background.addSubview(gridView)
            gridView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        }
        
        

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
        
        // the first game is always the last played
        self.selectedGameView.configureView(title: self.titles[0], state: self.states[0])
        
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
