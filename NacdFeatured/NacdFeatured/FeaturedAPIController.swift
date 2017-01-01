//
//  FeaturedAPIController.swift
//  Northland News
//
//  Created by Greg Wise on 10/27/16.
//  Copyright © 2016 Northland Church. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

extension Realm {
    static let sharedInstance: Realm = {
        
        try! Realm()
    }()
}

class FeaturedAPIController
{
    
    
    init(delegate: FeaturedAPIControllerProtocol)
    {
        self.delegate = delegate
    }
    

    var arrayOfFeatured = [Featured]()
   // var backupFeatured: [Featured] = [Featured]
    var arrayOfBlogs = [Featured]()
    //var featuredRlmItems: Results<FeaturedRlm>!
   
    
    var delegate: FeaturedAPIControllerProtocol!
    
    
    
    let errorDomain = "VimeoClientErrorDomain"
    let baseURLString = "http://www.northlandchurch.net/index.php/resources/"
    let authToken = "37046b6bbce2064018367eaf61b60080"
    
    
        
    func getFeaturedDataFromNACD()
    {
        
        let URLString = "http://www.northlandchurch.net/index.php/resources/iphone-app-getfeatured"
        let myURL = NSURL(string: URLString)
        let request = NSMutableURLRequest(URL: myURL!)
        
        request.HTTPMethod = "GET"  // Compose a query string
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
               // print(response)
                print("EE CMS error: \(error)")

                
                if let httpResponse = response as? NSHTTPURLResponse
                {
                    if httpResponse.statusCode != 200
                    {
                        print("You got 404!!!???")
                        self.networkAlert()
                        return
                    }
                }

                
                if let apiData = data
                {
                    if let datastring = String(data: apiData, encoding: NSUTF8StringEncoding)
                    {
                        print("Blog string with control chars\(datastring)")
                        //print(response)
                    let data2 = self.removeBackslashes(datastring)
                        print("Blog data w/out control chars\(data2)")
                        
                    let data1 = data2.dataUsingEncoding(NSUTF8StringEncoding)
                        
                            if let apiData = data1, let jsonOutput = try? NSJSONSerialization.JSONObjectWithData(apiData, options: []) as? [String: AnyObject], let myJSON = jsonOutput
                            {
                                    let dataArray = myJSON["items"] as? [[String: AnyObject]]
                                
                                    if let constArray = dataArray
                                    {
                                        for value in constArray
                                        {
                                            let aFeatured = Featured(myDictionary: value)
                                            self.arrayOfFeatured.append(aFeatured)
                                        }
                                        self.delegate.gotTheFeatured(self.arrayOfFeatured)
                                    }
                            }
                        }
                }
                else
                {
                    self.networkAlert()
                    //self.delegate.gotTheFeatured(self.arrayOfFeatured)
                }
                
                })
            })
                
                
                task.resume()
                
                return
    }
    


    
    
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
    
    func getBlogsDataFromNACD(paginator: Int)
    {
        
        let URLString = baseURLString + "iphone-app-getblogs/" + "\(paginator)"
        
       // let URLString = "http://www.northlandchurch.net/index.php/resources/iphone-app-getblogs/"
        let myURL = NSURL(string: URLString)
        let request = NSMutableURLRequest(URL: myURL!)
        
        request.HTTPMethod = "GET"  // Compose a query string
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("EE CMS error: \(error)")

                if let httpResponse = response as? NSHTTPURLResponse
                { 
                    if httpResponse.statusCode != 200
                    {
                        print("You got 404!!!???")
                        self.networkAlert()
                        return
                    }
                }

                
                if let apiData = data
                {
                    if let datastring = String(data: apiData, encoding: NSUTF8StringEncoding)
                    {
                        print("Data From BlogsAPI: \(datastring)")
                        print("Response from BlogAPI: \(response)")
                        let data2 = self.removeBackslashes(datastring)
                        let data1 = data2.dataUsingEncoding(NSUTF8StringEncoding)
                        
                        if let apiData = data1, let jsonOutput = try? NSJSONSerialization.JSONObjectWithData(apiData, options: []) as? [String: AnyObject], let myJSON = jsonOutput
                        {
                            let dataArray = myJSON["items"] as? [[String: AnyObject]]
                            
                            if let constArray = dataArray
                            {
                                for value in constArray
                                {
                                    //let name = value["name"] as! String
                                    //self.names.append(name)
                                    let aFeatured = Featured(myDictionary: value)
                                    self.arrayOfBlogs.append(aFeatured)
                                }
                                self.delegate.gotTheFeatured(self.arrayOfBlogs)
                                print("eifgjheg")
                            }
                        }
                    }
                }
                else
                {
                    self.networkAlert()
                   // self.delegate.gotTheFeatured(self.arrayOfBlogs)
                }
                
            })
        })
        
        
        task.resume()
        
        return
    }
    
    func purgeBlogs()
    {
        arrayOfBlogs.removeAll()
    }
    
    func purgeFeatured()
    {
       arrayOfFeatured.removeAll()
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

extension String {
    static private let mappings = ["&egrave;" : "è","&quot;" : "\"", "&ldquo;" :  "\"", "&rdquo;" :  "\"", "&rsquo;" :  "'", "&lsquo;" :  "'", "&mdash;" :  "-", "&ndash;" :  "-", "&hellip;" :  "...",  "&amp;" : "&", "&lt;" : "<", "&gt;" : ">","&nbsp;" : " ","&iexcl;" : "¡","&cent;" : "¢","&pound;" : " £","&curren;" : "¤","&yen;" : "¥","&brvbar;" : "¦","&sect;" : "§","&uml;" : "¨","&copy;" : "©","&ordf;" : " ª","&laquo" : "«","&not" : "¬","&reg" : "®","&macr" : "¯","&deg" : "°","&plusmn" : "±","&sup2; " : "²","&sup3" : "³","&acute" : "´","&micro" : "µ","&para" : "¶","&middot" : "·","&cedil" : "¸","&sup1" : "¹","&ordm" : "º","&raquo" : "»&","frac14" : "¼","&frac12" : "½","&frac34" : "¾","&iquest" : "¿","&times" : "×","&divide" : "÷","&ETH" : "Ð","&eth" : "ð","&THORN" : "Þ","&thorn" : "þ","&AElig" : "Æ","&aelig" : "æ","&OElig" : "Œ","&oelig" : "œ","&Aring" : "Å","&Oslash" : "Ø","&Ccedil" : "Ç","&ccedil" : "ç","&szlig" : "ß","&Ntilde;" : "Ñ","&ntilde;":"ñ",]
    
    func stringByDecodingXMLEntities() -> String {
        
        guard let _ = self.rangeOfString("&", options: [.LiteralSearch]) else {
            return self
        }
        
        var result = ""
        
        let scanner = NSScanner(string: self)
        scanner.charactersToBeSkipped = nil
        
        let boundaryCharacterSet = NSCharacterSet(charactersInString: " \t\n\r;")
       // let boundaryCharacterSet = NSCharacterSet(charactersInString: " \t\r;")
        
        repeat {
            var nonEntityString: NSString? = nil
            
            if scanner.scanUpToString("&", intoString: &nonEntityString) {
                if let s = nonEntityString as? String {
                    result.appendContentsOf(s)
                }
            }
            
            if scanner.atEnd {
                break
            }
            
            var didBreak = false
            for (k,v) in String.mappings {
                if scanner.scanString(k, intoString: nil) {
                    result.appendContentsOf(v)
                    didBreak = true
                    break
                }
            }
            
            if !didBreak {
                
                if scanner.scanString("&#", intoString: nil) {
                    
                    var gotNumber = false
                    var charCodeUInt: UInt32 = 0
                    var charCodeInt: Int32 = -1
                    var xForHex: NSString? = nil
                    
                    if scanner.scanString("x", intoString: &xForHex) {
                        gotNumber = scanner.scanHexInt(&charCodeUInt)
                    }
                    else {
                        gotNumber = scanner.scanInt(&charCodeInt)
                    }
                    
                    if gotNumber {
                        let newChar = String(format: "%C", (charCodeInt > -1) ? charCodeInt : charCodeUInt)
                        result.appendContentsOf(newChar)
                        scanner.scanString(";", intoString: nil)
                    }
                    else {
                        var unknownEntity: NSString? = nil
                        scanner.scanUpToCharactersFromSet(boundaryCharacterSet, intoString: &unknownEntity)
                        let h = xForHex ?? ""
                        let u = unknownEntity ?? ""
                        result.appendContentsOf("&#\(h)\(u)")
                    }
                }
                else {
                    scanner.scanString("&", intoString: nil)
                    result.appendContentsOf("&")
                }
            }
            
        } while (!scanner.atEnd)
        
        return result
    }
}
