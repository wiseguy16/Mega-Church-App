//
//  LiturgyRlm.swift
//  NacdFeatured
//
//  Created by Gregory Weiss on 12/13/16.
//  Copyright © 2016 NorthlandChurch. All rights reserved.
//

import Foundation
import RealmSwift

class LiturgyRlm: Object
{
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    
    
    dynamic var id = 1
    dynamic var entryID: Int = 1
    dynamic var sortOrder = 1
    
    dynamic var isExpanded: Bool = false
    dynamic var title: String? = ""
    dynamic var tranlation: String? = ""
    dynamic var entry_date: String? = ""
    dynamic var sequence: String? = ""
    dynamic var scripture: String? = ""
    dynamic var urltitle: String? = ""
    dynamic var hasBeenRead: Bool = false
    dynamic var dateStamp: String? 
    
    

    
    
    
    //    func setDefaultRealm()
    //    {
    //        let config = Realm.Configuration()
    //        Realm.Configuration.defaultConfiguration = config
    //    }
    
    
    
    
    
}
