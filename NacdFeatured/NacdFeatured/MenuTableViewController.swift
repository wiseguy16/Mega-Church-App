//
//  MenuTableViewController.swift
//  NacdFeatured
//
//  Created by Gregory Weiss on 11/8/16.
//  Copyright © 2016 NorthlandChurch. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    var webCategories = [WebItem]()
    
    let webCat1 = WebItem()
    let webCat2 = WebItem()
    let webCat3 = WebItem()
    let webCat4 = WebItem()
    let webCat5 = WebItem()
    let webCat6 = WebItem()
    let webCat7 = WebItem()



    
//
//    var delegate: PickVideoCategory?
    
    
    //var menuItems = ["About", "Pray", "Need Help", "New To God", "Calendar", "Give", "This Section Is Still Under Construction"]
    var currentItem = "About"
    
    var aFeaturedItem: Featured!

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        loadWebCategories()
        
               
        
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
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        //return videoCategories.count
        return webCategories.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuTableViewCell", forIndexPath: indexPath) as! MenuTableViewCell
        
        // Configure the cell...
        let aCat = webCategories[indexPath.row]
//        cell.textLabel?.text = aCat.categoryName
        
        let attributedString = NSMutableAttributedString(string: aCat.linkTitle)
        let myLength = aCat.linkTitle.characters.count
        attributedString.addAttribute(NSKernAttributeName, value:   CGFloat(0.6), range: NSRange(location: 0, length: myLength))
        //cell.firstTitleLabel.text = aVid.name?.uppercaseString
        cell.menuLabel.attributedText = attributedString
        
        //cell.menuLabel.text = menuItems[indexPath.row]
       // cell.menuLabel.textColor = (menuItems[indexPath.row] == currentItem) ? UIColor.whiteColor() : UIColor.redColor()
        
        return cell
    }
    
    
//    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0.0
//    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let menuTableViewController = segue.sourceViewController as! MenuTableViewController
        if let selectedIndexPath = menuTableViewController.tableView.indexPathForSelectedRow
        {
            //currentItem = menuItems[selectedIndexPath.row]
            
           // let aFeaturedURL = Featured(myDictionary: [String : AnyObject])
          //  let vc = self.storyboard!.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
           // vc.aFeaturedItem = aFeaturedURL
          //  self.showViewController(vc, sender: vc)

        }
    }

    
    func loadWebCategories()
    {
        webCat1.linkTitle = "About"
        webCat1.linkURLString = "http://northlandchurch.net/about/"
        
        webCat2.linkTitle = "Pray"
        webCat2.linkURLString = "http://northlandchurch.net/pray/"

        webCat3.linkTitle = "Need Help"
        webCat3.linkURLString = "http://www.northlandchurch.net/need-help/"

        webCat4.linkTitle = "Serve"
        webCat4.linkURLString = "http://www.northlandchurch.net/serve/"

        webCat5.linkTitle = "Calendar"
        webCat5.linkURLString = "http://calendar.northlandchurch.net/"

        webCat6.linkTitle = "Give"
        webCat6.linkURLString = "https://giving.northlandchurch.net/"
        
        webCat7.linkTitle = "Distributed Church"
        webCat7.linkURLString = "http://distributedchurch.com/"

        
        /*
         http://distributedchurch.com/
         */


        
        webCategories = [webCat1, webCat2, webCat3, webCat4, webCat5, webCat6, webCat7]
        
        /*
         "About", "Pray", "Need Help", "New To God", "Calendar", "Give", "This Section Is Still Under Construction"
         */
        
    }
    
    
    
   
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let theIndex: Int = indexPath.row
        let theCategory = webCategories[indexPath.row]
        
       // delegate!.gotTheCategory(theCategory.albumIDNumber, categoryTitle: theCategory.categoryName)
       // dismissViewControllerAnimated(true, completion: nil)
        // DO DELEGATE STUFF HERE!!!
        print(theIndex)
        
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        vc.passThruWebString = theCategory.linkURLString  //"http://preview.northlandchurch.net/pray/"
        self.showViewController(vc, sender: vc)
    }
   
    
  
//    @IBAction func unwindToHome(segue: UIStoryboardSegue)
//    {
//        let sourceController = segue.sourceViewController as! MenuTableViewController
//        
//      //  self.title = sourceController.currentItem
//        
//    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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



class WebItem
{
    var linkTitle: String = ""
    var linkURLString: String = ""
    var indexForUse: Int = 0
}




