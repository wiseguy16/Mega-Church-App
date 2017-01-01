//
//  WebViewController.swift
//  Northland News
//
//  Created by Greg Wise on 10/17/16.
//  Copyright © 2016 Northland Church. All rights reserved.
//

import UIKit
import WebKit

class Web2ViewController: UIViewController
{
    var aFeaturedItem: Featured?
    var passThruWebString: String?
    
    @IBOutlet weak var nacdWebView: UIWebView!
    var webViewURL = NSURL()
    
    //let nacdURL = NSURL(string: "https://youtu.be/vz7Hv4RAgk8") //  https://youtu.be/vz7Hv4RAgk8
    //let nacdURL = NSURL(string: "http://preview.northlandchurch.net/pray/")
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        loadWebPage()

    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        loadWebPage()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadWebPage()
    {
        webViewURL = NSURL(string: "http://northlandchurch.net/articles/mvb/")!
        //webViewURL = NSURL(string: "https://s3.amazonaws.com/nacdvideo/2015/newspaper2015wk50.pdf")!

        let request = NSURLRequest(URL: webViewURL)
        nacdWebView.loadRequest(request)
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
