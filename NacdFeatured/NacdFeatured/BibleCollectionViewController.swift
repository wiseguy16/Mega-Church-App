//
//  BibleCollectionViewController.swift
//  NacdNews
//
//  Created by Gregory Weiss on 10/11/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import UIKit
import RealmSwift


protocol BibleAPIControllerProtocol
{
    func gotTheBible(theLiturgy: [Liturgy])
}




private let reuseIdentifier = "BibleCell"

class BibleCollectionViewController: UICollectionViewController, MenuTransitionManagerDelegate, BibleAPIControllerProtocol
{
    let bibleURL = "http://www.northlandchurch.net/resources/liturgy/"
    
    let defaultsBible = NSUserDefaults.standardUserDefaults()
    var todayCheck: NSDate?

    
    var liturgyItems = [Liturgy]()
    var myFormatter = NSDateFormatter()
    
    let menuTransitionManager = MenuTransitionManager()
    var anApiController: BibleAPIController!

    @IBOutlet weak var bibleWebView: UIWebView!
    
    var dateBarBoundsY:CGFloat?
    var dateBar:UILabel?
    
    var unavailableSquare = UILabel()
    var unavailableSquare2 = UILabel()
    
    //************************  REALM  *****************************
    let liturgyRealm = Realm.sharedInstance
    var litRlmItems: Results<LiturgyRlm>!
    var notificationToken: NotificationToken? = nil
    
    
    //************************  REALM  *****************************
    

    
     let loadingIndicator = UIActivityIndicatorView()
    
    let refresher = UIRefreshControl()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        todayCheck = NSDate()

       
        myFormatter.dateFormat = "MMMM d"

        
        anApiController = BibleAPIController(delegate: self)
        
        let config = Realm.Configuration()
        Realm.Configuration.defaultConfiguration = config
        
        
        
        let litRlm = liturgyRealm.objects(LiturgyRlm.self)
        litRlmItems = litRlm.sorted("sortOrder", ascending: true)
        
        
         if litRlmItems.count > 0
         {
         // getFromRealm()
         print("Already have items \(litRlmItems.count)")
         }
         else
         {
         makeUnavailableLabel(unavailableSquare, unavailableBar2: unavailableSquare2)
         makeLoadActivityIndicator()
         
         anApiController.getLiturgyDataFromNACD()
         }

        
        

      //  anApiController.getLiturgyDataFromNACD()
        
