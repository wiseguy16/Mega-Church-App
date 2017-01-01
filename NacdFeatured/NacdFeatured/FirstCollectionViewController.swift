//
//  FirstCollectionViewController.swift
//  NacdNews
//
//  Created by Gregory Weiss on 9/9/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import UIKit
import SDWebImage
import RealmSwift

protocol APIControllerProtocol
{
    func gotTheVideos(theVideos: [Video])
}

protocol PickVideoCategory {
    func gotTheCategory(anAlbum: String, categoryTitle: String)
}

private let reuseIdentifier = "FirstCollectionViewCell"

var videoIDAlbumNumber = "3730564"
//var videoIDAlbumNumber = "373056" // SHOULD CAUSE ERROR VIEW!!
let vimeoURLOpening = "/users/northlandchurch/albums/"
let vimeoURLSettings = "/videos?per_page=15"







class FirstCollectionViewController: UICollectionViewController, APIControllerProtocol, UISearchBarDelegate, PickVideoCategory, MenuTransitionManagerDelegate//, UIPopoverPresentationControllerDelegate  //, UITextFieldDelegate
{
    
    // LIVE STREAM:  http://WtIDGlE-lh.akamaihd.net/i/northlandlive_1@188060/master.m3u8?attributes=off
    
    
    let defaultsVideo = NSUserDefaults.standardUserDefaults()
    var todayCheck: NSDate?

    
    @IBOutlet weak var loadMoreButton: UIBarButtonItem!
    
    @IBOutlet weak var categoryButton: UIButton!
    
    var pickedVideoDelegate: PickVideoCategory?
    
    let menuTransitionManager = MenuTransitionManager()
    
    let loadingLabel = UILabel()
    let loadingIndicator = UIActivityIndicatorView()
    let smallLoader = UIActivityIndicatorView()
   // let videoSearchBar = UISearchBar()
    
    var searchBarActive:Bool = false
    var searchBarBoundsY:CGFloat?
    var searchBar:UISearchBar?
    
   // var unavailableBarBoundsY:CGFloat?
   // var unavailableBar2BoundsY:CGFloat?
    var unavailableSquare = UILabel()
    var unavailableSquare2 = UILabel()
    
   // var animateLabelStartXPosition = view.frame.width
    
//************************  REALM  *****************************
    let videoRealm = Realm.sharedInstance
    var videoRlmItems: Results<VideoServiceRlm>!
    var notificationToken: NotificationToken? = nil
    
    
//************************  REALM  *****************************

    
    var arrayOfVideos = [Video]()
    var mediaItems = [MediaItem]()
    var myFormatter = NSDateFormatter()
    var anApiController: APIController!
    var apiDataToQuery = vimeoURLOpening + videoIDAlbumNumber + vimeoURLSettings
    
    var theseVideosString = "/users/northlandchurch/albums/\(videoIDAlbumNumber)/videos?per_page=15"
    var incrementer = 1
    
    let refresher = UIRefreshControl()


