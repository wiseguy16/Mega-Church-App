//
//  WebViewController.swift
//  Northland News
//
//  Created by Greg Wise on 10/17/16.
//  Copyright © 2016 Northland Church. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController
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
        
        if let nacdURL = aFeaturedItem?.webURL
        {
            webViewURL = NSURL(string: nacdURL)!
            //let  = NSURL(string: aFeaturedItem.webURL!)
        }
        else if let nacdURL = passThruWebString
        {
           webViewURL = NSURL(string: nacdURL)!
        }
        else
        {
            webViewURL = NSURL(string: "http://www.northlandchurch.net")!
        }
        
        // let nacdURL = NSURL(string: aFeaturedItem.webURL!)
        let request = NSURLRequest(URL: webViewURL)
        nacdWebView.loadRequest(request)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
