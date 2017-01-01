//
//  NowPlayingViewController.swift
//  NacdFeatured
//
//  Created by Gregory Weiss on 12/24/16.
//  Copyright © 2016 NorthlandChurch. All rights reserved.
//

import UIKit
import CoreMedia
import Foundation
import AVKit
import AVFoundation
import RealmSwift
import SDWebImage


//extension AVPlayer {
//    static let sharedAudioPlayer = AVPlayer()
//}

var player: AVPlayer!


class NowPlayingViewController: UIViewController
{
    
    var aSermon: Video!
    
    
    let audioRealm = Realm.sharedInstance
    var audioRlmItems: Results<SermonAudioRlm>!
    var dwnldSermonRlm: Results<SermonAudioRlm>!
   // var allAudioRlm: Results<SermonAudioRlm>!
    var notificationToken: NotificationToken? = nil
    var checkArrayAudioRlm = [Int]()

    static let sharedAudioPlayer = AVPlayer()
    
    @IBOutlet weak var nowPlayingImageView: UIImageView!
    
    @IBOutlet weak var playPauseButton: UIButton!

    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seriesLabel: UILabel!
    
    @IBOutlet weak var playSlider: UISlider!
    
    @IBOutlet weak var downloadCloudButton: UIButton!
    
    
    @IBOutlet weak var downloadProgressView: UIProgressView!
    
    
//    var player2 = AVPlayer.sharedAudioPlayer
   // let player2 = AVPlayer.sharedAudioPlayer
    
    let playImage = UIImage(named: "playAudio.png")
    let pauseImage = UIImage(named: "pauseAudio.png")
    
    var skipSetup = false
    
    var timer = NSTimer()
    var playingTimer = NSTimer()
    var timer2 = NSTimer()
    var slowValue: Float = 0.0
    var theTime: CMTime?
    var nowPlayItem: AVPlayerItem?

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        theTime = CMTime(seconds: 0, preferredTimescale: 1)
        
        let config = Realm.Configuration()
        Realm.Configuration.defaultConfiguration = config
        //let audSermonRlm = audioRealm.objects(SermonAudioRlm.self)

       // print(audioRlmItems.count)
        let allAudioRlm = audioRealm.objects(SermonAudioRlm.self)
        try! audioRealm.write({
                for anAud in allAudioRlm
                {
                anAud.isNowPlaying = false
                audioRealm.add(anAud, update: true)
                }
            })
        print("Now playing viewDidLoad")
//        print(dwnldSermonRlm.count)
        
        
        if aSermon == nil
        {
            skipSetup = true
            //let theCount = audSermonRlm.count - 1
            aSermon = Video.makeAudioFromRlmObjct(dwnldSermonRlm.last!)
        }
    
        configureView()

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: AVAudioSessionCategoryOptions.MixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true, withOptions: .NotifyOthersOnDeactivation)
        } catch {
            print("Better Handle this Error!")
        }
       // let songNames = ["music"]
        

        //let songs = songNames.map { AVPlayerItem(URL: NSBundle.mainBundle().URLForResource($0, withExtension: "mp3")!) }
        let song = AVPlayerItem(URL: NSURL(string: "https://s3.amazonaws.com/nacdvideo/\(aSermon.tagForAudioRef!).mp3")! )
        //player = AVQueuePlayer(items: songs)
        

        player = AVPlayer(playerItem: song)
        
