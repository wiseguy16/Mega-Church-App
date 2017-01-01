//
//  Liturgy.swift
//  NacdFeatured
//
//  Created by Gregory Weiss on 11/8/16.
//  Copyright © 2016 NorthlandChurch. All rights reserved.
//

import Foundation

class Liturgy
    
{
    
    var isExpanded = false
    let title: String
    var tranlation: String 
    let entry_date: String
    let sequence: String
    let scripture: String
    let urltitle: String
    var entry_id: Int? = 1
    
    
    
    init(myDictionary: [String: AnyObject])
    {
        
        
        
        tranlation = myDictionary["tranlation"] as! String
        sequence = myDictionary["sequence"] as! String
        scripture = myDictionary["scripture"] as! String
        title = myDictionary["title"] as! String
        urltitle = myDictionary["urltitle"] as! String
        entry_date = myDictionary["entry_date"] as! String
        entry_id = myDictionary["entry_id"] as? Int
        
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
    
    
    
    
    /*
     "entry_id": 30498,
     "channel": "Liturgy",
     "title": "Psalm 119:169-176",  "<br />    "
     "0": "psalm_119169_176",
     "entry_date": "2014-11-23T01:03:00-05:00",
     "tranlation": "NIV",
     "scripture": "May my cry come before you, O Lord;
     "sequence": "Morning"
     
     */
    
    
    
    
    
}