//
//  PickVideoTableViewController.swift
//  Northland News
//
//  Created by Greg Wise on 10/31/16.
//  Copyright © 2016 Northland Church. All rights reserved.
//

import UIKit
import SDWebImage

class PickVideoTableViewController: UITableViewController
{
    var videoCategories = [VideoCategory]()
    
    
    let vidCat1 = VideoCategory()
    let vidCat2 = VideoCategory()
    let vidCat3 = VideoCategory()
   // let vidCat4 = VideoCategory()
//    let vidCat5 = VideoCategory()
//    let vidCat6 = VideoCategory()
    var currentItem: String?
    
    
     var delegate: PickVideoCategory?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        loadVidCategories()
        
       
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
   
   
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return videoCategories.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoCategoryCell", forIndexPath: indexPath)

        // Configure the cell...
        let aCat = videoCategories[indexPath.row]
        cell.textLabel?.text = aCat.categoryName
       // cell.tintColor = UIColor.grayColor()
        if currentItem == aCat.categoryName + "▼"
        {
            cell.accessoryType = .Checkmark
        }
        else
        {
            cell.accessoryType = .None
        }
        

        return cell
    }
    
    func loadVidCategories()
    {
        vidCat1.categoryName = "Recent Services"
        vidCat1.albumIDNumber = "3730564"
        vidCat2.categoryName = "Sermon Only"
        vidCat2.albumIDNumber = "3446210"
        vidCat3.categoryName = "Worship Highlights"
        vidCat3.albumIDNumber = "3816976"
//        vidCat4.categoryName = "Personal Worship Time"
//        vidCat4.albumIDNumber = "3446209"


        
        /*
        vidCat2.categoryName = "Worship Highlights"
        vidCat2.albumIDNumber = "3816976"
        vidCat3.categoryName = "Worship Songs with Lyrics"
        vidCat3.albumIDNumber = "3446209"
        vidCat4.categoryName = "Instrumental Worship"
        vidCat4.albumIDNumber = "3742438"
        vidCat5.categoryName = "Sermons"
        vidCat5.albumIDNumber = "3446210"
        vidCat6.categoryName = "Worship In The Arts"
        vidCat6.albumIDNumber = "3590099"
        */
        videoCategories = [vidCat1, vidCat2, vidCat3] //, vidCat4, vidCat5, vidCat6]
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let theIndex: Int = indexPath.row
        let theCategory = videoCategories[indexPath.row]
        delegate!.gotTheCategory(theCategory.albumIDNumber, categoryTitle: theCategory.categoryName)
        
        if let selectedRow = tableView.indexPathForSelectedRow?.row {
            currentItem = theCategory.categoryName
        }
        //dismissViewControllerAnimated(true, completion: nil)

    }
    
        @IBAction func unwindToHome(segue: UIStoryboardSegue)
        {
            let sourceController = segue.sourceViewController as! FirstCollectionViewController
    
          //  self.title = sourceController.currentItem
    
        }

 


}



class VideoCategory
{
    var albumIDNumber: String = ""
    var categoryName: String = ""
}