//        if player.currentItem != nil
//        {
//            nowPlayItem = player.currentItem
//            
//        }
//        if song == nowPlayItem
//        {
//            skipSetup = true
//        }
        
        
        
        let theSession = AVAudioSession.sharedInstance()
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector:#selector(NowPlayingViewController.playInterrupt(_:)),
                                                         name:AVAudioSessionInterruptionNotification,
                                                         object: theSession)
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool)
    {
      //  print(skipSetup)
        super.viewWillAppear(animated)
        if skipSetup != true
        {
        prepForPlaying()
        }
        dwnldSermonRlm = audioRealm.objects(SermonAudioRlm.self).filter("isNowPlaying == true")
        
        for aPod in dwnldSermonRlm
        {
            checkArrayAudioRlm.append(aPod.id)
            print(aPod.id)
        }
   
        
    }
    
  
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playInterrupt(notification: NSNotification) {
        
        if notification.name == AVAudioSessionInterruptionNotification
            && notification.userInfo != nil {
            
            var info = notification.userInfo!
            var intValue: UInt = 0
            (info[AVAudioSessionInterruptionTypeKey] as! NSValue).getValue(&intValue)
            if let type = AVAudioSessionInterruptionType(rawValue: intValue) {
                switch type {
                case .Began:
                    print("aaaaarrrrgggg you stole me")
                    player.pause()
                    
                case .Ended:
                    let timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(NowPlayingViewController.resumeNow(_:)), userInfo: nil, repeats: false)
                }
            }
        }
    }
    
    func resumeNow(timer : NSTimer)
    {
        player.play()
        print("attempted restart")
    }
    
    
    @IBAction func downloadCloudTapped(sender: UIButton)
    {
        print("starting download in tableView")
        startFakeDownloadprogress()
        if let audioUrl = NSURL(string: "https://s3.amazonaws.com/nacdvideo/\(aSermon.tagForAudioRef!).mp3")
        {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.URLByAppendingPathComponent(audioUrl.lastPathComponent ?? "audio.mp3")
            print("This is the destURL-->> \(destinationUrl)")
            
            // to check if it exists before downloading it
            if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
                print("The file already exists at path")
              //  self.tableView.reloadData()
                
                // if the file doesn't exist
            } else {
                
                // you can use NSURLSession.sharedSession to download the data asynchronously
                NSURLSession.sharedSession().downloadTaskWithURL(audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location where error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try NSFileManager().moveItemAtURL(location, toURL: destinationUrl)
                        print("Finished downloading")
                        
                        // aSermon.isDownloading = !aSermon.isDownloading
                        // aSermon.showingTheDownload = !aSermon.showingTheDownload
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            
                            //self.tableView.reloadItemsAtIndexPaths([thisIndexPath!])
                           // self.convertAudioAndUpdateToSharedRealmObjcts(aSermon)
                            self.convertAudioAndUpdateToSharedRealmObjcts(self.aSermon)
                            print("Really finished downloading")
                            self.accelerateTimerForCompletion()
                           // self.presentAsRealm()
                            
                        })
                        
                        
                    } catch let error as NSError {
                        let alertController1 = UIAlertController(title: "Sorry, there was a problem downloading \(self.aSermon.name!)", message: "Please try again.", preferredStyle: .Alert)
                        // Add the actions
                        alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                        alertController1.addAction(UIAlertAction(title: "Delete", style: .Default, handler: nil))
                        // Present the controller
                        self.presentViewController(alertController1, animated: true, completion: nil)
                        
                        print(error.localizedDescription)
                    }
                }).resume()
            }
        }
    }
    
    
    func updateRLMForDownload(origSermon: SermonAudioRlm)
    {
        try! audioRealm.write({
            origSermon.showingTheDownload = !origSermon.showingTheDownload
            audioRealm.add(origSermon, update: true)
            print("downloaded: \(origSermon.name)")
        })
        
        
    }
    
    func convertAudioAndUpdateToSharedRealmObjcts(theAudio: Video)
    {
        var sorter = 1
        try! audioRealm.write({
            
            
            let aRlmAudio = SermonAudioRlm()
            aRlmAudio.id = theAudio.convertToURINumber(theAudio.uri!)
            
            
            aRlmAudio.sortOrder = sorter
            aRlmAudio.descript = theAudio.descript
            aRlmAudio.duration = theAudio.duration
            aRlmAudio.fileURLString = theAudio.fileURLString
            aRlmAudio.imageURLString = theAudio.imageURLString
            aRlmAudio.isDownloading = theAudio.isDownloading
            aRlmAudio.isNowPlaying = theAudio.isNowPlaying
            aRlmAudio.m3u8file = theAudio.m3u8file
            aRlmAudio.name = theAudio.name
            aRlmAudio.showingTheDownload = theAudio.showingTheDownload
            aRlmAudio.tagForAudioRef = theAudio.tagForAudioRef
            aRlmAudio.videoLink = theAudio.videoLink
            aRlmAudio.uri = theAudio.uri
            aRlmAudio.videoURL = theAudio.videoURL
            sorter = sorter + 1
            audioRealm.add(aRlmAudio, update: true)
            
            
        })
        
    }


    @IBAction func DownloadsTapped(sender: UIBarButtonItem)
    {
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DownloadsTableViewController") as! DownloadsTableViewController
        navigationController?.pushViewController(detailVC, animated: true)
        
    }
    
    
    @IBAction func playPauseTapped(sender: UIButton)
    {
        aSermon.isNowPlaying = !aSermon.isNowPlaying
        
        if aSermon.isNowPlaying
        {
           // player2.play()
            
            player.play()
            sender.setImage(pauseImage, forState: .Normal)
        }
        else if !aSermon.isNowPlaying
        {
           // player2.pause()
            player.pause()
            sender.setImage(playImage, forState: .Normal)
        }
        
    }
 
