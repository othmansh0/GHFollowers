//
//  User.swift
//  GHFollowers
//
//  Created by Othman Shahrouri on 18/11/2023.
//

import Foundation
struct User: Codable {
    let login: String
    let avatarUrl: String
    var name: String?
    var location: String?
    var bio: String?
    let publicRepos: Int
    var publicGists: Int?
    let htmlUrl: String
    let following: Int
    let followers: Int
    let createdAt: String
}
