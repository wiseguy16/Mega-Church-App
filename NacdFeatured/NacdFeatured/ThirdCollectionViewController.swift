//
//  ThirdCollectionViewController.swift
//  NacdNews
//
//  Created by Gregory Weiss on 9/9/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import UIKit
import CoreMedia
import Foundation
import AVKit
import AVFoundation
import SDWebImage
import RealmSwift





private let reuseIdentifier = "ThirdCollectionViewCell"

class ThirdCollectionViewController: UICollectionViewController, APIControllerProtocol, MenuTransitionManagerDelegate
{
    let defaultsAudio = NSUserDefaults.standardUserDefaults()
    var todayCheck: NSDate?
    
    var delegate: GetCurrentTimeDelegate?


    
    var myDateFormatter = NSDateFormatter()
    
    var incrementer = 1
    
    let secondsInMin = 60
    let minInHour = 60
    let hoursInDay = 24
    let daysInWeek = 7
    var thisWeek: Int = 0
    
    let player3 = AudioManager.sharedInstance
    

    
    var audioPlayer: AVAudioPlayer!
    var streamPlayer: AVPlayer!
    var isPlaying = false
    
    let loadingIndicator = UIActivityIndicatorView()
    let smallLoader = UIActivityIndicatorView()
    
    var podcastItems = [Podcast]()
    var myFormatter = NSDateFormatter()
    
    var anApiController: APIController!
    let menuTransitionManager = MenuTransitionManager()
    
    //************************  REALM  *****************************
    let audioRealm = Realm.sharedInstance
    var audioRlmItems: Results<SermonAudioRlm>!
    var nowPlayingRlmItems: Results<SermonAudioRlm>!
    var notificationToken: NotificationToken? = nil
    var checkArrayAudioRlm = [Int]()
    
    //************************  REALM  *****************************
    
    
    var arrayOfPlayButton = [UIButton]()
    var arrayOfIndexPaths = [NSIndexPath]()
    var arrayForUpdateVideos = [Video]()
    
    var arrayOfSermonVideos = [Video]()
    var animatingVideos = [Video]()
    var perPage = 15
    var theseVideosString = "/users/northlandchurch/albums/3446210/videos?per_page=15"
    
    var currentPlayer: AVPlayer?
    var player2 = AVPlayer()
    var playerItem2: AVPlayerItem?
    
    let refresher = UIRefreshControl()
    
    var unavailableSquare = UILabel()
    var unavailableSquare2 = UILabel()
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        todayCheck = NSDate()
        
        myDateFormatter.dateFormat = "yyyy-MM-dd"
        
         makeUnavailableLabel(unavailableSquare, unavailableBar2: unavailableSquare2)
         makeLoadActivityIndicator()
        
        anApiController = APIController(delegate: self)
        
        let config = Realm.Configuration()
        Realm.Configuration.defaultConfiguration = config
        
        let audSermonRlm = audioRealm.objects(SermonAudioRlm.self)
        audioRlmItems = audSermonRlm.sorted("tagForAudioRef", ascending: false)
        
        presentAsRealm()
        
        
        NSKernAttributeName.capitalizedString
        myFormatter.dateStyle = .ShortStyle
        myFormatter.timeStyle = .NoStyle
        