//MARK: Scrubber - SLider functions - timer
    
    @IBAction func scrubAudio(sender: UISlider)
    {
        let seekTime = CMTimeMakeWithSeconds(Double(sender.value) * CMTimeGetSeconds(player.currentItem!.asset.duration), 1)
        player.seekToTime(seekTime)
       
        
    }
    
    // MARK: - Timer update status of player
    func startTimer() {
        playingTimer.invalidate() // just in case this button is tapped multiple times
        
        // start the timer
        playingTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    // stop timer
    func cancelTimer() {
        playingTimer.invalidate()
    }
    
    func timerAction() {
        endLabel.text = CMTimeMakeWithSeconds(CMTimeGetSeconds(player.currentItem!.asset.duration) - CMTimeGetSeconds(player.currentTime()), 1).drrationText
        startLabel.text = CMTimeMakeWithSeconds(CMTimeGetSeconds(player.currentItem!.currentTime()), 1).drrationText
        let rate = Float(CMTimeGetSeconds(player.currentTime())/CMTimeGetSeconds(player.currentItem!.asset.duration))
        
        playSlider.setValue(rate, animated: false)
        theTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(player.currentItem!.currentTime()), 1)
        print(theTime)
        
        // Call delegate
        if (CMTimeGetSeconds(player.currentItem!.asset.duration) - CMTimeGetSeconds(player.currentTime()) < 1.0)
        {
            cancelTimer()
            
            player.seekToTime(CMTime(seconds: 0, preferredTimescale: 1))
            startTimer()
            
            player.pause()
            playPauseButton.setImage(playImage, forState: .Normal)
            print("playerDidFinishPlaying")
            aSermon.isNowPlaying = !aSermon.isNowPlaying
           // self.delegate.playerDidFinishPlaying(self)
        }
        
//        if self.delegate != nil {
//            self.delegate.playerDidUpdateCurrentTimePlaying(self, currentTime: (self.audioPlayer.currentItem?.currentTime())!)
//        }
    }
    
//MARK: Progress UI Updates - timers and functions
    
    func startFakeDownloadprogress()
    {
        timer2.invalidate() // just in case this button is tapped multiple times
        
        // start the timer
        timer2 = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(slowTimerAction), userInfo: nil, repeats: true)
        
    }
    
    func slowTimerAction()
    {
        if downloadProgressView.progress == 1.0
        {
           timer2.invalidate()
            downloadProgressView.alpha = 0
        }
        else
        {
        downloadProgressView.progress = slowValue
        slowValue = slowValue + 0.0025
        }
    }
    
    func accelerateTimerForCompletion()
    {
        timer2.invalidate() // just in case this button is tapped multiple times
        
        // start the timer
        timer2 = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(fastTimerAction), userInfo: nil, repeats: true)
        
    }
    
    func fastTimerAction()
    {
        if downloadProgressView.progress == 1.0
        {
            downloadCloudButton.alpha = 0
            timer2.invalidate()
            downloadProgressView.alpha = 0
        }
        else
        {
            downloadProgressView.progress = slowValue
            slowValue = slowValue + 0.1
        }

        
    }

