//
//  LiturgyDetailViewController.swift
//  NacdFeatured
//
//  Created by Greg Wise on 11/9/16.
//  Copyright © 2016 NorthlandChurch. All rights reserved.
//

import UIKit
import RealmSwift

class LiturgyDetailViewController: UIViewController
{

    @IBOutlet weak var liturgyScrollView: UIScrollView!
    
    @IBOutlet weak var liturgyContentView: UIView!
    
    var aLitItem: LiturgyRlm!
    var myFormatter = NSDateFormatter()
    var shareBody = String()
    
    
    
    @IBOutlet weak var titleLabel1: UILabel!
    
    @IBOutlet weak var titleLabel2: UILabel!
    
    @IBOutlet weak var dateLabel1: UILabel!
    
    @IBOutlet weak var dateLabel2: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var mainBodyLabel: UILabel!
    @IBOutlet weak var readButton: UIButton!
    
    let liturgyRealm = Realm.sharedInstance
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        myFormatter.dateFormat = "MMMM d"
        configureView()
        shareBody = aLitItem.tranlation! + "\n" + aLitItem.scripture!

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func markAsReadTapped(sender: UIButton)
    {
        if aLitItem.hasBeenRead != true
        {
        sender.setTitle("I'VE READ THIS.", forState: .Normal)
        sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        sender.backgroundColor = UIColor(red: 121/255.0, green: 198/255.0, blue: 113/255.0, alpha: 1.0)
        
        try! liturgyRealm.write({
            aLitItem.hasBeenRead = true
            liturgyRealm.add(aLitItem, update: true)
        })
        }

        
    }
    
    
    @IBAction func sharingTapped(sender: UIButton)
    {
        let vc = UIActivityViewController(activityItems: [shareBody], applicationActivities: nil)
        self.presentViewController(vc, animated: true, completion: nil)
        
        
    }

    
    func configureView()
    {
        let fullTitle = aLitItem.title!.componentsSeparatedByString(" ")
        titleLabel1.text = fullTitle[0].uppercaseString
        titleLabel2.text = fullTitle[1].uppercaseString
        
        let today = NSDate()
        let stringForToday = myFormatter.stringFromDate(today)
        let dateArray = stringForToday.componentsSeparatedByString(" ")
        dateLabel1.text = dateArray[0].uppercaseString
        dateLabel2.text = dateArray[1].uppercaseString
        
        authorLabel.text = aLitItem.tranlation!.uppercaseString
        
        // let fullText = aLit.scripture
        let fullText = aLitItem.scripture
        
        //let attributedBody  = NSMutableAttributedString(string: aLit.scripture)
        let attributedBody  = NSMutableAttributedString(string: fullText!)
        
        
        
        
        
        //let attributedBody  = NSMutableAttributedString(string: aLitItem.scripture)
        
       // let attributedString = NSMutableAttributedString(string: "Your text")
        
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = 12 // Whatever line spacing you want in points
        
        // *** Apply attribute to string ***
        attributedBody.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedBody.length))
        
        // *** Set Attributed String to your label ***
       // label.attributedText = attributedString;
        
        
        mainBodyLabel.attributedText = attributedBody
        
        if aLitItem.hasBeenRead == true
        {
            readButton.setTitle("I'VE READ THIS.", forState: .Normal)
            readButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            readButton.backgroundColor = UIColor(red: 121/255.0, green: 198/255.0, blue: 113/255.0, alpha: 1.0)
           // aLitItem.hasBeenRead = true
        }

        
    }
    
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
