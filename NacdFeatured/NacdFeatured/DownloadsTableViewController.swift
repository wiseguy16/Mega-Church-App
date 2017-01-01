//
//  DownloadsTableViewController.swift
//  NacdFeatured
//
//  Created by Gregory Weiss on 12/26/16.
//  Copyright © 2016 NorthlandChurch. All rights reserved.
//

import UIKit
import CoreMedia
import Foundation
import AVKit
import AVFoundation
import SDWebImage
import RealmSwift

class DownloadsTableViewController: UITableViewController
{
    let loadingIndicator = UIActivityIndicatorView()
    let refresher = UIRefreshControl()
    
    var timer = NSTimer()
    var timer2 = NSTimer()
    var slowValue: Float = 0.0
    
    var aSermon: Video?
    //var incomingSermon: Video?
    
    let downloadAudioRealm = Realm.sharedInstance
    var audioRlmItems: Results<SermonAudioRlm>!
    var notificationToken: NotificationToken? = nil
    var checkArrayAudioRlm = [Int]()
    
    var arrayOfSermonDownloads = [Video]()
    var arrayOfCurrentlyDownloading = [Video]()
    var arrayOfProgress = [UIProgressView]()
    
    @IBOutlet weak var downloadProgressView: UIProgressView!
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        //makeLoadActivityIndicator()
        
        let config = Realm.Configuration()
        Realm.Configuration.defaultConfiguration = config
        
        if let incomingSermon = aSermon
        {
            arrayOfCurrentlyDownloading.append(incomingSermon)
            startDownloadingFile(incomingSermon)
            
        }
        
        
        let audSermonRlm = downloadAudioRealm.objects(SermonAudioRlm.self).filter("showingTheDownload == true")
        audioRlmItems = audSermonRlm.sorted("tagForAudioRef", ascending: false)
        
        presentAsRealm()
        


//         Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false
//
//         Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentAsRealm()
    {
        print("presenting from tableview")
        if audioRlmItems.count > 0
        {
           arrayOfSermonDownloads.removeAll()
            for audRlm in audioRlmItems
            {
                if let rAudio = Video.makeAudioFromRlmObjct(audRlm)
                {
                    arrayOfSermonDownloads.append(rAudio)
                }
            }
            loadingIndicator.stopAnimating()
            if refresher.refreshing
            {
                stopRefresher()
            }
           // anApiController.syncTheSermons(arrayOfSermonVideos)
            
            tableView.reloadData()
            print("Already have items \(audioRlmItems.count)")
        }
        else
        {
            print("You have no downloads")
        }
    }
    
    func makeLoadActivityIndicator()
    {
        loadingIndicator.activityIndicatorViewStyle = .WhiteLarge
        loadingIndicator.color = UIColor.grayColor()
        loadingIndicator.frame = CGRect(x: self.view.frame.width / 2 - 75, y: self.view.frame.height / 2 - 75, width: 150, height: 150)
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        
    }
    
    func stopRefresher()
    {
        refresher.endRefreshing()
    }
    
