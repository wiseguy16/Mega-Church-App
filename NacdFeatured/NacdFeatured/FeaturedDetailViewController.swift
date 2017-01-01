//
//  FeaturedDetailViewController.swift
//  Northland News
//
//  Created by Greg Wise on 10/17/16.
//  Copyright © 2016 Northland Church. All rights reserved.
//

import UIKit
import CoreMedia
import Foundation
import AVKit
import AVFoundation
import SDWebImage


class FeaturedDetailViewController: UIViewController
{

    @IBOutlet weak var featureImageView: UIImageView!
    
    
    @IBOutlet weak var newFeatureTitleLabel: UILabel!
    
    @IBOutlet weak var featuredTextView: UITextView!
    
    @IBOutlet weak var fullBodyLabel: UILabel!
    
    @IBOutlet weak var featureClosingLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var videoPlayButton: UIButton!
    
    
    @IBOutlet weak var dateLabel: UILabel!
    
    var shareBody: String?
    
    var myFormatter = NSDateFormatter()
    
    
    var tempText = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempo    r incididunt ut labore et dolore mag na aliqua. Ut enim ad minim \n veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo    Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod t empor incididunt ut labore et dolore magna aliqua.  Ut enim ad minim veniam, quis nostrud exercitation ullamco  consequat. D    repr\n ehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui \n officia deser     unt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiud  a.  "
    
    
    var aFeaturedItem: FeaturedRlm!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        myFormatter.dateFormat = "yyyy-MM-dd"
        
        videoPlayButton.alpha = 0
        videoPlayButton.enabled = false
        
        
        configureView()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       // featuredTextView.setContentOffset(CGPointZero, animated: false)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func videoPlayTapped(sender: UIButton)
    {
        let videoURL = NSURL(string: aFeaturedItem.mediaFileM3U8!)
        let player = AVPlayer(URL: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.presentViewController(playerViewController, animated: true) {
            
            playerViewController.player?.play()
            
        }

        
    }
    
    
    @IBAction func sharingTapped(sender: UIButton)
    {
        let vc = UIActivityViewController(activityItems: [shareBody!], applicationActivities: nil)
        self.presentViewController(vc, animated: true, completion: nil)
        
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func configureView()
    {
        newFeatureTitleLabel.text = aFeaturedItem.title
        //print(aFeaturedItem.webURL)
        
        categoryLabel.text = aFeaturedItem.channel?.uppercaseString
        
        //authorLabel.text = aBlogItem.author.uppercaseString
       // dateLabel.text = aBlogItem.entry_date
       // subTextLabel.text = aBlogItem.subText
        //featureMessageLabel.text = aFeaturedItem.urltitle
        //featureClosingLabel.text = aFeaturedItem.channel
        
        if aFeaturedItem.channel == "Media"
        {
            videoPlayButton.alpha = 1
            videoPlayButton.enabled = true
        }
        

        
        
        
         let myURL = aFeaturedItem.image!
        
        var attributedBody  = NSMutableAttributedString(string: "")
        
        let placeHolder = UIImage(named: "WhiteBack.png")
        // cell.featuredButton.setTitle(aFeaturedThing.webURL, forState: .Normal)
        
       // let myURL = featuredItems[indexPath.row].image!
        let realURL = NSURL(string: myURL)
        
        self.featureImageView.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: [])
        
        if let decodedString = aFeaturedItem.body?.stringByDecodingXMLEntities()
        {
        
       // let attributedBody  = NSMutableAttributedString(string: aFeaturedItem.body!)
         attributedBody  = NSMutableAttributedString(string: decodedString)
        }

        // let attributedString = NSMutableAttributedString(string: "Your text")
        
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = 2 // Whatever line spacing you want in points
        
        // *** Apply attribute to string ***
        attributedBody.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedBody.length))
        attributedBody.addAttribute(NSKernAttributeName, value:   CGFloat(0.05), range: NSRange(location: 0, length: attributedBody.length))
        
        // *** Set Attributed String to your label ***
        // label.attributedText = attributedString;
        
        
        fullBodyLabel.attributedText = attributedBody
        
        let arrayFromDate = aFeaturedItem.entry_date?.componentsSeparatedByString("T")
        let tempDate = arrayFromDate![0]
        
        
        let newDate = myFormatter.dateFromString(tempDate)
        myFormatter.dateFormat = "MMM d, y"
        let showDate = myFormatter.stringFromDate(newDate!)
        dateLabel.text = showDate
        
       // let newDate = tempDate.
        
        var attributedAuthor  = NSMutableAttributedString(string: "")
        attributedAuthor = NSMutableAttributedString(string: aFeaturedItem.closingText!.uppercaseString)
        attributedAuthor.addAttribute(NSKernAttributeName, value: CGFloat(0.001), range: NSRange(location: 0, length: attributedAuthor.length))
        
        featureClosingLabel.attributedText = attributedAuthor
        
        
        let baseURL = "http://www.northlandchurch.net/"
        let urlPart2 = self.aFeaturedItem.channel!.lowercaseString
        let urlPart3 = self.aFeaturedItem.urltitle!
        self.shareBody = baseURL + urlPart2 + "/" + urlPart3

        
    }


}

