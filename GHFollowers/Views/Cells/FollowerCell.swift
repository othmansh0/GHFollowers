//
//  FollowerCell.swift
//  GHFollowers
//
//  Created by Othman Shahrouri on 19/11/2023.
//

import UIKit

class FollowerCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func configure() {
        layer.cornerRadius = 10
        clipsToBounds = true
    }
    
}
