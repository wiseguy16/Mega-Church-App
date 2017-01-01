//
//  BlogItem.swift
//  NacdNews
//
//  Created by Gregory Weiss on 8/31/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import Foundation

class BlogItem

{
    
    var isExpanded = false
    let title: String
    let author: String
    let entry_date: String
    let subText: String
    let body: String
    let bioDisclaimer: String
    let blog_primary: String
    
    
    
    init(myDictionary: [String: AnyObject])
    {
       
        
        
        author = myDictionary["author"] as! String
        subText = myDictionary["subText"] as! String
        body = myDictionary["body"] as! String
        title = myDictionary["title"] as! String
        bioDisclaimer = myDictionary["bioDisclaimer"] as! String
        entry_date = myDictionary["entry_date"] as! String
        blog_primary = myDictionary["blog-primary"] as! String
        
    }
 
    
    
    
    // **************** USING FEATURED CLASS INSTEAD OF BLOGITEMS !!!!!!!  *********************
    
    
    
}