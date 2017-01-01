//
//  ThirdCollectionViewCell.swift
//  NacdNews
//
//  Created by Gregory Weiss on 9/9/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import UIKit

class ThirdCollectionViewCell: UICollectionViewCell
{
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var podcastImageView: UIImageView!
    
    @IBOutlet weak var speakerLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var loadingView: UIView!
    
    @IBOutlet weak var downloadButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var playBarView: UIView!
    
//    var setURLString = ""
    
    
  
    override func awakeFromNib()
    {
        
        super.awakeFromNib()
        // Initialization code
        
        self.loadingView.alpha = 0
    
        let activityIndicator : CustomActivityIndicatorView = {
            let image: UIImage = UIImage(named: "loading")!
            return CustomActivityIndicatorView(image: image)
        }()
        
        self.loadingView.addSubview(activityIndicator)
        activityIndicator.alpha = 1.0
        activityIndicator.startAnimating()
        
      //  initComponent(setURLString)
    
        
    }
    
    func initComponent(passedURL: String)
    {
        // let url3 = "http://s3.amazonaws.com/nacdvideo/2016/HoldUsTogether.mp3"
        
        // let audioPlayer = XQAudioPlayer.init(frame: CGRect(x: 0, y: 70, width: SCREEN_WIDTH, height: SCREEN_WIDTH * 0.12), urlString: url)
        
        
        let audioPlayer = XQAudioPlayer(frame: CGRect(x: 0, y: 0, width: 280, height: 40 ), urlString: passedURL)
        playBarView.addSubview(audioPlayer)
        
        // Change progress color
        audioPlayer.progressColor = UIColor.redColor()
        
        // Change background color
        // audioPlayer.backgroundColor = UIColor.groupTableViewBackgroundColor()
        audioPlayer.backgroundColor = UIColor.clearColor()
        
        // Change background progress color
        audioPlayer.progressBackgroundColor = UIColor.lightGrayColor()
        
        // Change title time label color
        audioPlayer.timeLabelColor = UIColor.blackColor()
        
        // Change height of progress
        audioPlayer.progressHeight = 6
        
        // Change button play image
        audioPlayer.playingImage = UIImage(named:"icon_playing")
        audioPlayer.pauseImage = UIImage(named:"icon_pause")
        
        // Setting delegate
        // audioPlayer.delegate = self
        
    }

    
}
