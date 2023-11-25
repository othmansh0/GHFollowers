//
//  UIHelpers.swift
//  GHFollowers
//
//  Created by Othman Shahrouri on 24/11/2023.
//

import UIKit



struct UIHelpers {
    static func createThreeColumnsFlowLayout(in view: UIView) -> UICollectionViewFlowLayout {
        let width = view.bounds.width
        let padding: CGFloat = 12
        let minimumSpacing: CGFloat = 10
        let availableWidth = width - (padding * 2) - (minimumSpacing * 2)
        let itemWidth = availableWidth / 3
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth + 40) //the cell is squared so same as width but + 40 for cell text and some padding
        return flowLayout
    }
}