    override func viewDidLoad()
    {
        super.viewDidLoad()
        todayCheck = NSDate()
        categoryButton.setTitle("Recent Services▼", forState: .Normal)
        
        //var animateLabelStartXPosition = -view.frame.width
        
        makeUnavailableLabel(unavailableSquare, unavailableBar2: unavailableSquare2)

        makeLoadActivityIndicator()
        refresher.addTarget(self, action: #selector(FirstCollectionViewController.reloadFromAPI), forControlEvents: .ValueChanged)
        collectionView?.addSubview(refresher)
        refresher.endRefreshing()


        
        
//        let memoryCapacity = 500 * 1024 * 1024
//        let diskCapacity = 500 * 1024 * 1024
//        let urlCache = NSURLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "myDiskPath")
//        NSURLCache.setSharedURLCache(urlCache)
        
        
        anApiController = APIController(delegate: self)
        
        myFormatter.dateStyle = .ShortStyle
        myFormatter.timeStyle = .NoStyle
        
        
        
        let config = Realm.Configuration()
        Realm.Configuration.defaultConfiguration = config
        
        
        
        let vidServiceRlm = videoRealm.objects(VideoServiceRlm.self)
        videoRlmItems = vidServiceRlm.sorted("sortOrder", ascending: true)
        
        if videoRlmItems.count > 0
        {
            for vidRlm in videoRlmItems
            {
               if let rVideo = Video.makeVideoFromRlmObjct(vidRlm)
               {
                 arrayOfVideos.append(rVideo)
               }
            }
            loadingIndicator.stopAnimating()
            if refresher.refreshing
            {
                stopRefresher()
            }
            anApiController.syncTheVideos(arrayOfVideos)

            collectionView?.reloadData()
            // getFromRealm()
            print("Already have Video items \(videoRlmItems.count)")
            
        }
        else
        {
            //makeUnavailableLabel(unavailableSquare, unavailableBar2: unavailableSquare2)
            //makeLoadActivityIndicator()
            
            anApiController.getVideoFullServicesDataFromVimeo(theseVideosString)
        }

        

        
       // anApiController.getVideoFullServicesDataFromVimeo(theseVideosString)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        
        
       // loadMediaItems()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresher.endRefreshing()
        
        let dateVideo_get = defaultsVideo.objectForKey("DateVideo") as? NSDate ?? todayCheck
        let result = Int(todayCheck!.timeIntervalSinceDate(dateVideo_get!))
        if result > 43200
        {
            makeLoadActivityIndicator()
            reloadFromAPI()
        }

        
       // self.collectionView?.alwaysBounceVertical = true
        //refresher.tintColor = UIColor.grayColor()
//        refresher.addTarget(self, action: #selector(FirstCollectionViewController.reloadFromAPI), forControlEvents: .ValueChanged)
//        collectionView?.addSubview(refresher)
        

        
        self.prepareUI()
        self.searchBar?.alpha = 0
        
    }
    

    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if arrayOfVideos.count > 0
        {
           // makeUnavailableLabel()
          //  print("Got stuff in the array")
            unavailableSquare.alpha = 0
            unavailableSquare2.alpha = 0
        }
        else
        {
            //makeUnavailableLabel()
            unavailableSquare.alpha = 0.5
            unavailableSquare2.alpha = 0.5
            
        }
        
        defaultsVideo.setObject(todayCheck, forKey: "DateVideo")
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if arrayOfVideos.count > 0 //|| videoRlmItems.count > 0
        {
            unavailableSquare.alpha = 0
            unavailableSquare2.alpha = 0
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        refresher.endRefreshing()
    }

    
    

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//************************  REALM  *****************************
    func getFromRealm()
    {
        do
        {
            // let featurRealm = try Realm()
            videoRlmItems = videoRealm.objects(VideoServiceRlm)
            print("Got Realm items maybe??")
        }
        catch
        {
            print("Didn't save in Realm")
        }
    }
//************************  REALM  *****************************
    

    
    func reloadFromAPI()
    {
        resetIncrementer()
        //code to execute during refresher
        
        if categoryButton.currentTitle == "Recent Services▼" && incrementer == 1 //&& !refresher.refreshing
        {
            var tempSorter = 1000
            try! videoRealm.write({
                for aRlmOnDisk in videoRlmItems
                {
                    aRlmOnDisk.sortOrder = tempSorter
                    tempSorter = tempSorter + 1
                    videoRealm.add(aRlmOnDisk, update: true)
                }
            })
            
            
            anApiController.purgeVideosFromArray()
            anApiController.getVideoFullServicesDataFromVimeo(theseVideosString)
            
            try! videoRealm.write({
                for aNewRlmOnDisk in videoRlmItems
                {
                    if aNewRlmOnDisk.sortOrder >= 1000
                    {
                        videoRealm.delete(aNewRlmOnDisk)
                    }
                }
            })
        }
        else
        {
            anApiController.purgeVideosFromArray()
            anApiController.getVideoFullServicesDataFromVimeo(theseVideosString)
        }

        
        
        
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
    
    func makeSmallLoadIndicator()
    {
        smallLoader.activityIndicatorViewStyle = .White
        smallLoader.color = UIColor.grayColor()
        smallLoader.frame = CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height * 0.80 + 20, width: 60, height: 60)
        smallLoader.startAnimating()
        view.addSubview(smallLoader)
        
    }

    
    
    func makeLoadActivityIndicator()
    {
        loadingIndicator.activityIndicatorViewStyle = .WhiteLarge
        loadingIndicator.color = UIColor.grayColor()
        loadingIndicator.frame = CGRect(x: self.view.frame.width / 2 - 75, y: self.view.frame.height / 2 - 75, width: 150, height: 150)
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        
    }
    
    func makeLabel()
    {
        loadingLabel.backgroundColor = UIColor.grayColor()
        loadingLabel.text = "Loading Videos"
        loadingLabel.font = UIFont(name: "FormaDJRText-Regular", size: 15)
        loadingLabel.textColor = UIColor.whiteColor()
        loadingLabel.frame = CGRect(x: self.view.frame.width / 2 - 50, y: self.view.frame.height / 2, width: 100, height: 30)
        view.addSubview(loadingLabel)
        
    }
    
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        let sourceController = segue.sourceViewController as! PickVideoTableViewController
        //self.title = sourceController.currentItem
    }
    
