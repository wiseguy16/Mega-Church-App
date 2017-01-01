//
//  FeaturedCollectionViewCell.swift
//  NacdNews
//
//  Created by Gregory Weiss on 10/11/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import UIKit

class FeaturedCollectionViewCell: UICollectionViewCell
{
    
    @IBOutlet weak var featuredImageView: UIImageView!
    
    @IBOutlet weak var featuredTitleLabel: UILabel!
    
    @IBOutlet weak var featuredDetailsLabel: UILabel!
    
    @IBOutlet weak var featuredButton: UIButton!
    
    @IBOutlet weak var backingBlurImage: UIImageView!
    
    @IBOutlet weak var featuredPlayButton: UIButton!
    
    @IBOutlet weak var tabBarButton: UIButton!
    
    
//    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes! {
//        let toReturn = super.preferredLayoutAttributesFittingAttributes(layoutAttributes)
//        return toReturn
//    }
    
//    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        return super.preferredLayoutAttributesFittingAttributes(layoutAttributes)
//    }
    
}
