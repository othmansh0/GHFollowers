//
//  GFRepoItemVC.swift
//  GHFollowers
//
//  Created by Othman Shahrouri on 03/12/2023.
//

import UIKit

class GFRepoItemVC: GFItemInfoVC {

//    var user: User!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()
    }

    private func configureItems() {
        itemInfoViewOne.set(itemInfoType: .repos, withCount: user.publicRepos)
        itemInfoViewTwo.set(itemInfoType: .gists, withCount: user.publicGists ?? 0)
        actionButton.set(backgroundColor: .systemPurple, title: "GitHub Profile")
    }
    
    
    override func actionButtonTapped() {
        delegate.didTapGitHubProfile(for: user)
    }
}
