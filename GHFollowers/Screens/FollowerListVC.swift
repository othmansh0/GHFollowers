//
//  FollowerListVC.swift
//  GHFollowers
//
//  Created by Othman Shahrouri on 17/11/2023.
//

import UIKit


protocol FollowerListVCDelegate: AnyObject {
    func didRequestFollowers(for username: String)
}
class FollowerListVC: UIViewController {
    var username: String!
    var followers = [Follower]()
    var filteredFollowers: [Follower] = []
    var isSearching = false
    var collectionView: UICollectionView!
    var page = 1
    var hasMoreFollowers = true
    enum Section { case main }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureViewController()
        configureDataSource()
        collectionView.delegate = self
        getFollowers(username: username, page: page)
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
           navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.setNeedsLayout()

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
    
    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search for a username"
        
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
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
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray = isSearching ? filteredFollowers : followers
        let follower = activeArray[indexPath.row]
        
        let vc = UserInfoVC()
        vc.delegate = self
        vc.username = follower.login
        
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true)
    }
}


extension FollowerListVC: UISearchResultsUpdating,UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let filter = searchController.searchBar.text, !filter.isEmpty,filter != " "  else { return }
        
        isSearching = true
        filteredFollowers = followers.filter{$0.login.lowercased().contains(filter.lowercased())}
        updateData(followers: filteredFollowers)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchCanceled()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { //To update data when cross button is tapped
        if searchText.isEmpty { searchCanceled() }
    }
    
    private func searchCanceled() {
        isSearching = false
        updateData(followers: followers)
    }
    
}


extension FollowerListVC: FollowerListVCDelegate {
    func didRequestFollowers(for username: String) {
        print("selected user is \(username)")
        self.username = username
        title = username
        page = 1
        followers.removeAll()
        filteredFollowers.removeAll()
        if isSearching {
                   navigationItem.searchController?.searchBar.text = ""
                   navigationItem.searchController?.isActive = false
                   navigationItem.hidesSearchBarWhenScrolling = false
                   navigationItem.searchController?.dismiss(animated: false)
                   isSearching = false
               }
        
        
//        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        getFollowers(username: username, page: page)
        updateData(followers: followers)
    }
    
    
    
}
