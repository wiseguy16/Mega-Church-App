//
//  NewspaperViewController.swift
//  NacdFeatured
//
//  Created by Gregory Weiss on 12/21/16.
//  Copyright © 2016 NorthlandChurch. All rights reserved.
//

import UIKit
import WebKit


class NewspaperViewController: UIViewController
{
    
    var webViewURL = NSURL()
    
    var topBarBoundsY:CGFloat?

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       // self.topBarBoundsY = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height

        loadWebPage()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        //loadWebPage()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadWebPage()
    {
        
        
        webViewURL = NSURL(string: "https://s3.amazonaws.com/nacdvideo/misc/current_newspaper.pdf")!
        let request = NSURLRequest(URL: webViewURL)

        let newspaperView: WKWebView = WKWebView(frame: UIScreen.mainScreen().bounds)
        // WKWebView(frame: CGRectMake(0, self.topBarBoundsY!, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - (self.topBarBoundsY! * 1.5)))
        // WKWebView(frame: UIScreen.mainScreen().bounds)
        newspaperView.loadRequest(request)
        self.view.addSubview(newspaperView)
       // newspaperWebView.loadRequest(request)
        
        // newspaperView.UIDelegate = self

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
