//
//  DownloadsTableViewCell.swift
//  NacdFeatured
//
//  Created by Gregory Weiss on 12/26/16.
//  Copyright © 2016 NorthlandChurch. All rights reserved.
//

import UIKit
import SDWebImage
import RealmSwift

class DownloadsTableViewCell: UITableViewCell
{

    @IBOutlet weak var downloadImageView: UIImageView!
    @IBOutlet weak var downloadTitleLabel: UILabel!
    @IBOutlet weak var downloadSeriesLabel: UILabel!
    
    
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
