//
//  SearchResultsCollectionViewController.swift
//  Northland News
//
//  Created by Greg Wise on 10/26/16.
//  Copyright © 2016 Northland Church. All rights reserved.
//

import UIKit
import CoreMedia
import Foundation
import AVKit
import AVFoundation
import SDWebImage

private let reuseIdentifier = "SearchResultsCell"

class SearchResultsCollectionViewController: UICollectionViewController, APIControllerProtocol, UITextViewDelegate
{
    
    let loadingIndicator = UIActivityIndicatorView()
    
    var myFormatter = NSDateFormatter()
    
    var anApiController: APIController!
    
    var arrayOfSearchVideos = [Video]()
    var theseVideosString = ""
    
    var possibleTextView: UITextView?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        makeLoadActivityIndicator()
        
        
        
//        let memoryCapacity = 500 * 1024 * 1024
//        let diskCapacity = 500 * 1024 * 1024
//        let urlCache = NSURLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "myDiskPath")
//        NSURLCache.setSharedURLCache(urlCache)
        
        anApiController = APIController(delegate: self)
        
        NSKernAttributeName.capitalizedString
        
        myFormatter.dateStyle = .ShortStyle
        myFormatter.timeStyle = .NoStyle
        
        anApiController.getVideoSearchesDataFromVimeo(theseVideosString)
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
     //   refresher.endRefreshing()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
   
    
    func makeLoadActivityIndicator()
    {
        loadingIndicator.activityIndicatorViewStyle = .WhiteLarge
        loadingIndicator.color = UIColor.grayColor()
        loadingIndicator.frame = CGRect(x: self.view.frame.width / 2 - 75, y: self.view.frame.height / 2 - 75, width: 150, height: 150)
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        
    }



    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return arrayOfSearchVideos.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SearchResultsCell
    
        // Configure the cell
        let aVid = arrayOfSearchVideos[indexPath.row]
        cell.searchTitle.text = aVid.name
        cell.searchResultsBodyLabel.text = aVid.descript
        cell.searchBottomLabel.text = ""
        //cell.searchResultsBodyLabel.font = UIFont(name: "Roboto-LightItalic", size: 14)
        //cell.searchResultsBodyLabel.textColor = UIColor.grayColor()
        
        cell.searchImage.image = UIImage(named: "WhiteBack.png")
        
        
        let myURL = arrayOfSearchVideos[indexPath.row].imageURLString!
        
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: myURL)!, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error)
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let image = UIImage(data: data!)
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.removeFromSuperview()
                cell.searchImage.image = image
                
            })
            
        }).resume()
        
        
        /*
         cell.titleLabel.text = aPodcast.title
         cell.speakerLabel.text = aPodcast.speaker.uppercaseString
         cell.podcastImageView.image = UIImage(named: aPodcast.podcastImage)
         */
        
        cell.layer.shadowOffset = CGSizeMake(10, 10)
        cell.layer.shadowColor = UIColor.blackColor().CGColor
        cell.layer.shadowRadius = 3
        cell.layer.shadowOpacity = 0.14
        
        cell.clipsToBounds = false
        
        let shadowFrame: CGRect = (cell.layer.bounds)
        let shadowPath: CGPathRef = UIBezierPath(rect: shadowFrame).CGPath
        cell.layer.shadowPath = shadowPath
        
        
        //cell.searchBodyTextView.setContentOffset(CGPointZero, animated: false)
    
        return cell
    }
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        
        //let aVideoItem = mediaItems[indexPath.row] //as! BlogItem
        let aVideoItem = arrayOfSearchVideos[indexPath.row]
        
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("VideoDetailViewController") as! VideoDetailViewController
        navigationController?.pushViewController(detailVC, animated: true)
        //TODO: FIX this!! Conflict between Custom Video Class and Realm Object.  Pick one or the other!!
        detailVC.aVideo = aVideoItem
        
        
        //detailVC.categoryString = categoryButton.currentTitle!
        
        
    }

    
    
    
    func gotTheVideos(theVideos: [Video])
    {
        arrayOfSearchVideos = theVideos
        collectionView?.reloadData()
        
        // configureVideoStuff()
    }
    
    
    @IBAction func playVideoTapped(sender: UIButton)
    {
        let contentView = sender.superview
        let cell = contentView?.superview as! SearchResultsCell
        let thisIndexPath = collectionView?.indexPathForCell(cell)
        let aSermon = arrayOfSearchVideos[thisIndexPath!.row]
        // print("This cell")
        
        //  let playImage = UIImage(named: "podPlayIcon.png")
        //  let pauseImage = UIImage(named: "podPauseIcon.png")
        
        let videoURL = NSURL(string: aSermon.m3u8file!)
        
        let player = AVPlayer(URL: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.presentViewController(playerViewController, animated: true) {
            
            playerViewController.player?.play()
            
        }

        
        
    }

    


}
