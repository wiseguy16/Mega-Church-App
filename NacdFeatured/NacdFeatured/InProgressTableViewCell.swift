//
//  InProgressTableViewCell.swift
//  NacdFeatured
//
//  Created by Gregory Weiss on 12/28/16.
//  Copyright © 2016 NorthlandChurch. All rights reserved.
//

import UIKit
import SDWebImage
import RealmSwift

class InProgressTableViewCell: UITableViewCell
{
    
    @IBOutlet weak var inProgressTitle: UILabel!
    @IBOutlet weak var inProgressImage: UIImageView!
    @IBOutlet weak var inProgressDetailLabel: UILabel!
    @IBOutlet weak var inProgressView: UIProgressView!
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