        self.collectionView!.alwaysBounceVertical = true
        //refresher.tintColor = UIColor.grayColor()
        refresher.addTarget(self, action: #selector(ThirdCollectionViewController.reloadFromAPI), forControlEvents: .ValueChanged)
        collectionView!.addSubview(refresher)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        smallLoader.stopAnimating()
        if player3.audioPlayer != nil
        {
            currentPlayer = player3.audioPlayer
        }

        

        
        let audSermonRlm = audioRealm.objects(SermonAudioRlm.self).filter("isNowPlaying == true")
        nowPlayingRlmItems = audSermonRlm
        
        let dateAudio_get = defaultsAudio.objectForKey("DateAudio") as? NSDate ?? todayCheck
        let result = Int(todayCheck!.timeIntervalSinceDate(dateAudio_get!))
        if result > 43200
        {
            makeLoadActivityIndicator()
            reloadFromAPI()
        }
//        let viewControllers = self.navigationController?.viewControllers
//        let count = viewControllers?.count
//        if count > 1 {
//            if let sourceVC = viewControllers?[count! - 2] as? DownloadsTableViewController
//            {
//                makeLoadActivityIndicator()
//                reloadFromAPI()
//            }
//        }

    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        if arrayOfSermonVideos.count > 0
        {
            unavailableSquare.alpha = 0
            unavailableSquare2.alpha = 0
        }
        else
        {
            //makeUnavailableLabel()
            unavailableSquare.alpha = 0.5
            unavailableSquare2.alpha = 0.5
        }
        //reloadFromAPI()
        defaultsAudio.setObject(todayCheck, forKey: "DateAudio")

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if arrayOfSermonVideos.count > 0
        {
            unavailableSquare.alpha = 0
            unavailableSquare2.alpha = 0
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        refresher.endRefreshing()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //************************  REALM  *****************************
    
    func presentAsRealm()
    {
        if audioRlmItems.count > 0
        {
            perPage = audioRlmItems.count
            for audRlm in audioRlmItems
            {
                if let rAudio = Video.makeAudioFromRlmObjct(audRlm)
                {
                    arrayOfSermonVideos.append(rAudio)
                }
            }
            loadingIndicator.stopAnimating()
            if refresher.refreshing
            {
                stopRefresher()
            }
            anApiController.syncTheSermons(arrayOfSermonVideos)
            
            collectionView?.reloadData()
            print("Already have items \(audioRlmItems.count)")
        }
        else
        {
            theseVideosString = "/users/northlandchurch/albums/3446210/videos?per_page=\(perPage)"
            anApiController.getVideoSermonsDataFromVimeo(theseVideosString)
        }
    }
    
    func getFromRealm()
    {
        do
        {
            audioRlmItems = audioRealm.objects(SermonAudioRlm).sorted("tagForAudioRef", ascending: false)
            print("Got Realm items maybe??")
        }
        catch
        {
            print("Didn't save in Realm")
        }
    }

    
    
    func reloadFromAPI()
    {
        //code to execute during refresher
        resetIncrementer()

            for aAudRlm in audioRlmItems
            {
                if !checkArrayAudioRlm.contains(aAudRlm.id)
                {
                    checkArrayAudioRlm.append(aAudRlm.id)
                }
                print(aAudRlm.id)
            }

        theseVideosString = "/users/northlandchurch/albums/3446210/videos?per_page=\(perPage)"

        anApiController.syncTheSermons(arrayOfSermonVideos)
        anApiController.purgeSermons()
        anApiController.getVideoSermonsDataFromVimeo(theseVideosString)
    }
    
    
    func convertArrayToSharedRealmObjcts(arrayOfAudios: [Video])
    {
        var sorter = 1
        try! audioRealm.write({
            
            for audio in arrayOfAudios
            {
                let aRlmAudio = SermonAudioRlm()
                aRlmAudio.id = audio.convertToURINumber(audio.uri!)
                
                if !checkArrayAudioRlm.contains(aRlmAudio.id)
                {
                    aRlmAudio.sortOrder = sorter
                    aRlmAudio.descript = audio.descript
                    aRlmAudio.duration = audio.duration
                    aRlmAudio.fileURLString = audio.fileURLString
                    aRlmAudio.imageURLString = audio.imageURLString
                    aRlmAudio.isDownloading = audio.isDownloading
                    aRlmAudio.isNowPlaying = audio.isNowPlaying
                    aRlmAudio.m3u8file = audio.m3u8file
                    aRlmAudio.name = audio.name
                    aRlmAudio.showingTheDownload = audio.showingTheDownload
                    aRlmAudio.tagForAudioRef = audio.tagForAudioRef
                    aRlmAudio.videoLink = audio.videoLink
                    aRlmAudio.uri = audio.uri
                    aRlmAudio.videoURL = audio.videoURL
                    sorter = sorter + 1
                    audioRealm.add(aRlmAudio, update: true)
                }
            }
        })
        
    }
    
    
    func gotTheVideos(theVideos: [Video])
    {
        smallLoader.stopAnimating()
        for aVid in theVideos
        {
            if !checkArrayAudioRlm.contains(aVid.convertToURINumber(aVid.uri!))
            {
                arrayOfSermonVideos.append(aVid)
            }
        }
      //  arrayOfSermonVideos = theVideos //TODO: Something here is messing with UI losing track of download status. Things are getting reset!!
        print("array of audio has \(arrayOfSermonVideos.count)")
        
        //if incrementer == 0
        //{
        convertArrayToSharedRealmObjcts(theVideos)
        getFromRealm()
        arrayOfSermonVideos = []
        for audRlm in audioRlmItems
        {
            if let rAudio = Video.makeAudioFromRlmObjct(audRlm)
            {
                arrayOfSermonVideos.append(rAudio)
            }
        }


       // presentAsRealm()
        //}
        
        loadingIndicator.stopAnimating()
        
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.unavailableSquare.alpha = 0
            self.unavailableSquare2.alpha = 0
            self.view.layoutIfNeeded()
            }, completion: nil)
        
        if refresher.refreshing
        {
            stopRefresher()
        }
        
        collectionView?.reloadData()
    }
    
    
    func loadMoreAutoRetrieve()
    {
        if incrementer < 6
        {
            makeSmallLoadIndicator()
            //incrementer = incrementer + 1
            
            
            for aAudRlm in audioRlmItems
            {
                if !checkArrayAudioRlm.contains(aAudRlm.id)
                {
                    checkArrayAudioRlm.append(aAudRlm.id)
                }
                print(aAudRlm.id)
            }
            
            theseVideosString = "/users/northlandchurch/albums/3446210/videos?per_page=\(perPage)"
            
            anApiController.syncTheSermons(arrayOfSermonVideos)
            anApiController.purgeSermons()
            anApiController.getVideoSermonsDataFromVimeo(theseVideosString)
        }
    }
    //************************  REALM  *****************************

    
    func stopRefresher()
    {
        refresher.endRefreshing()
    }
    
    
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func downloadsTapped(sender: UIBarButtonItem)
    {
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DownloadsTableViewController") as! DownloadsTableViewController
        navigationController?.pushViewController(detailVC, animated: true)
        
    }
    
    
    @IBAction func nowPlayingTapped(sender: UIBarButtonItem)
    {
//        let playingVC = self.storyboard?.instantiateViewControllerWithIdentifier("NowPlayingViewController") as! NowPlayingViewController
//        navigationController?.presentViewController(playingVC, animated: true, completion: nil)
        
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("NowPlayingViewController") as! NowPlayingViewController
        navigationController?.pushViewController(detailVC, animated: true)
       // aSermon.isNowPlaying = true
        self.delegate = detailVC
       
        if let playingSermon = nowPlayingRlmItems.last
        {
           if let aSermon = Video.makeAudioFromRlmObjct(playingSermon)
           {
             detailVC.aSermon = aSermon
           // var tempTime = detailVC.theTime
//            print(tempTime)
//            detailVC.newTime = tempTime
            if currentPlayer != nil
            {
               // print("3rd CollView: \(CMTimeMakeWithSeconds(CMTimeGetSeconds(currentPlayer!.currentItem!.currentTime()), 1))")
                let nowTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentPlayer!.currentItem!.currentTime()), 1)
                delegate!.getCurrentAudioTime(nowTime)
            }

             detailVC.skipSetup = true
            
           // let player3 = AudioManager.sharedInstance
           // player3.playAudio("audioname", fileType: "mp3")
            
            // USE THE SINGLETON IMPLEMENTATION HERE!!
//            if player3.becomeCurrentlyPlaying == true
//            {
//                print("don't play a new file")
//            }
        
            
           }
        }
        
        
    }
    
    
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue)
    {
        let sourceController = segue.sourceViewController as! MenuTableViewController
        //self.title = sourceController.currentItem
    }
    
    
    
    
    func setupAudioSession()
    {
        
        var mySession = AVAudioSession()
        // mySession.setActive(true, withOptions: .)
        //  try? mySession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: [])
        // try! AVAudioSession.sharedInstance().setActive(true)
        
        
    }

    
    
    func makeLoadActivityIndicator()
    {
        loadingIndicator.activityIndicatorViewStyle = .WhiteLarge
        loadingIndicator.color = UIColor.grayColor()
        loadingIndicator.frame = CGRect(x: self.view.frame.width / 2 - 75, y: self.view.frame.height / 2 - 75, width: 150, height: 150)
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        
    }
    
    func makeSmallLoadIndicator()
    {
        smallLoader.activityIndicatorViewStyle = .White
        smallLoader.color = UIColor.grayColor()
        smallLoader.frame = CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height * 0.80 + 20, width: 60, height: 60)
        smallLoader.startAnimating()
        view.addSubview(smallLoader)
        
    }

    
    
    
    
    func resetIncrementer()
    {
        incrementer = 1
        
        theseVideosString = "/users/northlandchurch/albums/3446210/videos?page=\(incrementer)&per_page=\(perPage)"
        
    }

    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return arrayOfSermonVideos.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ThirdCollectionViewCell
        
        // Configure the cell
        
        cell.loadingView.alpha = 0
        cell.downloadButton.alpha = 1
        cell.downloadButton.userInteractionEnabled = true
        let downloadCloudImage = UIImage(named: "Download From Cloud-50.png")
       // let finishedDownloadImage = UIImage(named: "blackDot.png")
        
        
        cell.downloadButton.setImage(downloadCloudImage, forState: .Normal)
        
        let playImage = UIImage(named: "btn-play.png")
        let pauseImage = UIImage(named: "pause-button-new.png")
        cell.playPauseButton.setImage(playImage, forState: .Normal)
        cell.deleteButton.alpha = 0
        cell.deleteButton.userInteractionEnabled = false
        
        
        //let aPodcast = podcastItems[indexPath.row]
        let aVid = arrayOfSermonVideos[indexPath.row]
       // let origSermon = arrayOfSermonVideos[indexPath.row]
        
        if aVid.isNowPlaying == true
        {
            cell.playPauseButton.setImage(pauseImage, forState: .Normal)
        }
        
        
        let part1Name = aVid.name?.componentsSeparatedByString("(")
        
        cell.titleLabel.text = part1Name![0]
        cell.speakerLabel.text = aVid.descript
        cell.podcastImageView.image = UIImage(named: "WhiteBack.png")
        
        
        
        
        //**********************************************************************************
        //**********************************************************************************
        // STUFF FOR LOADING INDICATOR & PLAYBAR
       /*
        if aVid.isDownloading == true // && aVid.showingTheDownload == false
        {
            cell.loadingView.alpha = 1
        }
        */
        
        if aVid.showingTheDownload == true
        {
            //cell.downloadButton.setImage(finishedDownloadImage, forState: .Normal)
//            cell.downloadButton.alpha = 0
            cell.downloadButton.userInteractionEnabled = false
            cell.downloadButton.alpha = 0
            cell.deleteButton.alpha = 1.0
            cell.deleteButton.userInteractionEnabled = false
        }
        
        
        //        let weekNumber = thisWeek - indexPath.row
        //        cell.initComponent("https://s3.amazonaws.com/nacdvideo/2016/2016Week\(weekNumber).mp3")
        //**********************************************************************************
        //**********************************************************************************
        
        
        //let myURL = arrayOfSermonVideos[indexPath.row].imageURLString!
        
        
        let placeHolder = UIImage(named: "WhiteBack.png")
        let myURL = arrayOfSermonVideos[indexPath.row].imageURLString!
        let realURL = NSURL(string: myURL)
        cell.podcastImageView.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: .ProgressiveDownload)
        
        
        
        cell.layer.shadowOffset = CGSizeMake(10, 10)
        cell.layer.shadowColor = UIColor.blackColor().CGColor
        cell.layer.shadowRadius = 3
        cell.layer.shadowOpacity = 0.14
        
        cell.clipsToBounds = false
        
        let shadowFrame: CGRect = (cell.layer.bounds)
        let shadowPath: CGPathRef = UIBezierPath(rect: shadowFrame).CGPath
        cell.layer.shadowPath = shadowPath
        
                if indexPath.row == arrayOfSermonVideos.count - 1
                {
                    if arrayOfSermonVideos.count < 100
                    {
                    perPage = audioRlmItems.count + 15
                   // incrementer = incrementer + 1
                    loadMoreAutoRetrieve()
                    }
                }
        
        // print(aVid.tagForAudioRef!)
        
        return cell
    }
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        
        //let aVideoItem = mediaItems[indexPath.row] //as! BlogItem
        let aSermonItem = arrayOfSermonVideos[indexPath.row]
        
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("NowPlayingViewController") as! NowPlayingViewController
        navigationController?.pushViewController(detailVC, animated: true)
        detailVC.aSermon = aSermonItem
        //detailVC.categoryString = categoryButton.currentTitle!
        
        
    }

    
    
    @IBAction func listenNowTapped(sender: UIButton)
    {
        
        let contentView = sender.superview
        let cell = contentView?.superview as! ThirdCollectionViewCell
        let thisIndexPath = collectionView?.indexPathForCell(cell)
        let aSermon = arrayOfSermonVideos[thisIndexPath!.row]
        
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("NowPlayingViewController") as! NowPlayingViewController
        navigationController?.pushViewController(detailVC, animated: true)
        aSermon.isNowPlaying = true
        detailVC.aSermon = aSermon

        
        
    }
    
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "SubLogoSegue"
        {
            let navVC = segue.destinationViewController as! UINavigationController
            let menuTableViewController = navVC.viewControllers[0] as! MenuTableViewController
            navVC.transitioningDelegate = menuTransitionManager
            menuTransitionManager.delegate = self
        }
