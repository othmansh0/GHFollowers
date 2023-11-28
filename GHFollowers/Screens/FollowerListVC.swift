//
//  FollowerListVC.swift
//  GHFollowers
//
//  Created by Othman Shahrouri on 17/11/2023.
//

import UIKit

class FollowerListVC: UIViewController {

    var username: String!
    var followers = [Follower]()
    var collectionView: UICollectionView!
    var page = 1
    var hasMoreFollowers = true
    enum Section {
        case main
    }

    var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationController?.navigationBar.prefersLargeTitles = true
        

        
        configureCollectionView()
        configureViewController()
        configureDataSource()
        collectionView.delegate = self
        getFollowers(username: username, page: page)
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
   
        navigationController?.setNavigationBarHidden(false, animated: true)
    }


    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelpers.createThreeColumnsFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    
    
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section,Follower>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, follower) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseID, for: indexPath) as! FollowerCell
            cell.set(follower: follower)
            return cell
        
        })
    }
    
    func updateData(followers: [Follower]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
        
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.isNavigationBarHidden = false
    }
    
    func getFollowers(username: String, page: Int) {
        showLoadingView()
        NetworkManager.shared.getFollowers(for: username, page: page) { [weak self] result in
           
           
            guard let self = self else { return }
            self.dismissLoadingView()
            switch result {
            case .success(let followers):
                
                if followers.count < 100 { self.hasMoreFollowers = false}
                self.followers.append(contentsOf: followers)
                if followers.isEmpty {DispatchQueue.main.async {self.showEmptyStateView(with: "This user doesn't have any followers. Go follow them 😄.", in: self.view)}}
                self.updateData(followers: self.followers)
                
            case .failure(let error):
                self.presentGFAlertOnMainThread(alertTitle: "Bad Stuff Happened", message: error.rawValue, buttonTitle: "OK")

            }
        }
    }
    
}


extension FollowerListVC: UICollectionViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height // entire height of the whole scrollview which holds 100 cells
        let height = scrollView.frame.size.height // height of the screen

    
        if height + offsetY > contentHeight {
            guard hasMoreFollowers else { return }
            page += 1
            getFollowers(username: username, page: page)
        }
    }
}
