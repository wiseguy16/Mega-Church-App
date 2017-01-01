//
//  FeaturedCollectionViewController.swift
//  NacdNews
//
//  Created by Gregory Weiss on 10/11/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import UIKit
import SDWebImage
import CoreMedia
import AVKit
import AVFoundation
import RealmSwift
//import ContentfulDeliveryAPI

protocol FeaturedAPIControllerProtocol
{
    func gotTheFeatured(theFeatured: [Featured])
}




private let reuseIdentifier = "FeaturedCell"

class FeaturedCollectionViewController: UICollectionViewController, FeaturedAPIControllerProtocol, MenuTransitionManagerDelegate, UICollectionViewDelegateFlowLayout
{
    let defaultsFeatured = NSUserDefaults.standardUserDefaults()
    var todayCheck: NSDate?

    var featuredItems = [Featured]()
    
    
//************************  REALM  *****************************
    let featuredRealm = Realm.sharedInstance
    var featuredRlmItems: Results<FeaturedRlm>!
    var notificationToken: NotificationToken? = nil

    
//************************  REALM  *****************************
    
    var myFormatter = NSDateFormatter()
    var anApiController: FeaturedAPIController!
    
    let loadingIndicator = UIActivityIndicatorView()
    
    let menuTransitionManager = MenuTransitionManager()
    
    var dateBarBoundsY:CGFloat?
    var dateBar = UILabel()
    
    var unavailableSquare = UILabel()
    var unavailableSquare2 = UILabel()

    let refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         todayCheck = NSDate()
        
        makeDateLabel()

        //TODO: Fix Live Service Label. one more try again
       // let featuredRealm = Realm.sharedInstance
        
