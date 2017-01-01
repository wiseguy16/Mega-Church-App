//
//  FeaturedRlm.swift
//  NacdFeatured
//
//  Created by Gregory Weiss on 12/9/16.
//  Copyright © 2016 NorthlandChurch. All rights reserved.
//

import RealmSwift

class FeaturedRlm: Object
{
    
    override static func primaryKey() -> String? {
        return "id"
    }

    dynamic var id = 1
    dynamic var entryID: String? = ""
    dynamic var sortOrder = 1
    
    dynamic var channel: String? = ""
    dynamic var title: String? = ""
    dynamic var urltitle: String? = ""
    dynamic var entry_date: String? = ""
    // var speaker: String? = ""
    dynamic var mediaFileM3U8: String? = ""
    dynamic var image: String? = ""
    dynamic var webURL: String? = ""
    dynamic var body: String? = ""
    dynamic var closingText: String? = ""
    dynamic var uri: String? = ""
    
    
//    func setDefaultRealm()
//    {
//        let config = Realm.Configuration()
//        Realm.Configuration.defaultConfiguration = config
//    }
    
    

    
    
}
