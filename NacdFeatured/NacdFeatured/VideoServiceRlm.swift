//
//  VideoServiceRlm.swift
//  NacdFeatured
//
//  Created by Gregory Weiss on 12/12/16.
//  Copyright © 2016 NorthlandChurch. All rights reserved.
//

import Foundation
import RealmSwift

class VideoServiceRlm: Object
{
    
    override static func primaryKey() -> String? {
        return "id"
    }
    

    
    dynamic var id = 1
    //dynamic var entryID: String? = ""
    dynamic var sortOrder = 1

    dynamic var uri: String? = ""
    dynamic var name: String? = ""
    dynamic var duration: String?
    dynamic var imageURLString: String? = ""
    dynamic var descript: String? = ""
    dynamic var videoLink: String? = ""
    dynamic var videoURL: String? = ""
    dynamic var fileURLString: String? = ""
    dynamic var m3u8file: String? = ""
    dynamic var isDownloading: Bool = false
    dynamic var showingTheDownload: Bool = false
    dynamic var isNowPlaying: Bool = false
    dynamic var tagForAudioRef: String? = ""
    dynamic var totalResults = 1

    
    
    //    func setDefaultRealm()
    //    {
    //        let config = Realm.Configuration()
    //        Realm.Configuration.defaultConfiguration = config
    //    }
    
    
    
    
    
}
