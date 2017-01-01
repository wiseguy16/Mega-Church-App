//
//  Blog.swift
//  NacdFeatured
//
//  Created by Greg Wise on 11/14/16.
//  Copyright © 2016 NorthlandChurch. All rights reserved.
//

import Foundation

class Blog
{
    
    
    var channel: String? = ""
    var title: String? = ""
    var urltitle: String? = ""
    var entry_date: String? = ""
    // var speaker: String? = ""
    // var mediaFile: String? = ""
    var image: String? = ""
    var webURL: String? = ""
    
    
    init(myDictionary: [String: AnyObject])
    {
        
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
    }
    
}