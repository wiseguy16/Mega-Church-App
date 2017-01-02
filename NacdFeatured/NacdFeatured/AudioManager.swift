//
//  AudioManager.swift
//  NacdFeatured
//
//  Created by Gregory Weiss on 1/1/17.
//  Copyright © 2017 NorthlandChurch. All rights reserved.
//

import Foundation
import AVFoundation

class AudioManager {
    
    var audioPlayer = AVPlayer()
    var isCurrentlyPlaying = false
    
    class var sharedInstance: AudioManager {
        struct Static {
            static var instance: AudioManager?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = AudioManager()
        }
        return Static.instance!
    }
    
    func playAudio(fileName: String, fileType: String){
        let url = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource(fileName, ofType: fileType)!)
        audioPlayer = AVPlayer(URL: url)
        audioPlayer.play()
        isCurrentlyPlaying = !isCurrentlyPlaying
        
        //audioPlayer.numberOfLoops = loop
    }
    
    func stopAudio(){
        audioPlayer.pause()
    }
}