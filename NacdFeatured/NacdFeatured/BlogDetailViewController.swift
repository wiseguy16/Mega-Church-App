//
//  BlogDetailViewController.swift
//  NacdNews
//
//  Created by Gregory Weiss on 8/31/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import UIKit
import WebKit
import SDWebImage

class BlogDetailViewController: UIViewController
{
    
    @IBOutlet weak var blogScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var aBlogItem: Featured!
    var shareBody: String?
    var myFormatter = NSDateFormatter()
    
    @IBOutlet weak var blogImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subTextLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    var hardCodeText = "Throughout my college career, I had the opportunity to complete several internships in many places around the United States. I spent time in the Cascade my future after Florida, I decided to find a church; I decided to allow myself to become a little more attached to Florida. This led me to Northland, and I guess I got a lot more attached than I intended. \n Here I am; it’s been over a year since I moved here, and my life looks wildly different from what I expected. I am working a full-time job, and in my spare time, I am involved both inside and , He is teaching me how to be the church in someone’s living room, and He is teaching me what it looks like to live life with other people, in community. \n Moving to a new city that I know nothing about has definitely been tough. However, I have been so fortunate to be surrounded by people who care about me and consider me a valuable part of their community. When I started coming to Northland, I pretty quickly got connected with a group of peers looking to find "
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        myFormatter.dateFormat = "yyyy-MM-dd"
       // myFormatter.timeStyle = .NoStyle
        
        configureView()
        
        //shareBody = aBlogItem.channel
        //contentView.layer.borderWidth = 1
        //contentView.layer.borderColor = UIColor.magentaColor().CGColor
        
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
      //  self.blogScrollView.frame = self.view.bounds // Instead of using auto layout
       // self.blogScrollView.contentSize.height = 2346
        
        
        //let sizeEstimator = CGFloat(aBlogItem.body.characters.count)
        // print("This blog has this many chars: \(sizeEstimator)")
//        let wordArray1 = aBlogItem.body.componentsSeparatedByString(" ")
//        print(wordArray1.count)
//        let wordArray2 = aBlogItem.subText.componentsSeparatedByString(" ")
//        let newEstimate = CGFloat((wordArray1.count + wordArray2.count) * 6)
       
        
       // self.blogScrollView.frame = self.view.bounds // Instead of using auto layout
       // self.blogScrollView.contentSize.height = newEstimate * 0.7 // Or whatever you want it to be.
 
        
//        var contentRect: CGRect = CGRectZero
//        for view in blogScrollView.subviews
//        {
//            contentRect = CGRectUnion(contentRect, view.frame)
//            print(contentRect)
//        }
//        self.blogScrollView.contentSize = contentRect.size
    }
    
    
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(true)
//        var contentRect: CGRect = CGRectZero
//        for view in blogScrollView.subviews
//        {
//            contentRect = CGRectUnion(contentRect, view.frame)
//            print(contentRect)
//        }
//        self.blogScrollView.contentSize = contentRect.size
//    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func sharingTapped(sender: UIButton)
    {
        let vc = UIActivityViewController(activityItems: [shareBody!], applicationActivities: nil)
        self.presentViewController(vc, animated: true, completion: nil)
        
        
    }
    
    func configureView()
    {
        titleLabel.text = aBlogItem.title?.stringByDecodingXMLEntities()
        authorLabel.text = aBlogItem.channel!.uppercaseString
        
        let arrayFromDate = aBlogItem.entry_date?.componentsSeparatedByString("T")
        let tempDate = arrayFromDate![0]
        
        let newDate = myFormatter.dateFromString(tempDate)
        myFormatter.dateFormat = "MMM d, y"
        let showDate = myFormatter.stringFromDate(newDate!)
        dateLabel.text = showDate

        //subTextLabel.text = aBlogItem.subText
       // print(aBlogItem.body)
        
        /*
         self.featureImageView.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: [])
         
         if let decodedString = aFeaturedItem.body?.stringByDecodingXMLEntities()
         {
         
         // let attributedBody  = NSMutableAttributedString(string: aFeaturedItem.body!)
         attributedBody  = NSMutableAttributedString(string: decodedString)
         }
         
         // let attributedString = NSMutableAttributedString(string: "Your text")
         
         // *** Create instance of `NSMutableParagraphStyle`
         let paragraphStyle = NSMutableParagraphStyle()

         */
        
        //var convertedBody = aBlogItem.replaceBreakWithReturn(aBlogItem.body!)
        var convertedBody = aBlogItem.body!.stringByDecodingXMLEntities()
        convertedBody = aBlogItem.replaceBreakWithReturn(convertedBody)
        let attributedBody  = NSMutableAttributedString(string: convertedBody)
        // let attributedString = NSMutableAttributedString(string: "Your text")
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = 12 // Whatever line spacing you want in points
        // *** Apply attribute to string ***
        attributedBody.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedBody.length))
        // *** Set Attributed String to your label ***
        // label.attributedText = attributedString;
        
        bodyLabel.attributedText = attributedBody

        subTextLabel.text = aBlogItem.title?.stringByDecodingXMLEntities()
        
       // bioLabel.text = aBlogItem.bioDisclaimer
     //   blogImage.image = UIImage(named: aBlogItem.blog_primary)
        
        let myURL = aBlogItem.image!
        
        let placeHolder = UIImage(named: "WhiteBack.png")
        // cell.featuredButton.setTitle(aFeaturedThing.webURL, forState: .Normal)
        
        // let myURL = featuredItems[indexPath.row].image!
        let realURL = NSURL(string: myURL)
        
        self.blogImage.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: [])
        
        let baseURL = "http://www.northlandchurch.net/"
        let urlPart2 = self.aBlogItem.channel!.lowercaseString
        let urlPart3 = self.aBlogItem.urltitle!
        self.shareBody = baseURL + urlPart2 + "/" + urlPart3
        
    }
    
    /*
     self.channel = myDictionary["channel"] as? String
     self.title = myDictionary["title"] as? String
     self.urltitle = myDictionary["urltitle"] as? String
     self.entry_date = myDictionary["entry_date"] as? String
     // self.speaker = myDictionary["media-speaker"] as? String
     // self.mediaFile = myDictionary["media-file"] as? String
     
     if (myDictionary["media-primary"] as? String) != nil
     {
     self.image = myDictionary["media-primary"] as? String
     }
     else if (myDictionary["blog-primary"] as? String) != nil
     {
     self.image = myDictionary["blog-primary"] as? String
     }
     else
     {
     self.image = "Logo2.png"
     }
     // self.podcastImage = myDictionary["media-primary"] as? String
     let baseURL = "http://www.northlandchurch.net/"
     let urlPart2 = self.channel?.lowercaseString
     let urlPart3 = self.urltitle
     self.webURL = baseURL + urlPart2! + "/" + urlPart3!

     
     */


}