    func convertArrayToSharedRealmObjcts(arrayOfVideos2: [Video])
    {
        var sorter = 1
        try! videoRealm.write({
            
            for video in arrayOfVideos2
            {
                let aRlmVideoService = VideoServiceRlm()
                aRlmVideoService.id = video.convertToURINumber(video.uri!)
                aRlmVideoService.sortOrder = sorter
                
                aRlmVideoService.descript = video.descript
                aRlmVideoService.duration = video.duration
                aRlmVideoService.fileURLString = video.fileURLString
                aRlmVideoService.imageURLString = video.imageURLString
                aRlmVideoService.isDownloading = video.isDownloading
                aRlmVideoService.isNowPlaying = video.isNowPlaying
                aRlmVideoService.m3u8file = video.m3u8file
                aRlmVideoService.name = video.name
                aRlmVideoService.showingTheDownload = video.showingTheDownload
                aRlmVideoService.tagForAudioRef = video.tagForAudioRef
                aRlmVideoService.videoLink = video.videoLink
                aRlmVideoService.uri = video.uri
                aRlmVideoService.videoURL = video.videoURL
                
                sorter = sorter + 1
                videoRealm.add(aRlmVideoService, update: true)
            }
        })
        
    }


    
    
    
    func gotTheVideos(theVideos: [Video])
    {
        smallLoader.stopAnimating()
        arrayOfVideos = theVideos
        
        if categoryButton.currentTitle == "Recent Services▼" && incrementer == 1 //&& !refresher.refreshing
        {
          
            convertArrayToSharedRealmObjcts(arrayOfVideos)
            getFromRealm()
           
        }
 
        loadingIndicator.stopAnimating()
       // unavailableBar?.alpha = 0
        
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
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    


  
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        //return mediaItems.count
        
        return arrayOfVideos.count
        
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FirstCollectionViewCell
    
        // Configure the cell
       
        let aVid = arrayOfVideos[indexPath.row]
        
        var attributedString = NSMutableAttributedString(string: "")
        
       
        if categoryButton.currentTitle == "Recent Services▼" && !refresher.refreshing
        {
            let parseTitle = aVid.name?.componentsSeparatedByString("Worship Service ")
             attributedString = NSMutableAttributedString(string: parseTitle![1])
        }
        else if categoryButton.currentTitle == "Sermon Only▼" && !refresher.refreshing
        {
            let parseTitle = aVid.name?.stringByReplacingOccurrencesOfString("(Sermon)", withString: "")
            attributedString = NSMutableAttributedString(string: parseTitle!)
        }
        else
        {
            attributedString = NSMutableAttributedString(string: aVid.name!)
        }
        
        attributedString.addAttribute(NSKernAttributeName, value:   CGFloat(1.4), range: NSRange(location: 0, length: attributedString.length))
        cell.firstTitleLabel.attributedText = attributedString
 
        
        //cell.firstTitleLabel.text = aVid.name
       // cell.firstDescriptionLabel.attributedText = NSMutableAttributedString(string: "")
        
        if aVid.descript != nil
        {
        // ************************Something here crashed on worship songs w/ lyrics!!!*****
            
            /*
            let attributedString2 = NSMutableAttributedString(string: aVid.description!)
            attributedString2.addAttribute(NSKernAttributeName, value:   CGFloat(1.6), range: NSRange(location: 0, length: attributedString2.length))
            cell.firstDescriptionLabel.attributedText = attributedString2
            */
            
            cell.firstDescriptionLabel.text = aVid.descript
            
        }
        
         let placeHolder = UIImage(named: "WhiteBack.png")
         let myURL = arrayOfVideos[indexPath.row].imageURLString!
         let realURL = NSURL(string: myURL)
         
         cell.firstImageView.sd_setImageWithURL(realURL, placeholderImage: placeHolder, options: .ProgressiveDownload)
        
        cell.layer.shadowOffset = CGSizeMake(10, 10)
        cell.layer.shadowColor = UIColor.blackColor().CGColor
        cell.layer.shadowRadius = 3
        cell.layer.shadowOpacity = 0.14
        
        cell.clipsToBounds = false
        
        let shadowFrame: CGRect = (cell.layer.bounds)
        let shadowPath: CGPathRef = UIBezierPath(rect: shadowFrame).CGPath
        cell.layer.shadowPath = shadowPath
        
        if indexPath.row == arrayOfVideos.count - 1
        {
            incrementer = incrementer + 1
            loadMoreAutoRetrieve()
        }
        
        return cell
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return .None
    }
    
//    func checkTheNetwork()
//    {
//        if Reachability.isConnectedToNetwork() == true {
//            print("Internet connection OK")
//        } else {
//            let alertController1 = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet", preferredStyle: .Alert)
//            // Add the actions
//            alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
//            alertController1.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
//
//            print("Internet connection FAILED")
//            alertController1.show()
//            smallLoader.stopAnimating()
//
//
//        }
//    }
    
