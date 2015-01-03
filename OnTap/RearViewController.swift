//
//  RearViewController.swift
//  OnTap
//
//  Created by Nick Martinson on 1/2/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit

class RearViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate
{
    var menuItems = ["On Tap", "breweryInfo", "login"]
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var item = menuItems[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier(item) as UITableViewCell
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        switch(indexPath.row)
        {
        case 1:
            tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text = "Show brewery info: Yes"
        case 2:
            var i = 0
        case 3:
            var i = 9
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return menuItems.count
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    }
}
