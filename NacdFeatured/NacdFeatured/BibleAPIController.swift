//
//  BibleAPIController.swift
//  NacdFeatured
//
//  Created by Greg Wise on 11/23/16.
//  Copyright © 2016 NorthlandChurch. All rights reserved.
//

import Foundation
import UIKit

class BibleAPIController
{
    
    
    init(delegate: BibleAPIControllerProtocol)
    {
        self.delegate = delegate
    }
    
    
    //var arrayOfFeatured = [Featured]()
    // var arrayOfBlogs = [Featured]()
    var arrayOfLiturgy = [Liturgy]()
    
    var delegate: BibleAPIControllerProtocol!
    
    
    func removeSpecialCharsFromString(str: String) -> String {
        let chars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),.:!_/@[]{}".characters)
        return String(str.characters.filter { chars.contains($0) })
    }
    
    func removeBackslashes(str: String) -> String
    {
        var newStr = str
        newStr = newStr.stringByReplacingOccurrencesOfString("\t", withString: "")
        newStr = newStr.stringByReplacingOccurrencesOfString("\n", withString: "")
        newStr = newStr.stringByReplacingOccurrencesOfString("\\", withString: "")
        
        return newStr
    }
    
    
    func getLiturgyDataFromNACD()
    {
        
        let URLString = "http://www.northlandchurch.net/index.php/resources/iphone-app-getliturgy"
        let myURL = NSURL(string: URLString)
        let request = NSMutableURLRequest(URL: myURL!)
        
        request.HTTPMethod = "GET"  // Compose a query string
        //request.addValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if let httpResponse = response as? NSHTTPURLResponse
                {   print(httpResponse)
                    if httpResponse.statusCode != 200
                    {
                        print("You got 404!!!???")
                        self.networkAlert()
                        return
                    }
                }
                
                if let apiData = data
                {   print(apiData)
                    if let datastring = String(data: apiData, encoding: NSUTF8StringEncoding)
                    {
                        
                    print(datastring)
                        let data2 = self.removeBackslashes(datastring)
                    print(data2)
                        let data1 = data2.dataUsingEncoding(NSUTF8StringEncoding)
                    print(data1!)
                        
                        if let apiData = data1, let jsonOutput = try? NSJSONSerialization.JSONObjectWithData(apiData, options: []) as? [String: AnyObject], let myJSON = jsonOutput
                        {
                            let dataArray = myJSON["items"] as? [[String: AnyObject]]
                            
                            if let constArray = dataArray
                            {
                                for value in constArray
                                {
                                    let aLit = Liturgy(myDictionary: value)
                                    self.arrayOfLiturgy.append(aLit)
                                }
                                self.delegate.gotTheBible(self.arrayOfLiturgy)
                            }
                        }
                    }
                }
                else
                {
                    self.networkAlert()
                  //  self.delegate.gotTheBible(self.arrayOfLiturgy)
                }
                
            })
        })
        
        
        task.resume()
        
        return
    }
    

    
    func purgeLiturgy()
    {
        arrayOfLiturgy.removeAll()
    }
    
    func networkAlert()
    {
        // Create the alert controller
        let alertController1 = UIAlertController(title: "Sorry, having trouble connecting to the network. Please try again later.", message: "Network Unavailable", preferredStyle: .Alert)
        // Add the actions
        alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController1.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        // Present the controller
        alertController1.show()
    }

    
    
    
}