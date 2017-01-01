//
//  APIResult.swift
//  IronTrivia
//
//  Created by Ross Gottschalk on 9/4/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import Foundation
class APIResult
{
    let id: Int
    let title: String
    let cluesCount: Int
    let cluesArray: [[String: AnyObject]]
    
    
    init(resultDict: [String: AnyObject])
    {
        id = resultDict["id"] as! Int
        title = resultDict["title"] as! String
        cluesCount = resultDict["clues_count"] as! Int
        cluesArray = resultDict["clues"] as! [[String: AnyObject]]
    }
    
    
}