    func hasConnectivity() -> Bool
    {
        do {
            let reachability: Reachability = try Reachability.reachabilityForInternetConnection()
            let networkStatus: Int = reachability.currentReachabilityStatus.hashValue
            
            return (networkStatus != 0)
        }
        catch {
            
            // Handle error however you please
            return false
        }
    }
    
    func showConnectionError()
    {
        let alertController1 = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet", preferredStyle: .Alert)
        // Add the actions
        alertController1.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController1.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
        print("Internet connection FAILED")
        alertController1.show()
        smallLoader.stopAnimating()
 
    }

    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "PickCategorySegue"
        {
            if !hasConnectivity()
            {
               showConnectionError()
            }
            
           let pickVC = segue.destinationViewController as! PickVideoTableViewController
            pickVC.currentItem = categoryButton.currentTitle!
            pickVC.delegate = self
           pickVC.transitioningDelegate = menuTransitionManager
           menuTransitionManager.delegate = self
            
        }
        else if segue.identifier == "SubLogoSegue"
        {
            let navVC = segue.destinationViewController as! UINavigationController
            let menuTableViewController = navVC.viewControllers[0] as! MenuTableViewController
            navVC.transitioningDelegate = menuTransitionManager
            menuTransitionManager.delegate = self
        }
        
        
    }
  
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        
        //let aVideoItem = mediaItems[indexPath.row] //as! BlogItem
        let aVideoItem = arrayOfVideos[indexPath.row]
      
            let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("VideoDetailViewController") as! VideoDetailViewController
            navigationController?.pushViewController(detailVC, animated: true)
            detailVC.aVideo = aVideoItem
            detailVC.categoryString = categoryButton.currentTitle!
        
        
    }
    
    
    
    @IBAction func searchIconTapped(sender: UIBarButtonItem)
    {
        self.searchBar?.becomeFirstResponder()
        self.searchBar?.alpha = 1
    }
    

    
    func loadMoreAutoRetrieve()
    {
        makeSmallLoadIndicator()
        smallLoader.startAnimating()
       // incrementer = incrementer + 1
        switch videoIDAlbumNumber
        {
        case "3446209":
            theseVideosString = "/users/northlandchurch/albums/\(videoIDAlbumNumber)/videos?page=\(incrementer)&per_page=15&sort=alphabetical"
        case "3742438":
            theseVideosString = "/users/northlandchurch/albums/\(videoIDAlbumNumber)/videos?page=\(incrementer)&per_page=15&sort=alphabetical"
        default:
            theseVideosString = "/users/northlandchurch/albums/\(videoIDAlbumNumber)/videos?page=\(incrementer)&per_page=15"
        }

        anApiController.getVideoFullServicesDataFromVimeo(theseVideosString)
        //collectionView?.reloadData()
    }
    
    func resetIncrementer()
    {
        incrementer = 1
        switch videoIDAlbumNumber
        {
        case "3446209":
            theseVideosString = "/users/northlandchurch/albums/\(videoIDAlbumNumber)/videos?page=\(incrementer)&per_page=15&sort=alphabetical"
        case "3742438":
            theseVideosString = "/users/northlandchurch/albums/\(videoIDAlbumNumber)/videos?page=\(incrementer)&per_page=15&sort=alphabetical"
        default:
            theseVideosString = "/users/northlandchurch/albums/\(videoIDAlbumNumber)/videos?page=\(incrementer)&per_page=15"
        }

        
    }
    
    func searchVimeoForVideos(searchString: String)
    {
        theseVideosString = "/users/northlandchurch/albums/\(videoIDAlbumNumber)/videos?query=\(searchString)"
        anApiController.getVideoFullServicesDataFromVimeo(theseVideosString)
        collectionView?.reloadData()
    }
    
    func gotTheCategory(anAlbum: String, categoryTitle: String)
   {
    if videoIDAlbumNumber != anAlbum
        {
            videoIDAlbumNumber = anAlbum
            incrementer = 1
            switch videoIDAlbumNumber
                {
                case "3446209":
                    theseVideosString = "/users/northlandchurch/albums/\(videoIDAlbumNumber)/videos?page=\(incrementer)&per_page=15&sort=alphabetical"
                case "3742438":
                    theseVideosString = "/users/northlandchurch/albums/\(videoIDAlbumNumber)/videos?page=\(incrementer)&per_page=15&sort=alphabetical"
                default:
                    theseVideosString = "/users/northlandchurch/albums/\(videoIDAlbumNumber)/videos?page=\(incrementer)&per_page=15"
                }
            
            arrayOfVideos.removeAll()
            collectionView?.reloadData()
            
            makeLoadActivityIndicator()
            anApiController.purgeVideosFromArray()
            anApiController.getVideoFullServicesDataFromVimeo(theseVideosString)
            
            categoryButton.setTitle("\(categoryTitle)▼", forState: .Normal)
            
            
             //  collectionView?.setContentOffset(CGPointZero, animated: true)
            
        }
    
    //print("got a category \(anAlbum)")
    
    }
    
