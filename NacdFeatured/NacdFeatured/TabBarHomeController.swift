//
//  TabBarHomeController.swift
//  NacdFeatured
//
//  Created by Greg Wise on 11/18/16.
//  Copyright © 2016 NorthlandChurch. All rights reserved.
//

import UIKit

class TabBarHomeController: UITabBarController
{
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tabBarController?.moreNavigationController.navigationBar.tintColor = UIColor.blackColor()
       // self.tabBarController?.moreNavigationController.navigationBar.window?.tintColor = UIColor.blackColor()
        //window?.tintColor = UIColor.blackColor()
        initializeTabs()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeTabs()
    {
        customizableViewControllers = nil
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