    func convertAudioAndUpdateToSharedRealmObjcts(theAudio: Video)
    {
        var sorter = 1
        try! downloadAudioRealm.write({
            
            
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
                    aRlmAudio.showingTheDownload = !theAudio.showingTheDownload
                    aRlmAudio.tagForAudioRef = theAudio.tagForAudioRef
                    aRlmAudio.videoLink = theAudio.videoLink
                    aRlmAudio.uri = theAudio.uri
                    aRlmAudio.videoURL = theAudio.videoURL
                    sorter = sorter + 1
                    downloadAudioRealm.add(aRlmAudio, update: true)
            
            
        })
        
    }

    
    func startDownloadingFile(aSermon: Video)
    {
      print("starting download in tableView")
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
                self.tableView.reloadData()
                
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
                            
                            self.accelerateTimerForCompletion()
                            
                            //self.tableView.reloadItemsAtIndexPaths([thisIndexPath!])
                            self.convertAudioAndUpdateToSharedRealmObjcts(aSermon)
                            //self.updateRLMForDownload(aSermon)
                            self.arrayOfCurrentlyDownloading.removeAll()
                           self.presentAsRealm()
                            
                        })
                        
                        
                    } catch let error as NSError {
                        let alertController1 = UIAlertController(title: "Sorry, there was a problem downloading \(aSermon.name!)", message: "Please try again.", preferredStyle: .Alert)
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
    
    
    //MARK: Progress UI Updates - timers and functions
    
    func runProgress()
    {
        
    }
    
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
            slowValue = slowValue + 0.005
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
            //downloadCloudButton.alpha = 0
            timer2.invalidate()
            downloadProgressView.alpha = 0
            slowValue = 0
        }
        else
        {
            downloadProgressView.progress = slowValue
            slowValue = slowValue + 0.1
        }
        
        
    }

    
    func updateRLMForDownload(origSermon: SermonAudioRlm)
    {
        try! downloadAudioRealm.write({
            origSermon.showingTheDownload = !origSermon.showingTheDownload
            downloadAudioRealm.add(origSermon, update: true)
            print("downloaded: \(origSermon.name)")
        })
        
        
    }




    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0
        {
          return arrayOfCurrentlyDownloading.count
        }
        else
        {
        return arrayOfSermonDownloads.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if indexPath.section == 0 && arrayOfCurrentlyDownloading.count > 0
        {
            startFakeDownloadprogress()
            let cell = tableView.dequeueReusableCellWithIdentifier("InProgressTableViewCell", forIndexPath: indexPath) as! InProgressTableViewCell
            
            let aProgress = arrayOfCurrentlyDownloading[indexPath.row]
            let newtitle = aProgress.name?.stringByReplacingOccurrencesOfString("(Sermon)", withString: "")
            cell.inProgressTitle.text = "Downloading... " + newtitle!
           // cell.downloadSeriesLabel.text = aDownload.descript
            
            let placeHolder = UIImage(named: "WhiteBack.png")
            let myURL = arrayOfCurrentlyDownloading[indexPath.row].imageURLString!
            let realURL = NSURL(string: myURL)
            cell.inProgressImage.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: .ProgressiveDownload)
           

            
            return cell
        }
            
        else if indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("DefaultTableViewCell", forIndexPath: indexPath) as! DefaultTableViewCell
            //  DefaultTableViewCell
            return cell
        }
        else
        {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("DownloadsTableViewCell", forIndexPath: indexPath) as! DownloadsTableViewCell

        // Configure the cell...
        let aDownload = arrayOfSermonDownloads[indexPath.row]
        
        let newtitle = aDownload.name?.stringByReplacingOccurrencesOfString("(Sermon)", withString: "")
        cell.downloadTitleLabel.text = newtitle
        cell.downloadSeriesLabel.text = aDownload.descript
        
        let placeHolder = UIImage(named: "WhiteBack.png")
        let myURL = arrayOfSermonDownloads[indexPath.row].imageURLString!
        let realURL = NSURL(string: myURL)
        cell.downloadImageView.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: .ProgressiveDownload)
        
        

        return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let aSermonItem = arrayOfSermonDownloads[indexPath.row]
        
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("NowPlayingViewController") as! NowPlayingViewController
        navigationController?.popToRootViewControllerAnimated(true)
        navigationController?.pushViewController(detailVC, animated: true)
        aSermonItem.isNowPlaying = true
        detailVC.aSermon = aSermonItem
        //detailVC.categoryString = categoryButton.currentTitle!
    }
    
  
    

    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        let aDownload = arrayOfSermonDownloads[indexPath.row]
        if editingStyle == .Delete
        {
            arrayOfSermonDownloads.removeAtIndex(indexPath.row)
            convertAudioAndUpdateToSharedRealmObjcts(aDownload)
            
            if let audioUrl = NSURL(string: "https://s3.amazonaws.com/nacdvideo/\(aDownload.tagForAudioRef!).mp3")
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
                    let alertController1 = UIAlertController(title: "Are you sure you want to delete this sermon?", message: "\(aDownload.name!)", preferredStyle: .Alert)
                    // Add the actions
                    alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                    alertController1.addAction(UIAlertAction(title: "Delete", style: .Default, handler: nil))
                    // Present the controller
                    self.presentViewController(alertController1, animated: true, completion: nil)
                    
                    do
                    {
                        
                        try NSFileManager().removeItemAtPath(destinationUrl.path!)
                        print("Audio deleted from disk")
                        
                        //aSermon.showingTheDownload = !aSermon.showingTheDownload
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            //self.collectionView?.reloadItemsAtIndexPaths([thisIndexPath!])
                            
                        })
                        /*
                         try! audioRealm.write({
                         aSermon.showingTheDownload = !aSermon.showingTheDownload
                         audioRealm.add(aSermon, update: true)
                         })
                         */
                        
                        
                    } catch let error1 as NSError {
                        let alertController1 = UIAlertController(title: "Sorry, there was a problem deleting \(aDownload.name!)", message: "Please try again.", preferredStyle: .Alert)
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
                    let alert = UIAlertController(title: "\(aDownload.name!)", message: "This sermon has not been downloaded", preferredStyle: .Alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    
                    // show the alert
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
                
            }
            

            
            // Delete the row from the data source
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } //else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
       // }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
