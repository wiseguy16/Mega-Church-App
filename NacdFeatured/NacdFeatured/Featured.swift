//
//  Podcast.swift
//  NacdNews
//
//  Created by Gregory Weiss on 9/9/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class Featured
{
    
    var uri: String? = ""
    var channel: String? = ""
    var title: String? = ""
    var urltitle: String? = ""
    var entry_date: String? = ""
   // var speaker: String? = ""
    var mediaFileM3U8: String? = ""
    var image: String? = ""
    var webURL: String? = ""
    var body: String? = ""
    var closingText: String? = ""
    var entry_id: Int? = 1
    var sortOrder: Int? = 1
    
    
    init(myDictionary: [String: AnyObject])
    {
        self.uri = myDictionary["uri"] as? String
        self.entry_id = myDictionary["entry_id"] as? Int
        self.sortOrder = myDictionary["sortOrder"] as? Int
        self.channel = myDictionary["channel"] as? String
        self.title = myDictionary["title"] as? String
        self.urltitle = myDictionary["urltitle"] as? String
        self.entry_date = myDictionary["entry_date"] as? String
       // self.speaker = myDictionary["media-speaker"] as? String
       // self.mediaFile = myDictionary["media-file"] as? String
        
        if let fileAvailable = myDictionary["media-vimeo-m3u8-id"]
        {
            self.mediaFileM3U8 = fileAvailable as? String
        }
        
        // IMAGE
        
        if let videoImage = myDictionary["media-primary"]
        {
            self.image = videoImage as? String
        }
        
        if let blogImage = myDictionary["blog-primary"]
        {
            self.image = blogImage as? String
        }
        
        // MAIN BODY
        
        if let blogBody = myDictionary["blog-post"]
        {
            self.body = blogBody as? String
        }
        
        if let mediaBody = myDictionary["media-description"]
        {
            self.body = mediaBody as? String
        }
        
        if myDictionary["media-description"] == nil
        {
           if let backupBody = myDictionary["media-speaker"]
           {
                self.body = backupBody as? String
            }
        }
        
        
        // CLOSING TEXT
        if let catDict = (myDictionary["categories"] as? [[String: AnyObject]])
        {
            let catNameDict = catDict[0]
            self.closingText = catNameDict["category_name"] as? String
        }
        
        if let tagsDict = (myDictionary["tags"] as? [[String: AnyObject]])
        {
            let tagsNameDict = tagsDict[0]
            self.closingText = tagsNameDict["tag_name"] as? String
        }

    
        
        // ADRESS FOR SHARE BODY
        
        let baseURL = "http://www.northlandchurch.net/"
        let urlPart2 = self.channel?.lowercaseString
        let urlPart3 = self.urltitle
        self.webURL = baseURL + urlPart2! + "/" + urlPart3!
    }
    
    
    func replaceBreakWithReturn(brString: String) -> String
    {
        var properRetun = brString.stringByReplacingOccurrencesOfString("<br />    ", withString: "\n")
        properRetun = properRetun.stringByReplacingOccurrencesOfString("<br />", withString: "\n")
        properRetun = properRetun.stringByReplacingOccurrencesOfString("<p style='text-align: center;'>", withString: "")
        properRetun = properRetun.stringByReplacingOccurrencesOfString("<p>", withString: "")
        properRetun = properRetun.stringByReplacingOccurrencesOfString("</p>", withString: "\n \n")
        properRetun = properRetun.stringByReplacingOccurrencesOfString("<strong>", withString: "")
        properRetun = properRetun.stringByReplacingOccurrencesOfString("</strong>", withString: "")
        
        //properRetun = properRetun.html2String
        
       // print(properRetun)
        
        
        return properRetun
    }
    
    
    static func makeFeaturedFromRlmObjct(ftrdOnDisk: BlogRlm) -> Featured?
    {
        
        if let convertDict: [String: AnyObject] = ["uri": ftrdOnDisk.uri!,
                                                   "entry_id": ftrdOnDisk.entryID!,
                                                   "sortOrder": ftrdOnDisk.sortOrder,
                                                   "channel": ftrdOnDisk.channel!,
                                                   "title": ftrdOnDisk.title!,
                                                   "urltitle": ftrdOnDisk.urltitle!,
                                                   "entry_date": ftrdOnDisk.entry_date!,
                                                   
                                                   "blog-primary": ftrdOnDisk.image!,
                                                   "webURL": ftrdOnDisk.webURL!,
                                                   "mediaFileM3U8": ftrdOnDisk.mediaFileM3U8!,
                                                   "blog-post": ftrdOnDisk.body!,
                                                   "closingText": ftrdOnDisk.closingText!]
        {
            let aFeatured = Featured(myDictionary: convertDict)
            
            return aFeatured
        }
        else
        {
            return nil
        }
    }


    
    
}


extension String {
    
    var html2AttributedString: NSAttributedString? {
        guard
            let data = dataUsingEncoding(NSUTF8StringEncoding)
            else { return nil }
        do {
           // return try NSAttributedString(data: data, options: [], documentAttributes: nil)
            return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType/*, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding*/], documentAttributes: nil)

        } catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}


//cell.detailTextLabel?.text = item.itemDescription.html2String