        self.collectionView!.alwaysBounceVertical = true
        //        refresher.tintColor = UIColor.grayColor()
        refresher.addTarget(self, action: #selector(BibleCollectionViewController.reloadFromAPI), forControlEvents: .ValueChanged)
        collectionView!.addSubview(refresher)
        
        //makeUnavailableLabel(unavailableSquare, unavailableBar2: unavailableSquare2)
       // makeLoadActivityIndicator()
        print("ViewDidLoad for Liturgy")

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let dateBible_get = defaultsBible.objectForKey("DateBible") as? NSDate ?? todayCheck
        let result = Int(todayCheck!.timeIntervalSinceDate(dateBible_get!))
        if result > 43200
        {
            makeLoadActivityIndicator()
            reloadFromAPI()
        }

    }
    

    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        if liturgyItems.count > 0
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
        defaultsBible.setObject(todayCheck, forKey: "DateBible")

        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if liturgyItems.count > 0
        {
            unavailableSquare.alpha = 0
            unavailableSquare2.alpha = 0
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        refresher.endRefreshing()
    }


    
    func loadBiblePage()
    {
        let nacdURL = NSURL(string: bibleURL)
        let request = NSURLRequest(URL: nacdURL!)
        bibleWebView.loadRequest(request)
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
    
    //************************  REALM  *****************************
    func getFromRealm()
    {
        do
        {
            // let featurRealm = try Realm()
            litRlmItems = liturgyRealm.objects(LiturgyRlm)
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
        //code to execute during refresher
        let today = NSDate()
        let stringForToday = myFormatter.stringFromDate(today)

//        if let checkDate = litRlmItems[0].dateStamp
//        {
//            if checkDate == stringForToday
//            {
//                if refresher.refreshing
//                {
//                    stopRefresher()
//                }
//
//            }
//            else
//            {
                var tempSorter = 1000
                try! liturgyRealm.write({
                    for aRlmOnDisk in litRlmItems
                    {
                        aRlmOnDisk.sortOrder = tempSorter
                        tempSorter = tempSorter + 1
                        liturgyRealm.add(aRlmOnDisk, update: true)
                    }
                })
                
                
                anApiController.purgeLiturgy()
                anApiController.getLiturgyDataFromNACD()
                
                try! liturgyRealm.write({
                    for aNewRlmOnDisk in litRlmItems
                    {
                        if aNewRlmOnDisk.sortOrder >= 1000
                        {
                            liturgyRealm.delete(aNewRlmOnDisk)
                        }
                    }
                })

                
            //}
            
        //}
        
        
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
    
    func gotTheBible(theLiturgy: [Liturgy])
    {
        liturgyItems = theLiturgy
        let today = NSDate()
        let stringForToday = myFormatter.stringFromDate(today)

        
        var sorter = 1
        try! liturgyRealm.write({
            
            for lit in liturgyItems
            {
                let aRlmLit = LiturgyRlm()
                aRlmLit.id = lit.entry_id!
                aRlmLit.sortOrder = sorter
                
                aRlmLit.entry_date = lit.entry_date
                //aRlmLit.entryID = lit.entry_id
                aRlmLit.hasBeenRead = false
                aRlmLit.isExpanded = lit.isExpanded
                aRlmLit.scripture = lit.replaceBreakWithReturn(lit.scripture)
                aRlmLit.sequence = lit.sequence
                aRlmLit.title = lit.title
                aRlmLit.tranlation = lit.tranlation
                aRlmLit.urltitle = lit.urltitle
                aRlmLit.dateStamp = stringForToday
                
                sorter = sorter + 1
                liturgyRealm.add(aRlmLit, update: true)
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
        collectionView?.reloadData()
        
        // print("conforming to protocol")
    }
    

    
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue)
    {
        let sourceController = segue.sourceViewController as! MenuTableViewController
        //self.title = sourceController.currentItem
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
         }
     
     }



    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
       // return 4
        
        return litRlmItems.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! BibleCell
    
        // Configure the cell
        let aLit = litRlmItems[indexPath.row]
        
        let today = NSDate()
        let stringForToday = myFormatter.stringFromDate(today)
        cell.dateLabel.text = stringForToday
        
        let splitTitle = aLit.title!.componentsSeparatedByString(" ")
        cell.title1Label.text = splitTitle[0].uppercaseString
        cell.title2Label.text = splitTitle[1].uppercaseString
        if let theAuthor = aLit.tranlation
        {
          cell.authorLabel.text = theAuthor.uppercaseString
        }
        else
        {
           cell.authorLabel.text = ""
        }
        
        
        
        var tempText = ""
       
        var attributedBody  = NSMutableAttributedString(string: "")
        if let fullText = aLit.scripture
        {
            attributedBody = NSMutableAttributedString(string: fullText)
            tempText = fullText
        }
        
         //attributedBody  = NSMutableAttributedString(string: aLit.scripture)
        
        
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = 12 // Whatever line spacing you want in points
        // *** Apply attribute to string ***
        attributedBody.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedBody.length))

        
        let countLetters = tempText.characters.count
        if countLetters > 140
        {
            let partialText = tempText[tempText.startIndex...tempText.startIndex.advancedBy(140)]
            let attBody  = NSMutableAttributedString(string: partialText)
            // *** Create instance of `NSMutableParagraphStyle`
            let paragraphStyle = NSMutableParagraphStyle()
            // *** set LineSpacing property in points ***
            paragraphStyle.lineSpacing = 6 // Whatever line spacing you want in points
            // *** Apply attribute to string ***
            attBody.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attBody.length))
            let dotDotDot = NSMutableAttributedString(string: "...")
            attBody.appendAttributedString(dotDotDot)
            
            cell.actualBodyLabel.attributedText = attBody
        }
        else
        {
            cell.actualBodyLabel.attributedText = attributedBody
        }
        
        
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
    
    
    
    func makeDateLabel ()
    {
        self.dateBarBoundsY = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height
        self.dateBar = UILabel()
        
        // self.searchBar = UISearchBar(frame: CGRectMake(0, self.searchBarBoundsY!, UIScreen.mainScreen().bounds.size.width, 44))
        self.dateBar!.frame = CGRect(x: 0, y: self.dateBarBoundsY! , width: view.frame.width, height: 30)
        
        self.dateBar!.font = UIFont(name: "FormaDJRText-Bold", size: 17)
       // self.dateBar!.font = UIFont(name: "FormaDJRText-Bold", size: 15)
        
        self.dateBar!.textColor = UIColor.blackColor()
       // self.dateBar!.backgroundColor = UIColor(red: 208/255.0, green: 198/255.0, blue: 181/255.0, alpha: 1)
        self.dateBar!.textAlignment = .Center
        self.dateBar!.alpha = 0.9
        
       // self.dateBar!.shadowColor = UIColor.darkGrayColor()
        
        let today = NSDate()
        let stringForToday = myFormatter.stringFromDate(today)
        
        self.dateBar!.text = stringForToday
        view.addSubview(dateBar!)
        
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let aLit = litRlmItems[indexPath.row]
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("LiturgyDetailViewController") as! LiturgyDetailViewController
        navigationController?.pushViewController(detailVC, animated: true)
        detailVC.aLitItem = aLit

    }


  
}
