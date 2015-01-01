//
//  SearchViewController.swift
//  OnTap
//
//  Created by Nick Martinson on 12/26/14.
//  Copyright (c) 2014 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate
{

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var image = ""
    var id = ""
    var beersReturned:[[NSObject]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Beer Search"
    }
    /******************************************************************************************
    *
    ******************************************************************************************/
    func callBreweryDB(name: String)
    {
        beersReturned.removeAll(keepCapacity: false)
        var item = name
        item = item.stringByReplacingOccurrencesOfString(" ", withString: "+").lowercaseString
        
        var brewURL = "http://api.brewerydb.com/v2/search?q=\(item)&type=beer&p=1&key=dacc2d3e348d431bbe07adca89ac2113"
        Alamofire.request(.GET, brewURL, parameters: nil).responseJSON{ (_,_, data, _) -> Void in
            let json = JSON(data!)
            let totalResults = json["totalResults"].intValue
//            let description = json["data"][0]["description"].stringValue
//            let styleDescription = json["data"][0]["style"]["description"].stringValue
//            let abv = json["data"][0]["abv"].floatValue
//            let ibu = json["data"][0]["ibu"].floatValue
            for(var i = 0; i < totalResults; i++)
            {
                let name = json["data"][i]["name"].stringValue
                var id = json["data"][i]["id"].stringValue
                var image = json["data"][i]["labels"]["medium"].stringValue
                if id != ""
                {
                    if image == ""
                    {
                        image = "http://www.brewerydb.com/img/glassware/pint_medium.png"
                    }
                    self.beersReturned.append([name, id, image])
                }
            }
            self.tableView.reloadData()
        }
        
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        var searchStr = searchBar.text
        if searchStr != ""
        {
            callBreweryDB(searchStr)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        if beersReturned.count > 0
        {
            var name = beersReturned[indexPath.row][0] as String
            var imageStr = beersReturned[indexPath.row][2] as String
            cell.textLabel?.text = name
            if imageStr != ""
            {
                Alamofire.request(.GET,imageStr).responseImage({ (request, _, image, error) -> Void in
                    if error == nil{
                        cell.imageView?.image = image
                    }
                })
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.id = beersReturned[indexPath.row][1] as String
        performSegueWithIdentifier("fromSearch", sender: self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return beersReturned.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "fromSearch"
        {
            var navController = segue.destinationViewController as UINavigationController
            var codeController = navController.viewControllers.first as CodeViewController
            codeController.fromSearch = true
            codeController.id = self.id
            
            
//            var controller = segue.destinationViewController as CodeViewController
//            controller.fromSearch = true
//            controller.id = self.id
        }
    }
}