//    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
//        print("dismissed")
//    }
    
    
    // MARK: Search
    func filterContentForSearchText(searchText:String)
    {
       // self.dataSourceForSearchResult = self.dataSource?.filter({ (text:String) -> Bool in
       //     return text.containsString(searchText)
       // })
    }
    
//    func textFieldShouldReturn(textField: UITextField) -> Bool
//    {
//        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("SearchResultsCollectionViewController") as! SearchResultsCollectionViewController
//        navigationController?.pushViewController(detailVC, animated: true)
//        //detailVC.aVideo = aVideoItem
//        return true
//    }
    
// MARK: SEARCH BAR STUFF*********
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        // user did type something, check our datasource for text that looks the same
        if searchText.characters.count > 0
        {
            self.searchBarActive    = true

        } else {
            // if text length == 0
            // we will consider the searchbar is not active
            self.searchBarActive = false
         
        }
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self .cancelSearching()
        self.searchBar?.alpha = 0
       // self.collectionView?.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        let baseURL = "/users/northlandchurch/albums/\(videoIDAlbumNumber)/videos?query="
        var urlSearchString = ""
        
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("SearchResultsCollectionViewController") as! SearchResultsCollectionViewController
        navigationController?.pushViewController(detailVC, animated: true)
 
        
        if self.searchBar?.text!.characters.count > 0
        {
           let searchableString = self.searchBar!.text
            urlSearchString = searchableString!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        }

        
        detailVC.theseVideosString = baseURL + urlSearchString
        
        self.searchBarActive = false
        self.searchBar!.resignFirstResponder()
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        // we used here to set self.searchBarActive = YES
        // but we'll not do that any more... it made problems
        // it's better to set self.searchBarActive = YES when user typed something
        self.searchBar!.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        // this method is being called when search btn in the keyboard tapped
        // we set searchBarActive = NO
        // but no need to reloadCollectionView
        self.searchBarActive = false
        self.searchBar!.setShowsCancelButton(false, animated: false)
    }
    func cancelSearching(){
        self.searchBarActive = false
        self.searchBar!.resignFirstResponder()
        self.searchBar!.text = ""
        
    }
    
    // MARK: prepareVC
    func prepareUI()
    {
        self.addSearchBar()
        //self.addRefreshControl()
    }
    
    
    
    func addSearchBar()
    {
        if self.searchBar == nil
        {
            self.searchBarBoundsY = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height
            self.searchBar = UISearchBar()
            
            // self.searchBar = UISearchBar(frame: CGRectMake(0, self.searchBarBoundsY!, UIScreen.mainScreen().bounds.size.width, 44))
            searchBar!.frame = CGRect(x: 0, y: self.searchBarBoundsY! , width: view.frame.width, height: 35)
            self.searchBar!.searchBarStyle = .Default
            //self.searchBar?.alpha = 0.75
            self.searchBar!.tintColor = UIColor.grayColor()
            self.searchBar!.barTintColor = UIColor.whiteColor()
            
            self.searchBar!.delegate = self
            self.searchBar!.placeholder = "Search for videos..."
           // self.searchBar?.becomeFirstResponder()
            view.addSubview(searchBar!)
            
            // self.addObservers()
        }
        
        //        if !self.searchBar!.isDescendantOfView(self.view)
        //        {
        //            self.view.addSubview(self.searchBar!)
        //        }
    }
    
    
    
    
    func youTappedHere()
    {
        print("you tapped in Recent Services")
    }


    

}

