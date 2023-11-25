//
//  Model.swift
//  GHFollowers
//
//  Created by Othman Shahrouri on 18/11/2023.
//

import Foundation
struct Follower: Codable, Hashable {
    var login: String
    var avatarUrl: String
}