//        if segue.identifier == "GoToDownloadSegue2"
//        {
//            let dwnldVC = segue.destinationViewController as! DownloadsTableViewController
//            self.parentViewController?.presentViewController(dwnldVC, animated: true, completion: nil)
//           // navigationController?.presentViewController(dwnldVC, animated: true, completion: nil)
//            
//            //let presentStyle = UIModalPresentationStyle.OverFullScreen
//           // self.presentViewController(dwnldVC, animated: true, completion: nil)  // (() -> Void)?)
//            
//        }
//         if segue.identifier == "GoToNowPlayingSegue"
//        {
//            let destVC = segue.destinationViewController as! UINavigationController
//            let nowPlayingViewController = destVC.viewControllers[0] as! DownloadsTableViewController
//            navigationController?.showViewController(nowPlayingViewController, sender: sender)//  pushViewController(nowPlayingViewController, animated: true)
//            
////            let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DownloadsTableViewController") as! DownloadsTableViewController
////            navigationController?.pushViewController(detailVC, animated: true)
//
//
//            
//        }
        
    }
    
    
    
    
    @IBAction func downloadTapped(sender: UIButton)
    {
        
        
        let contentView = sender.superview
        let cell = contentView?.superview as! ThirdCollectionViewCell
        let thisIndexPath = collectionView?.indexPathForCell(cell)
        let aSermon = arrayOfSermonVideos[thisIndexPath!.row]
        let origSermon = audioRlmItems[thisIndexPath!.row]
        
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DownloadsTableViewController") as! DownloadsTableViewController
        navigationController?.pushViewController(detailVC, animated: true)
        //aSermon.isNowPlaying = true
        
        aSermon.isDownloading = !aSermon.isDownloading
        detailVC.aSermon = aSermon

        collectionView?.reloadItemsAtIndexPaths([thisIndexPath!])
        
        
//        if let audioUrl = NSURL(string: "https://s3.amazonaws.com/nacdvideo/\(aSermon.tagForAudioRef!).mp3")
//        {
//            
//            // then lets create your document folder url
//            let documentsDirectoryURL =  NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
//            
//            // lets create your destination file url
//            let destinationUrl = documentsDirectoryURL.URLByAppendingPathComponent(audioUrl.lastPathComponent ?? "audio.mp3")
//            print("This is the destURL-->> \(destinationUrl)")
//            
//            // to check if it exists before downloading it
//            if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
//                print("The file already exists at path")
//                
//                
//                // if the file doesn't exist
//            } else {
//                
//                // you can use NSURLSession.sharedSession to download the data asynchronously
//                NSURLSession.sharedSession().downloadTaskWithURL(audioUrl, completionHandler: { (location, response, error) -> Void in
//                    guard let location = location where error == nil else { return }
//                    do {
//                        // after downloading your file you need to move it to your destination url
//                        try NSFileManager().moveItemAtURL(location, toURL: destinationUrl)
//                        print("Finished downloading")
//                        
//                        aSermon.isDownloading = !aSermon.isDownloading
//                        aSermon.showingTheDownload = !aSermon.showingTheDownload
//                        
//                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                            
//                            self.collectionView?.reloadItemsAtIndexPaths([thisIndexPath!])
//                            self.updateRLMForDownload(origSermon)
//                            
//                            
//                        })
//                        
//                        
//                    } catch let error as NSError {
//                        let alertController1 = UIAlertController(title: "Sorry, there was a problem downloading \(aSermon.name!)", message: "Please try again.", preferredStyle: .Alert)
//                        // Add the actions
//                        alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
//                        alertController1.addAction(UIAlertAction(title: "Delete", style: .Default, handler: nil))
//                        // Present the controller
//                        self.presentViewController(alertController1, animated: true, completion: nil)
//
//                        print(error.localizedDescription)
//                    }
//                }).resume()
//               
//                
//                
//
//                
//
//            }
//        }
        
    }
    
    func updateRLMForDownload(origSermon: SermonAudioRlm)
    {
        try! audioRealm.write({
            origSermon.showingTheDownload = !origSermon.showingTheDownload
            audioRealm.add(origSermon, update: true)
            print("downloaded: \(origSermon.name)")
        })

        
    }
    
    
    
    
    @IBAction func deleteTapped(sender: UIButton)
    {
        let contentView = sender.superview
        let cell = contentView?.superview as! ThirdCollectionViewCell
        let thisIndexPath = collectionView?.indexPathForCell(cell)
        let aSermon = arrayOfSermonVideos[thisIndexPath!.row]
        //let origSermon = arrayOfSermonVideos[thisIndexPath!.row]
        
        if let audioUrl = NSURL(string: "https://s3.amazonaws.com/nacdvideo/\(aSermon.tagForAudioRef!).mp3")
        {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.URLByAppendingPathComponent(audioUrl.lastPathComponent ?? "audio.mp3")
            print("This is the destURL-->> \(destinationUrl)")
            
            // to check if it exists before deleting it
            if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
                print("The file already exists at path")
                
                 // Create the alert controller
                 let alertController1 = UIAlertController(title: "Are you sure you want to delete this sermon?", message: "\(aSermon.name!)", preferredStyle: .Alert)
                 // Add the actions
                 alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                 alertController1.addAction(UIAlertAction(title: "Delete", style: .Default, handler: nil))
                 // Present the controller
                 self.presentViewController(alertController1, animated: true, completion: nil)
                
                do
                {
                    
                    try NSFileManager().removeItemAtPath(destinationUrl.path!)
                    print("Audio deleted from disk")
                    
                    aSermon.showingTheDownload = !aSermon.showingTheDownload
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.collectionView?.reloadItemsAtIndexPaths([thisIndexPath!])
                        
                    })
                    /*
                    try! audioRealm.write({
                        aSermon.showingTheDownload = !aSermon.showingTheDownload
                        audioRealm.add(aSermon, update: true)
                    })
                    */

                    
                } catch let error1 as NSError {
                    let alertController1 = UIAlertController(title: "Sorry, there was a problem deleting \(aSermon.name!)", message: "Please try again.", preferredStyle: .Alert)
                    // Add the actions
                    alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                    alertController1.addAction(UIAlertAction(title: "Delete", style: .Default, handler: nil))
                    // Present the controller
                    self.presentViewController(alertController1, animated: true, completion: nil)
                    print(error1)
                }
            }
            else
            {
                // create the alert
                let alert = UIAlertController(title: "\(aSermon.name!)", message: "This sermon has not been downloaded", preferredStyle: .Alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                
                // show the alert
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            let origSermon = audioRlmItems[thisIndexPath!.row]
            
            try! audioRealm.write({
                origSermon.showingTheDownload = !origSermon.showingTheDownload
                audioRealm.add(origSermon, update: true)
            })

        }
        
        
    }
    
    
    @IBAction func playPauseTapped(sender: UIButton)
    {
        
       // isPlaying = !isPlaying
        let contentView = sender.superview
        let cell = contentView?.superview as! ThirdCollectionViewCell
        let thisIndexPath = collectionView?.indexPathForCell(cell)
        let aSermon = arrayOfSermonVideos[thisIndexPath!.row]
        //let origSermon = arrayOfSermonVideos[thisIndexPath!.row]
        let incomingButton: UIButton = sender
        
        let playImage = UIImage(named: "btn-play.png")
        let pauseImage = UIImage(named: "pause-button-new.png")

        arrayOfPlayButton.append(incomingButton)
        arrayOfIndexPaths.append(thisIndexPath!)
        arrayForUpdateVideos.append(aSermon)

        if arrayOfPlayButton.count > 1
        {
        
            if arrayOfPlayButton[0] == arrayOfPlayButton.last
            {
                arrayOfPlayButton.removeAll()
                arrayOfIndexPaths.removeAll()
                arrayForUpdateVideos.removeAll()
            }
            else
            {
                let changeButtonAtPath = arrayOfIndexPaths[0]
                arrayForUpdateVideos[0].isNowPlaying = !arrayForUpdateVideos[0].isNowPlaying
               // arrayOfPlayButton[0].setImage(playImage, forState: .Normal)
                self.collectionView?.reloadItemsAtIndexPaths([changeButtonAtPath])
                arrayOfPlayButton.removeAtIndex(0)
                arrayOfIndexPaths.removeAtIndex(0)
                arrayForUpdateVideos.removeAtIndex(0)
                
            }
        }
        
        
        //TODO: THIS WILL BREAK HERE!!!**********************FIXED!!
            aSermon.isNowPlaying = !aSermon.isNowPlaying
        
        
        
        
        
        
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
                
                //*********Sets up audio session to play in backGround********
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                    print("AVAudioSession Category Playback OK")
                    do {
                        try AVAudioSession.sharedInstance().setActive(true)
                        print("AVAudioSession is Active")
                    } catch let error as NSError {
                        let alertController1 = UIAlertController(title: "Sorry, could not start playback.", message: "Please try again.", preferredStyle: .Alert)
                        // Add the actions
                        alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                        alertController1.addAction(UIAlertAction(title: "Delete", style: .Default, handler: nil))
                        // Present the controller
                        self.presentViewController(alertController1, animated: true, completion: nil)

                        print(error.localizedDescription)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                //***********************************************************
                
                
                do {
//                    if audioPlayer.playing
//                    {
//                        audioPlayer.stop()
//                       // audioPlayer.prepareToPlay()
//                    }
                    audioPlayer =  try AVAudioPlayer(contentsOfURL: audioFileUrl)      //(contentsOf: audioFileUrl)
                    print("playing from disk")
                    
                } catch let error1 as NSError {
                    let alertController1 = UIAlertController(title: "Sorry, could not start playback.", message: "Please try again.", preferredStyle: .Alert)
                    // Add the actions
                    alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                    alertController1.addAction(UIAlertAction(title: "Delete", style: .Default, handler: nil))
                    // Present the controller
                    self.presentViewController(alertController1, animated: true, completion: nil)
                    print(error1)
                }
                
                
                if !aSermon.isNowPlaying
                {
                    audioPlayer.play()
                    sender.setImage(pauseImage, forState: .Normal)
                }
                else
                {
                    audioPlayer.stop()
                    sender.setImage(playImage, forState: .Normal)
                }
                
                // if the file doesn't exist
            }
            else
                
            {
               // player2.pause()
                
                
                let playerItem2 = AVPlayerItem(URL: NSURL(string: "https://s3.amazonaws.com/nacdvideo/\(aSermon.tagForAudioRef!).mp3")! )
                player2 = AVPlayer(playerItem: playerItem2)
                print("streaming audio")
                // player.volume = 1
                
                player2.rate = 1.0
                
                if aSermon.isNowPlaying
                {
                    player2.play()
                }
                else if !aSermon.isNowPlaying
                {
                    player2.pause()
                }
                
                if aSermon.isNowPlaying
                {
                    // streamPlayer.play()
                    //self.audioPlayer.play()
                    sender.setImage(pauseImage, forState: .Normal)
                }
                else
                {
                    //streamPlayer.pause()
                    //self.audioPlayer.stop()
                    sender.setImage(playImage, forState: .Normal)
                }
            }
            
            
        }
    }
    
    
}
// END OF CLASS  ***************

