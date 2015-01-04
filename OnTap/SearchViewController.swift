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

    @IBOutlet weak var sidebarButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var image = ""
    var id = ""
    var beersReturned:[[NSObject]] = []
    var name = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Beer Search"
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        var searchStr = searchBar.text
        var scopeIndex = searchBar.selectedScopeButtonIndex
        beersReturned.removeAll(keepCapacity: false)


        if searchStr != ""
        {
            switch scopeIndex
            {
                case 0:
                    BreweryDBapi().searchBeersByName(searchStr) {
                        (result: [[NSObject]]?) in
                        self.beersReturned = result!
                        self.tableView.reloadData()
                }
                case 1:
                    BreweryDBapi().searchBreweryByName(searchStr) {
                        (result: [[NSObject]]?) in
                        self.beersReturned = result!
                        self.tableView.reloadData()
                    }
                default:
                    break
            }
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func searchBarTextDidBeginEditing(searchBar: UISearchBar)
    {
        searchBar.showsScopeBar = true
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func searchBarTextDidEndEditing(searchBar: UISearchBar)
    {
        searchBar.showsScopeBar = false
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
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
                BreweryDBapi().getLabelImage(imageStr) {
                    (newImage: UIImage) in
                    var myImage = newImage
                    cell.imageView?.image = myImage
                }
            }
        }
        return cell
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 44
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.id = beersReturned[indexPath.row][1] as String
        self.name = beersReturned[indexPath.row][0] as String
        
        if searchBar.selectedScopeButtonIndex == 0
        {
            performSegueWithIdentifier("fromSearch", sender: self)
        }
        else
        {
            performSegueWithIdentifier("fromSearchToBrewery", sender: self)
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return beersReturned.count
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.row == tableView.indexPathsForVisibleRows()?.last?.row
        {
//            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "fromSearch"
        {
            var controller = segue.destinationViewController as CodeViewController
            controller.fromSearch = true
            controller.id = self.id
        }
        else if segue.identifier == "fromSearchToBrewery"
        {
            var controller = segue.destinationViewController as BreweryViewController
            controller.id = self.id
            controller.nameStr = self.name
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    @IBAction func sidebarButtonPressed(sender: AnyObject)
    {
        revealViewController().revealToggle(sender)
    }
    
}