//MARK: Skipping Functions
    
    @IBAction func rewindTapped(sender: UIButton)
    {
        let subtractTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(player.currentItem!.currentTime()), 1) - CMTime(seconds: 30, preferredTimescale: 1)
        player.seekToTime(subtractTime)
        
    }
    
    @IBAction func forwardTapped(sender: UIButton)
    {
        let addTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(player.currentItem!.currentTime()), 1) + CMTime(seconds: 30, preferredTimescale: 1)
        player.seekToTime(addTime)
    }
    
    
    func configureView()
    {
        startLabel.text = "00:00"
        endLabel.text = ""
        titleLabel.text = aSermon.name
        seriesLabel.text = aSermon.descript
        
//        if checkArrayAudioRlm.contains(aSermon.convertToURINumber(aSermon.uri!))
//        {
//          downloadCloudButton.setImage(pauseImage, forState: .Normal)
//        }
        
//        let attributedBody  = NSMutableAttributedString(string: aSermon.descript!)
//        
//        // *** Create instance of `NSMutableParagraphStyle`
//        let paragraphStyle = NSMutableParagraphStyle()
//        
//        // *** set LineSpacing property in points ***
//        paragraphStyle.lineSpacing = 4 // Whatever line spacing you want in points
//        
//        // *** Apply attribute to string ***
//        attributedBody.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedBody.length))
//        
//        // *** Set Attributed String to your label ***
//        
//        
//        fullDescriptionLabel.attributedText = attributedBody
        
        
        let myURL = aSermon.imageURLString!
        let placeHolder = UIImage(named: "WhiteBack.png")
        let realURL = NSURL(string: myURL)
        nowPlayingImageView.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: .ProgressiveDownload)
    }
    
    func prepForPlaying()
    {
//        var now = player.currentTime()
//        if now == theTime!
//        {
//           print("Wow maybe this is nothing")
//        }
        
        
        let sermonID = aSermon.convertToURINumber(aSermon.uri!)

//        let playerItem2 = AVPlayerItem(URL: NSURL(string: "https://s3.amazonaws.com/nacdvideo/\(aSermon.tagForAudioRef!).mp3")! )
        
        if let audioUrl = NSURL(string: "https://s3.amazonaws.com/nacdvideo/\(aSermon.tagForAudioRef!).mp3")
        {
            // then lets create your document folder url
            let documentsDirectoryURL =  NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.URLByAppendingPathComponent(audioUrl.lastPathComponent ?? "audio.mp3")
            print("This is the destURL-->> \(destinationUrl)")
            
            // to check if it exists before downloading it
            if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
                print("The file already exists at path")
                
                let audioFilePath =  destinationUrl.path!
                
                let audioFileUrl = NSURL.fileURLWithPath(audioFilePath) //   .fileURL(withPath: audioFilePath!)
                let myAsset = AVAsset(URL: audioFileUrl)
                let playerItem1 = AVPlayerItem(asset: myAsset)
               // player = AVPlayer(playerItem: playerItem1)
                
                
                player.replaceCurrentItemWithPlayerItem(playerItem1)
            }
            
           player.rate = 1.0
            
            if aSermon.isNowPlaying
            {
                
//                if sermonID ==  56  //dwnldSermonRlm[0].id
//                {
//                    print(sermonID)
//                    print(dwnldSermonRlm[0].id)
//                    player.seekToTime(theTime!)
//                    startTimer()
//                }
//                
//                else
//                {
                
                
                    player.play()
              // if player.status == ???
                    startTimer()
               // }
                
            }
            else if !aSermon.isNowPlaying
            {
                player.pause()
            }
            
            if aSermon.isNowPlaying
            {
                // streamPlayer.play()
                //self.audioPlayer.play()
                playPauseButton.setImage(pauseImage, forState: .Normal)
            }
            else
            {
                //streamPlayer.pause()
                //self.audioPlayer.stop()
                playPauseButton.setImage(playImage, forState: .Normal)
            }
       // }
        
        }
        
        else
        {
                
        let playerItem2 = AVPlayerItem(URL: NSURL(string: "https://s3.amazonaws.com/nacdvideo/\(aSermon.tagForAudioRef!).mp3")! )
        player = AVPlayer(playerItem: playerItem2)
       // player.replaceCurrentItemWithPlayerItem(playerItem2)
        //player2 = AVPlayer(playerItem: playerItem2)
        print("streaming audio")
        // player.volume = 1
        
        player.rate = 1.0
            
        
            if aSermon.isNowPlaying
            {
                
                if sermonID == 56  //dwnldSermonRlm[0].id
                {
                    print(sermonID)
                    print(dwnldSermonRlm[0].id)
                    player.seekToTime(theTime!)
                    startTimer()
                }
                
                else
                {
                    player.play()
                    startTimer()
                }
            }
            else if !aSermon.isNowPlaying
            {
                player.pause()
            }
            
            if aSermon.isNowPlaying
            {
                // streamPlayer.play()
                //self.audioPlayer.play()
                playPauseButton.setImage(pauseImage, forState: .Normal)
            }
            else
            {
                //streamPlayer.pause()
                //self.audioPlayer.stop()
                playPauseButton.setImage(playImage, forState: .Normal)
            }
            
        }
        convertAudioAndUpdateToSharedRealmObjcts(aSermon)
//        let audSermonRlm = audioRealm.objects(SermonAudioRlm.self).filter("isNowPlaying == true")
//        // audioRlmItems = audSermonRlm.sorted("tagForAudioRef", ascending: false)
//        audioRlmItems = audSermonRlm
//        print(aSermon.isNowPlaying)
//        print(aSermon.name)
//        print(audSermonRlm.count)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension CMTime {
    var drrationText:String {
        let totalSeconds = CMTimeGetSeconds(self)
        let hours: Int = Int(totalSeconds / 3600)
        let minutes:Int = Int(totalSeconds % 3600 / 60)
        let seconds:Int = Int(totalSeconds % 60)
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}

