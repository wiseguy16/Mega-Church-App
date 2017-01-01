//
//  APIController.swift
//  WordSearchAPI
//
//  Created by Gregory Weiss on 8/30/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class APIController
{
    
    init(delegate: APIControllerProtocol)
    {
        self.delegate = delegate
    }
    
    var videoArrayOfServices = [Video]()
    var videoArrayOfSermons = [Video]()
    var videoArrayOfSearches = [Video]()
    var arrayOfFeatured = [Featured]()
    
     var checkArrayAudioRlm = [String]()
    
    var delegate: APIControllerProtocol!
    
    var names = [String]()
    
    let errorDomain = "VimeoClientErrorDomain"
    let baseURLString = "https://api.vimeo.com"
    // static let staffPicksPath = "/channels/staffpicks/videos"
    // let staffPicksPath = "/users/northlandchurch/albums/3730564/videos?per_page=15"
    let authToken = "37046b6bbce2064018367eaf61b60080"
    
    
    
    
    
    
    
    func getVideoFullServicesDataFromVimeo(theseVideos: String)
    {
        
        let URLString = baseURLString + theseVideos
        let myURL = NSURL(string: URLString)
        let request = NSMutableURLRequest(URL: myURL!)
        
        request.HTTPMethod = "GET"  // Compose a query string
        request.addValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("Made a call to Vimeo API for \(theseVideos) ")

                if let httpResponse = response as? NSHTTPURLResponse
                {
                    if httpResponse.statusCode != 200
                    {
                        print("You got 404!!!???")
                        self.networkAlert()
                        return
                    }
                }
                            
                if let vimeoData = data, let jsonResponse = try? NSJSONSerialization.JSONObjectWithData(vimeoData, options: []) as? [String: AnyObject], let myJSON = jsonResponse
                {
                    
                    // here "vimeoData" is the dictionary encoded in JSON data
                    
                    let dataArray = myJSON["data"] as? [[String: AnyObject]]
                    
                    if let constArray = dataArray
                    {
                        for value in constArray
                        {
                            let video = Video(dictionary: value)
                            self.videoArrayOfServices.append(video)
                        }
                        self.delegate.gotTheVideos(self.videoArrayOfServices)
                    }
                }
                else
                {
                    self.networkAlert()
                
                   // self.delegate.gotTheVideos(self.videoArrayOfServices)
                }
            })
        })
        
        
        task.resume()
        
        return
        
    }
    
    func getVideoSermonsDataFromVimeo(theseVideos: String)
    {
        
        let URLString = baseURLString + theseVideos
        let myURL = NSURL(string: URLString)
        let request = NSMutableURLRequest(URL: myURL!)
        
        request.HTTPMethod = "GET"  // Compose a query string
        request.addValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            print("Made a call to Vimeo API for \(theseVideos) ")

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("Vimeo error: \(error)")
                if let httpResponse = response as? NSHTTPURLResponse
                {
                    //print(httpResponse)
                    if httpResponse.statusCode != 200
                    {
                        print("You got 404!!!???")
                        self.networkAlert()
                        return
                    }
                }
                
                if let vimeoData = data, let jsonResponse = try? NSJSONSerialization.JSONObjectWithData(vimeoData, options: []) as? [String: AnyObject], let myJSON = jsonResponse
                {
                    // here "vimeoData" is the dictionary encoded in JSON data
                    
                    let dataArray = myJSON["data"] as? [[String: AnyObject]]
                    
                    if let constArray = dataArray
                    {
                        for value in constArray
                        {
                            let video = Video(dictionary: value)
                            self.videoArrayOfSermons.append(video)
//                            if !self.checkArrayAudioRlm.contains(video.uri!)
//                            {
//                              self.videoArrayOfSermons.append(video)
//                                print("appended item: \(video.uri)")
//                            }
                            
                        }
                        self.delegate.gotTheVideos(self.videoArrayOfSermons)
                        print("passing items: \(self.videoArrayOfSermons.count)")
                    }
                }
                else
                {
                    self.networkAlert()
                    //self.delegate.gotTheVideos(self.videoArrayOfSermons)
                }
            })
        })
        
        
        task.resume()
        
        return
    }
    
    
    func getVideoSearchesDataFromVimeo(theseVideos: String)
    {
        print(theseVideos)
        let URLString = baseURLString + theseVideos
        let myURL = NSURL(string: URLString)
        let request = NSMutableURLRequest(URL: myURL!)
        
        request.HTTPMethod = "GET"  // Compose a query string
        request.addValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            print("Made a call to Vimeo API for \(theseVideos) ")

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("Vimeo error: \(error)")
                if let httpResponse = response as? NSHTTPURLResponse
                {
                    if httpResponse.statusCode != 200
                    {
                        print("You got 404!!!???")
                        self.networkAlert()
                        return
                    }
                }

                
                if let vimeoData = data, let jsonResponse = try? NSJSONSerialization.JSONObjectWithData(vimeoData, options: []) as? [String: AnyObject], let myJSON = jsonResponse
                {
                    // here "vimeoData" is the dictionary encoded in JSON data
                      let totalRslts = myJSON["total"] as? Int
                        if totalRslts == 0
                     {
                        self.searchAlert(theseVideos)
                        print("no results")
                     }
                    
                    
                    let dataArray = myJSON["data"] as? [[String: AnyObject]]
                    
                    if let constArray = dataArray
                    {
                        for value in constArray
                        {
                            let video = Video(dictionary: value)
                            self.videoArrayOfSearches.append(video)
                        }
                        self.delegate.gotTheVideos(self.videoArrayOfSearches)
                    }
                }
                else
                {
                    self.networkAlert()
                    //self.delegate.gotTheVideos(self.videoArrayOfSearches)
                }
            })
        })
        
        
        task.resume()
        
        return
    }
    
    func syncTheVideos(videosOnDisk: [Video])
    {
       videoArrayOfServices = videosOnDisk
        
    }
    
    func syncTheSermons(audiosOnDisk: [Video])
    {
        videoArrayOfSermons = audiosOnDisk
        for xyz in videoArrayOfSermons
        {
            if !checkArrayAudioRlm.contains(xyz.uri!)
            {
                checkArrayAudioRlm.append(xyz.uri!)
            }
        }
    }
    
    
    
    func purgeVideosFromArray()
    {
        videoArrayOfServices.removeAll()
    }
    
    func purgeSermons()
    {
       // print("not removing anything from Sermon Audio")
        print("removing ALL from Sermon Audio")
        videoArrayOfSermons.removeAll()
    }
    
    func purgeSearches()
    {
        videoArrayOfSearches.removeAll()
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
    
    func searchAlert(searchTerm: String)
    {
        let tempSearchArray = searchTerm.componentsSeparatedByString("=")
        let tempWord = tempSearchArray[1]
        let realTerm = tempWord.stringByRemovingPercentEncoding
        // Create the alert controller
        let alertController1 = UIAlertController(title: "Sorry, no results found for \(realTerm!).", message: "Try another search.", preferredStyle: .Alert)
        // Add the actions
        alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController1.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        // Present the controller
        alertController1.show()

        
    }


    
    
    
}

extension UIAlertController {
    
    func show() {
        present(true, completion: nil)
    }
    
    func present(animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController {
            presentFromController(rootVC, animated: animated, completion: completion)
        }
    }
    
    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
            presentFromController(visibleVC, animated: animated, completion: completion)
        } else
            if let tabVC = controller as? UITabBarController,
                let selectedVC = tabVC.selectedViewController {
                presentFromController(selectedVC, animated: animated, completion: completion)
            } else {
                controller.presentViewController(self, animated: animated, completion: completion);
        }
    }
    
    }


