//
//  MediaItem.swift
//  FrameworkDesign1
//
//  Created by Gregory Weiss on 8/23/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import Foundation

class MediaItem
{
   
    
    let title: String
    let media_speaker: String
    
    let entry_id: Int
    let channel: String
    
    let urltitle: String
    let entry_date: String

    let media_description: String

    let media_image: String

    let media_vimeo_m3u8_id: String

  
   
   
    
    init(myDictionary: [String: AnyObject])
    {
       
        
        title = myDictionary["title"] as! String
        media_speaker = myDictionary["media-speaker"] as! String
        
        entry_id = myDictionary["entry_id"] as! Int
        channel = myDictionary["channel"] as! String
        
        urltitle = myDictionary["urltitle"] as! String
        entry_date = myDictionary["entry_date"] as! String

        media_description = myDictionary["media-description"] as! String

        media_image = myDictionary["media-primary"] as! String

        media_vimeo_m3u8_id = myDictionary["media-vimeo-m3u8-id"] as! String
        
    
 
    }
    

}

