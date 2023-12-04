//
//  UserInfoVC.swift
//  GHFollowers
//
//  Created by Othman Shahrouri on 01/12/2023.
//

import UIKit

protocol UserInfoVCDelegate: AnyObject {
    func didTapGitHubProfile(for user: User)
    func didTapGetFollowers(for user: User)
}

class UserInfoVC: UIViewController {

    let headerView = UIView()
    let itemViewOne = UIView()
    let itemViewTwo = UIView()
    let dateLabel = GFBodyLabel(textAlignment: .center)
    var itemViews: [UIView] = []
    
   weak var delegate: FollowerListVCDelegate!
    var username: String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        configureNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureViewController()
        layoutUI()
        getUserInfo()
        
    }
    
    
    
    private func configureNavigationBar() {
       if #available(iOS 15, *) {
           let appearance = UINavigationBarAppearance()
           appearance.configureWithOpaqueBackground()
           navigationController?.navigationBar.standardAppearance = appearance
           navigationController?.navigationBar.scrollEdgeAppearance = appearance
           let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
           navigationItem.rightBarButtonItem = doneButton
       }
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationController?.navigationItem.leftBarButtonItem = doneButton
     }
    
    
    func configureViewController() {
        configureNavigationBar()
    }
    
    
    func getUserInfo() {
        NetworkManager.shared.getUserInfo(for: username) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                DispatchQueue.main.async {self.configureUIElements(user:user)}
            case .failure(let error):
                presentGFAlertOnMainThread(alertTitle: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    
    
    private func configureUIElements(user: User) {
        
        let repoItemVc = GFRepoItemVC(user: user)
        repoItemVc.delegate = self
        
        let followerVC = GFFollowerVC(user: user)
        followerVC.delegate = self
        
      
            self.add(childVC: GFUserInfoHeaderVC(user: user), to: self.headerView)
            self.add(childVC: repoItemVc, to: self.itemViewOne)
            self.add(childVC: followerVC, to: self.itemViewTwo)
            self.dateLabel.text = "GitHub since\(user.createdAt.convertToDisplayFormat())"
        
    }
    
    func layoutUI() {
        
        let padding: CGFloat = 20
        let itemHeight: CGFloat = 140
        
        itemViews = [headerView,itemViewOne,itemViewTwo,dateLabel]
        for itemView in itemViews {
            view.addSubview(itemView)
            itemView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: padding),
                itemView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -padding)
            ])
        }
        
       
       
    
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 180),
            
            itemViewOne.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: padding),
            itemViewOne.heightAnchor.constraint(equalToConstant: itemHeight),
            
            itemViewTwo.topAnchor.constraint(equalTo: itemViewOne.bottomAnchor, constant: padding),
            itemViewTwo.heightAnchor.constraint(equalToConstant: itemHeight),
            
            dateLabel.topAnchor.constraint(equalTo: itemViewTwo.bottomAnchor, constant: padding),
            dateLabel.heightAnchor.constraint(equalToConstant: 18),
            
        ])
        
    }
    
  
    
    
    func add(childVC: UIViewController,to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds //tells the child to fill up the container view
        didMove(toParent: self)
    }
    
    @objc func dismissVC() {
        dismiss(animated: true)
    }
}


extension UserInfoVC: UserInfoVCDelegate {
    func didTapGitHubProfile(for user : User) {
        // Show safari view controller
        print("profile")
        guard let url = URL(string: user.htmlUrl) else {
            presentGFAlertOnMainThread(alertTitle: "Invalid URL", message: "The url attached to this user is invalid", buttonTitle: "Ok")
            return
        }
    
        presentSafariVC(with: url)
    }
    
    func didTapGetFollowers(for user : User) {
      
        
        guard user.followers != 0 else {
            presentGFAlertOnMainThread(alertTitle: "No followers", message: "This user has no followers. What a shame 😞", buttonTitle: "So sad")
            return
        }
        
        delegate.didRequestFollowers(for: user.login)
        dismissVC()
        print("followers")
    }
    
    
}