      //  makeUnavailableLabel(unavailableSquare, unavailableBar2: unavailableSquare2)
      //  makeLoadActivityIndicator()
        
//        let memoryCapacity = 500 * 1024 * 1024
//        let diskCapacity = 500 * 1024 * 1024
//        let urlCache = NSURLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "myDiskPath")
//        NSURLCache.setSharedURLCache(urlCache)

        
        self.collectionView!.alwaysBounceVertical = true
        //refresher.tintColor = UIColor.grayColor()
        refresher.addTarget(self, action: #selector(FeaturedCollectionViewController.reloadFromAPI), forControlEvents: .ValueChanged)
        collectionView!.addSubview(refresher)
        refresher.endRefreshing()
        
        anApiController = FeaturedAPIController(delegate: self)
        
        let config = Realm.Configuration()
        Realm.Configuration.defaultConfiguration = config
        
        
        
        let ftrRlm = featuredRealm.objects(FeaturedRlm.self)
        featuredRlmItems = ftrRlm.sorted("sortOrder", ascending: true)
        /*
        if stampDate != NSDate()
        {
           reloadFromAPI()
        }
        */
        
        //self.collectionView!.contentOffset = CGPoint(x: 0, y: 8)


        if featuredRlmItems.count > 0
        {
           // getFromRealm()
           print("Already have Featured items \(featuredRlmItems.count)")
        }
        else
        {
            makeUnavailableLabel(unavailableSquare, unavailableBar2: unavailableSquare2)
            makeLoadActivityIndicator()

            anApiController.getFeaturedDataFromNACD()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        establishTheTime()
        
        let dateFeatured_get = defaultsFeatured.objectForKey("DateFeatured") as? NSDate ?? todayCheck
        let result = Int(todayCheck!.timeIntervalSinceDate(dateFeatured_get!))
        if result > 43200
        {
            makeLoadActivityIndicator()
            reloadFromAPI()
        }
        
            
        
        



        
    }
    
    override func viewDidAppear(animated: Bool)
    {
        
        if featuredItems.count > 0
        {
            unavailableSquare.alpha = 0
            unavailableSquare2.alpha = 0
        }
        else
        {
            unavailableSquare.alpha = 0
            unavailableSquare2.alpha = 0.5
        }
        
        defaultsFeatured.setObject(todayCheck, forKey: "DateFeatured")

        //*********Second Call to cet current Featured********
        
       // reloadFromAPI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        if featuredItems.count > 0
//        {
//            unavailableSquare.alpha = 0
//            unavailableSquare2.alpha = 0
//        }
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
    func getFromRealm()
    {
        do
        {
           // let featurRealm = try Realm()
            featuredRlmItems = featuredRealm.objects(FeaturedRlm)
            print("Got Realm items maybe??")
            print(featuredRlmItems.count)
            let aRLM = featuredRlmItems[0]
            print(aRLM.channel)
            print(aRLM.closingText)
            print(aRLM.mediaFileM3U8)
            print(aRLM.title)
            
            
        }
        catch
        {
            print("Didn't save in Realm")
        }
    }
//************************  REALM  *****************************

    
    func reloadFromAPI()
    {
        //code to execute during refresher
        
       // let ftrRlm = featuredRealm.objects(FeaturedRlm.self)
        
//        try! featuredRealm.write({
//            featuredRlmItems.enumerate().forEach { index, item in
//                let order = abs(index - 1000)
//                item.sortOrder = order
//            }
//        })
        var tempSorter = 1000
        try! featuredRealm.write({
            for aRlmOnDisk in featuredRlmItems
            {
                aRlmOnDisk.sortOrder = tempSorter
                tempSorter = tempSorter + 1
                featuredRealm.add(aRlmOnDisk, update: true)
            }
        })

        
        anApiController.purgeFeatured()
        anApiController.getFeaturedDataFromNACD()
        
        try! featuredRealm.write({
            for aNewRlmOnDisk in featuredRlmItems
            {
                if aNewRlmOnDisk.sortOrder >= 1000
                {
                    featuredRealm.delete(aNewRlmOnDisk)
                }
            }
        })

        
        //refresher.endRefreshing()
        //Call this to stop refresher
    }
    
    
    
    func stopRefresher()
    {
        refresher.endRefreshing()
    }

    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue)
    {
        let sourceController = segue.sourceViewController as! MenuTableViewController
        //self.title = sourceController.currentItem
    }
    
    
    func establishTheTime()
    {
        let today = NSDate()
        let calender = NSCalendar.currentCalendar()
        let components = calender.components([.Weekday, .Hour, .Minute], fromDate: today)
        let weekday = components.weekday
        let hour = components.hour
        let minute = components.minute
        let checkTime = (hour * 100) + minute
        switch weekday
        {
            case 7:
                if case 1645...1830 = checkTime
                {
                    updateLiveServiceBar()
                }
                else
                {
                    disableLiveServiceBar()
                }
            case 1:
                if case 845...1230 = checkTime
                {
                    updateLiveServiceBar()
                    print("live service")
                }
                else if case 1645...1830 = checkTime
                {
                    updateLiveServiceBar()
                }
                else
                {
                   disableLiveServiceBar()
                }
            case 2:
                if case 1845...2030 = checkTime
                {
                    updateLiveServiceBar()
                }
                else
                {
                    disableLiveServiceBar()
                }
            default:
                //self.dateBar = UILabel()
                    disableLiveServiceBar()
                print("not live")
        }
    }


    

    
    
    func makeLoadActivityIndicator()
    {
        loadingIndicator.activityIndicatorViewStyle = .WhiteLarge
        loadingIndicator.color = UIColor.grayColor()
        loadingIndicator.frame = CGRect(x: self.view.frame.width / 2 - 75, y: self.view.frame.height * 0.75, width: 150, height: 150)
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        
    }

    
    func gotTheFeatured(theFeatured: [Featured])
    {
        featuredItems = theFeatured
        
        var sorter = 1
        try! featuredRealm.write({
            
        for aFeatured in featuredItems
            {
                let aRlmFeatured = FeaturedRlm()
                aRlmFeatured.sortOrder = sorter
                aRlmFeatured.id = aFeatured.entry_id!
                aRlmFeatured.body = aFeatured.replaceBreakWithReturn(aFeatured.body!)
                aRlmFeatured.channel = aFeatured.channel
                aRlmFeatured.closingText = aFeatured.closingText
                aRlmFeatured.entry_date = aFeatured.entry_date
                aRlmFeatured.image = aFeatured.image
                aRlmFeatured.mediaFileM3U8 = aFeatured.mediaFileM3U8
                aRlmFeatured.title = aFeatured.title?.stringByDecodingXMLEntities()
                aRlmFeatured.urltitle = aFeatured.urltitle
                aRlmFeatured.webURL = aFeatured.webURL
                    
                sorter = sorter + 1
                featuredRealm.add(aRlmFeatured, update: true)
            }
        })
        
        
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
        
        //*************  REALM CALL  ****************
        getFromRealm()
        
        //*************  REALM CALL  ****************
        
        collectionView?.reloadData()
        
       // print("conforming to protocol")
    }

    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
         if segue.identifier == "SubLogoSegue"
        {
            let navVC = segue.destinationViewController as! UINavigationController
            let menuTableViewController = navVC.viewControllers[0] as! MenuTableViewController
            navVC.transitioningDelegate = menuTransitionManager
            menuTransitionManager.delegate = self

            //let menuTableViewController = segue.destinationViewController as! MenuTableViewController
           // menuTableViewController.currentItem = self.title!
           // menuTableViewController.transitioningDelegate = menuTransitionManager
        }

    }

    
    @IBAction func webButtonTapped(sender: UIButton)
    {
        
        let contentView = sender.superview
        let cell = contentView!.superview as! FeaturedCollectionViewCell           //sender?.superview as! FeaturedCollectionViewCell
        let thisIndexPath = collectionView?.indexPathForCell(cell)
        let aFeaturedURL = featuredItems[thisIndexPath!.row]
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        vc.aFeaturedItem = aFeaturedURL
        self.showViewController(vc, sender: vc)
        
    }
    
    
 

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 2
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if section == 0
        {
            return 1
        }
        else
        {
            return featuredRlmItems.count
        }
    }
    
    
    // MARK: - UICollectionViewFlowLayout
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let picDimension = self.view.frame.size.width / 4.0
//        return CGSize(width: picDimension, height: picDimension)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        let leftRightInset = self.view.frame.size.width / 14.0
//        return UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset)
//    }


    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        let width : CGFloat
        let height : CGFloat
        
        if indexPath.section == 0
        {
            // First section
            width = collectionView.frame.width
            height = 320
            return CGSizeMake(width, height)
        }
        else
        {
            // Second section
           // width = collectionView.frame.width/3
            width = 280
            height = 280
            return CGSizeMake(width, height)
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        if indexPath.section == 0
        {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("WelcomeCell", forIndexPath: indexPath) as! WelcomeCollectionViewCell
            return cell
        }
        else
        {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FeaturedCollectionViewCell
    
        
        let aFeaturedThing = featuredRlmItems[indexPath.row]
        // Configure the cell
        
         let convertedTitle = aFeaturedThing.title?.stringByDecodingXMLEntities()
         //let myLength = aFeaturedThing.title!.characters.count
         let attributedString = NSMutableAttributedString(string: convertedTitle!)
         attributedString.addAttribute(NSKernAttributeName, value: CGFloat(1.4), range: NSRange(location: 0, length: attributedString.length))
         
         cell.featuredTitleLabel.attributedText = attributedString
        
        cell.featuredPlayButton.alpha = 0
        if aFeaturedThing.channel! == "Media"
        {
            cell.featuredPlayButton.alpha = 1.0
            cell.tabBarButton.setTitle("Browse Videos", forState: .Normal)
            cell.tabBarButton.contentHorizontalAlignment = .Left
        }
        else
        {
            cell.tabBarButton.setTitle("Browse Articles", forState: .Normal)
            cell.tabBarButton.contentHorizontalAlignment = .Left
        }
        
        
        //cell.featuredTitleLabel.text = aFeaturedThing.title
        //cell.featuredDetailsLabel.text = aFeaturedThing.channel?.uppercaseString
        cell.featuredDetailsLabel.text = aFeaturedThing.closingText?.uppercaseString
        
       
        //cell.featuredImageView.image = UIImage(named: "WhiteBack.png")
        // cell.featuredButton.setTitle(aFeaturedThing.webURL, forState: .Normal)
        
        let placeHolder = UIImage(named: "WhiteBack.png")
       
        let myURL = featuredRlmItems[indexPath.row].image!
        //print(myURL)
        let realURL = NSURL(string: myURL)
        
        cell.featuredImageView.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: .ProgressiveDownload)
//        cell.featuredImageView.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: .ProgressiveDownload) { (UIImage!, NSError!, SDImageCacheType, NSURL!) in
//            code



        cell.layer.shadowOffset = CGSizeMake(10, 10)
        cell.layer.shadowColor = UIColor.blackColor().CGColor
        cell.layer.shadowRadius = 3
        cell.layer.shadowOpacity = 0.14
        
        cell.clipsToBounds = false
        
        let shadowFrame: CGRect = (cell.layer.bounds)
        let shadowPath: CGPathRef = UIBezierPath(rect: shadowFrame).CGPath
        cell.layer.shadowPath = shadowPath
        
        
        return cell
        }
    }
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        
        let thisFeaturedItem = featuredRlmItems[indexPath.row] //as! Featured Item
        
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("FeaturedDetailViewController") as! FeaturedDetailViewController
        navigationController?.pushViewController(detailVC, animated: true)
        detailVC.aFeaturedItem = thisFeaturedItem
        
        
    }
    
    @IBAction func findMoreTapped(sender: UIButton)
    {
        let contentView = sender.superview
        let cell = contentView!.superview as! FeaturedCollectionViewCell           //sender?.superview as! FeaturedCollectionViewCell
        let thisIndexPath = collectionView?.indexPathForCell(cell)
        let aFeaturedThing = featuredRlmItems[thisIndexPath!.row]
        if aFeaturedThing.channel! == "Media"
        {
            if let myTabBarController = view.window!.rootViewController as? UITabBarController
            {
                myTabBarController.selectedIndex = 1
            }
        }
        else
        {
            if let myTabBarController = view.window!.rootViewController as? UITabBarController
            {
                myTabBarController.selectedIndex = 5
            }

            
        }

        
        
    }
    
    func makeDateLabel ()
    {
        self.dateBarBoundsY = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height
        let touchHere = UITapGestureRecognizer(target: self, action: #selector(gotoLiveService))
        
        /*
         let tapGesture = UITapGestureRecognizer(target: self, action: "gotoLiveService:")
         }
         
         func klikPlay(sender:UITapGestureRecognizer){
         // ...
         }
         */
        
        //self.dateBar = UILabel()
        
        // self.searchBar = UISearchBar(frame: CGRectMake(0, self.searchBarBoundsY!, UIScreen.mainScreen().bounds.size.width, 44))
        dateBar.frame = CGRect(x: 0, y: self.dateBarBoundsY! - 2 , width: view.frame.width, height: 45)
        
        dateBar.font = UIFont(name: "FormaDJRText-Bold", size: 16)
        // self.dateBar!.font = UIFont(name: "FormaDJRText-Bold", size: 15)
        
        dateBar.textColor = UIColor.whiteColor()
        dateBar.backgroundColor = UIColor.redColor()
        //dateBar!.backgroundColor = UIColor(red: 208/255.0, green: 198/255.0, blue: 181/255.0, alpha: 1)
        dateBar.numberOfLines = 2
        dateBar.textAlignment = .Center
        dateBar.alpha = 0.0
        dateBar.userInteractionEnabled = false
        dateBar.addGestureRecognizer(touchHere)
        //dateBar!.
        
        // self.dateBar!.shadowColor = UIColor.darkGrayColor()
        
        
        dateBar.text = "LIVE SERVICE IN PROGRESS. \nCLICK TO WATCH NOW."
        view.addSubview(dateBar)
        
    }
    
    func updateLiveServiceBar()
    {
        dateBar.alpha = 0.9
        dateBar.userInteractionEnabled = true
        
    }
    
    func disableLiveServiceBar()
    {
        dateBar.alpha = 0.0
        dateBar.userInteractionEnabled = false

        
    }
    
    func gotoLiveService ()
    {
        print("GOING TO LIVE")
        let videoURL = NSURL(string: "http://WtIDGlE-lh.akamaihd.net/i/northlandlive_1@188060/master.m3u8?attributes=off")
        let player = AVPlayer(URL: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.presentViewController(playerViewController, animated: true) {
            
            playerViewController.player?.play()
            
        }

        
    }

    

}
