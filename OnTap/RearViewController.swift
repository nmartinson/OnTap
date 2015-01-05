//
//  RearViewController.swift
//  OnTap
//
//  Created by Nick Martinson on 1/2/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit

class RearViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, FBLoginViewDelegate
{
    @IBOutlet weak var facebookLogin:FBLoginView!
    
    var menuItems = ["On Tap", "breweryInfo", "login"]
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var item = menuItems[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier(item) as UITableViewCell
        return cell
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.cellForRowAtIndexPath(indexPath)?.highlighted = false
        tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        switch(indexPath.row)
        {
        case 1:
            breweryInfoSelected(tableView, index: indexPath)
        case 2:
            var i = 0
        case 3:
            var i = 9
        default:
            break
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return menuItems.count
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!)
    {
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func loginViewShowingLoggedInUser(loginView: FBLoginView!)
    {
        var friendsRequest = FBRequest.requestForMyFriends()
        friendsRequest.startWithCompletionHandler { (connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            var resultDict = result as NSDictionary
//            println("Result dic: \(resultDict)")
        }
    }

    /******************************************************************************************
    *
    ******************************************************************************************/
    func breweryInfoSelected(selectedTableView: UITableView, index: NSIndexPath)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        var infoToggle = defaults.boolForKey("breweryInfo")
        infoToggle = !infoToggle
        defaults.setBool(infoToggle, forKey: "breweryInfo")
        
        if infoToggle
        {
            selectedTableView.cellForRowAtIndexPath(index)?.textLabel?.text = "Show brewery info: Yes"
        }
        else
        {
            selectedTableView.cellForRowAtIndexPath(index)?.textLabel?.text = "Show brewery info: No"
        }
    }
    
    
}
