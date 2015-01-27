//
//  PlaceDetailController.swift
//  OnTap
//
//  Created by Nick Martinson on 1/23/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation

class PlaceDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    var placeDetails:Dictionary<String,String>?
    var keys:[String]?
    
    override func viewDidLoad()
    {
        keys = [String](placeDetails!.keys)
        navBar.title = placeDetails!["name"]

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:UITableViewCell?
        
        if( keys![indexPath.row] == "hours" && placeDetails!["hours"] != "")
        {
            cell = tableView.dequeueReusableCellWithIdentifier("hourCell") as HourTableViewCell
            (cell as HourTableViewCell).hoursLabel.text  = placeDetails![keys![indexPath.row]]
        }
        else
        {
            
            cell = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
            cell?.textLabel?.text = placeDetails![keys![indexPath.row]]!
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return placeDetails!.count
    }
    
    @IBAction func backButtonPressed(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
}