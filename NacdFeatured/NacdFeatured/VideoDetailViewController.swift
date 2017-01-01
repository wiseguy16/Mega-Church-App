//
//  VideoDetailViewController.swift
//  NacdNews
//
//  Created by Gregory Weiss on 9/10/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import UIKit
import CoreMedia
import Foundation
import AVKit
import AVFoundation
import SDWebImage

class VideoDetailViewController: UIViewController, UITextViewDelegate
{
    //var aVideo: MediaItem!
    var aVideo: Video!
   // var aVideo: VideoServiceRlm!
    var myFormatter = NSDateFormatter()
    
    
    @IBOutlet weak var videoDetailImageView: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var videoDescriptionLabel: UILabel!
    @IBOutlet weak var videoMiscLabel: UILabel!
    
    @IBOutlet weak var fullDescriptionLabel: UILabel!
    
    var categoryString = ""
    
    

 //   @IBOutlet weak var longerDescriptionTextField: UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        myFormatter.dateStyle = .ShortStyle
        myFormatter.timeStyle = .NoStyle
        configureView()

        // Do any additional setup after loading the view.
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //longerDescriptionTextField.setContentOffset(CGPointZero, animated: false)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func playVideoTapped(sender: UIButton)
    {
        
        let videoURL = NSURL(string: aVideo.m3u8file!)
        let player = AVPlayer(URL: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.presentViewController(playerViewController, animated: true) {
            
            playerViewController.player?.play()
            
        }
        
    }

    
    func configureView()
    {
       
        videoTitleLabel.text = aVideo.name?.uppercaseString
        
        let attributedBody  = NSMutableAttributedString(string: aVideo.descript!)
        
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = 4 // Whatever line spacing you want in points
        
        // *** Apply attribute to string ***
        attributedBody.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedBody.length))
        
        // *** Set Attributed String to your label ***
        
        
        fullDescriptionLabel.attributedText = attributedBody
        
        
        let myURL = aVideo.imageURLString!
        
        let placeHolder = UIImage(named: "WhiteBack.png")
        
      
        
        let realURL = NSURL(string: myURL)
        
        videoDetailImageView.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: .ProgressiveDownload)
        
        
        /*
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: myURL)!, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error)
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let image = UIImage(data: data!)
                self.videoDetailImageView.image = image
                
            })
            
        }).resume()
        
        */

       
        /*
        let dateToShow = aVideo.entry_date
        let formattedDateArray = dateToShow.componentsSeparatedByString("-")     //.components(separatedBy: "-")
        let formattedDateArray2 = formattedDateArray[2].componentsSeparatedByString("T")            //components(separatedBy: "T")
        let formattedDate = "\(formattedDateArray[1])/\(formattedDateArray2[0])/\(formattedDateArray[0])"
        videoMiscLabel.text = formattedDate
        */
        
        let strippedCategory = categoryString.stringByReplacingOccurrencesOfString("▼", withString: "")
        videoMiscLabel.text = strippedCategory.uppercaseString
        
        
        
    }

 
}
