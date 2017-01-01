//
//  AudioPlaybackDownload.swift
//  NacdFeatured
//
//  Created by Gregory Weiss on 11/3/16.
//  Copyright © 2016 NorthlandChurch. All rights reserved.
//

import Foundation
import AVFoundation


class AudioPlaybackDownload
{
    let myAudio = Audio()
    
    
    
    func downloadFile(callback: (error: ErrorType?) -> Void) {
        let task = NSURLSession.sharedSession().dataTaskWithURL(myAudio.file!) { data, response, error in
            if let error = error {
                print(error)
            }
            else if let data = data {
                let url = documentsDirectory.URLByAppendingPathComponent("\(self.myAudio.contentID).\(self.myAudio.ext)")
                do {
                    try data.writeToURL(url, options: [])
                    callback(error: nil)
                }
                catch {
                    print("write failed $(error)")
                    callback(error: error)
                }
            }
            else {
                callback(error: NSError(domain: "Download", code: -1, userInfo: nil))
                // unknown error.
            }
        }
        task.resume()
    }
    
    var savedFileURL: NSURL {
        return  documentsDirectory.URLByAppendingPathComponent("\(myAudio.contentID).\(myAudio.ext)")
    }
    
    var savedFile: NSData? {
        return try? NSData(contentsOfURL: savedFileURL, options: [])
    }
    
    func deleteMedia() {
        let url = documentsDirectory.URLByAppendingPathComponent(myAudio.contentID!)
        let _ = try? NSFileManager.defaultManager().removeItemAtURL(url)
    }
}

var documentsDirectory: NSURL = {
    let searchPaths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return searchPaths.last!
}()

class Audio
{
    var file: NSURL? //= "fileName?"
    var contentID: String? // = "12345?"
    var ext: String? // = ".mp3"
    
}