extension UICollectionViewController
{
    
    func makeUnavailableLabel(unavailableBar: UILabel, unavailableBar2: UILabel)
    {

        let unavailableBarBoundsY = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height
        
        //unavailableBar = UILabel()
        
        unavailableBar.frame = CGRect(x: (view.frame.width / 2) - 140, y: unavailableBarBoundsY + 30 , width: 280, height: 280)
        unavailableBar.font = UIFont(name: "FormaDJRText-Bold", size: 16)
        unavailableBar.textColor = UIColor.whiteColor()
        unavailableBar.backgroundColor = UIColor.whiteColor()
        //dateBar!.backgroundColor = UIColor(red: 208/255.0, green: 198/255.0, blue: 181/255.0, alpha: 1)
        unavailableBar.numberOfLines = 2
        unavailableBar.textAlignment = .Center
        unavailableBar.alpha = 0.5
        // unavailableBar!.userInteractionEnabled = true
        // unavailableBar!.addGestureRecognizer(touchHere)
        
        unavailableBar.layer.shadowOffset = CGSizeMake(10, 10)
        unavailableBar.layer.shadowColor = UIColor.blackColor().CGColor
        unavailableBar.layer.shadowRadius = 3
        unavailableBar.layer.shadowOpacity = 0.14
        unavailableBar.clipsToBounds = false
        let shadowFrame: CGRect = (unavailableBar.layer.bounds)
        let shadowPath: CGPathRef = UIBezierPath(rect: shadowFrame).CGPath
        unavailableBar.layer.shadowPath = shadowPath
        
        let unavailableBar2BoundsY = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height
        
        //unavailableBar2 = UILabel()
        
        unavailableBar2.frame = CGRect(x: (view.frame.width / 2) - 140, y: unavailableBar2BoundsY + 340, width: 280, height: 280)
        unavailableBar2.font = UIFont(name: "FormaDJRText-Bold", size: 16)
        unavailableBar2.textColor = UIColor.whiteColor()
        unavailableBar2.backgroundColor = UIColor.whiteColor()
        //dateBar!.backgroundColor = UIColor(red: 208/255.0, green: 198/255.0, blue: 181/255.0, alpha: 1)
        unavailableBar2.numberOfLines = 2
        unavailableBar2.textAlignment = .Center
        unavailableBar2.alpha = 0.5
        // unavailableBar!.userInteractionEnabled = true
        // unavailableBar!.addGestureRecognizer(touchHere)
        
        unavailableBar2.layer.shadowOffset = CGSizeMake(10, 10)
        unavailableBar2.layer.shadowColor = UIColor.blackColor().CGColor
        unavailableBar2.layer.shadowRadius = 3
        unavailableBar2.layer.shadowOpacity = 0.14
        unavailableBar2.clipsToBounds = false
        let shadowFrame2: CGRect = (unavailableBar2.layer.bounds)
        let shadowPath2: CGPathRef = UIBezierPath(rect: shadowFrame2).CGPath
        unavailableBar.layer.shadowPath = shadowPath2
        
        
        view.addSubview(unavailableBar)
        view.addSubview(unavailableBar2)
        
        // unavailableBar?.addSubview(placeHolderView)
        //
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            unavailableBar.alpha = 1
            unavailableBar2.alpha = 1
            self.view.layoutIfNeeded()
            }, completion: nil)
        
    }
  
    
}
