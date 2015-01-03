//
//  SecondViewController.swift
//  OnTap
//
//  Created by Nick Martinson on 12/22/14.
//  Copyright (c) 2014 Nick Martinson. All rights reserved.
//
import Foundation
import CoreData
import UIKit
import Alamofire

class OnTapViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate
{
    var request: Alamofire.Request?
    var itemsOnTap = [String:[NSArray]]() //= [ "On Tap":, "Past Brews":  ]
    var onTap:[[NSObject]] = []
    var pastItems:[[NSObject]] = []
    var selectedCode = ""
    var tableSections = ["On Tap", "Past Brews"]
    var name = ""
    var id = ""
    var filteredBeers = [Inventory]()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sidebarButton: UIBarButtonItem!
    
    // Used for Core Data functionality
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
        }()
    
    override func viewDidLoad()
    {
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
        self.title = "On Tap"

        itemsOnTap.removeAll(keepCapacity: false)
        var (success, items) = fetchLog()
        
        if success
        {
            for(var i = 0; i < items?.count; i++)
            {
                if (items![i].amount as Int) > 0
                {
                    if let success = itemsOnTap["On Tap"]
                    {
                        itemsOnTap["On Tap"]!.append([items![i].name, items![i].amount, items![i].barcode, items![i].image, items![i].id])
                    }
                    else
                    {
                        itemsOnTap["On Tap"] = [[items![i].name, items![i].amount, items![i].barcode, items![i].image, items![i].id]]
                    }
                }
                else
                {
                    if let success = itemsOnTap["Past Brews"]
                    {
                        itemsOnTap["Past Brews"]!.append([items![i].name, items![i].amount, items![i].barcode, items![i].image, items![i].id])
                    }
                    else
                    {
                        itemsOnTap["Past Brews"] = [[items![i].name, items![i].amount, items![i].barcode, items![i].image, items![i].id]]
                    }
                }
            }
            
//            for(var i = 0; i < items?.count; i++)
//            {
//                Alamofire.request(.GET,items![i].image).responseImage({ (request, _, image, error) -> Void in
//                    if error == nil && image != nil{
//                        var item = self.itemsOnTap["On Tap"]
//                        item[i]
//                    }
//                })
//            }
            
            tableView.reloadData()
        }
    }
    

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func fetchLog() -> (Bool, [Inventory]?)
    {
        var inventoryItems = [Inventory]()
        let fetchRequest = NSFetchRequest(entityName: "Inventory")
        
        let sortDescriptor = NSSortDescriptor(key: "amount", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Inventory] {
            if fetchResults.count > 0
            {
                inventoryItems = fetchResults
                return (true, inventoryItems)
            }
        }
        return (false, nil)
    }

    /******************************************************************************************
    *
    ******************************************************************************************/
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var title = tableSections[section]
        if let sectionBeers = itemsOnTap[title]
        {
            return sectionBeers.count
        }
        return 0
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        var sectionTitle = tableSections[indexPath.section]
        var sectionBeer = itemsOnTap[sectionTitle]!
        var beer = sectionBeer[indexPath.row]
        var image = beer[3] as? String
        
        Alamofire.request(.GET,image!).responseImage({ (request, _, image, error) -> Void in
            if error == nil && image != nil{
                cell.imageView?.image = image
            }
        })
        
//        BreweryDBapi().getLabelImage(image!) {
//            (newImage: UIImage) in
//            var myImage = newImage
//            println(myImage)
//            cell.imageView?.image = myImage
//        }

        cell.textLabel?.text = beer[0] as? String
        cell.detailTextLabel?.text = beer[1] as? String
        
        return cell
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var sectionTitle = tableSections[indexPath.section]
        var sectionBeer = itemsOnTap[sectionTitle]!
        var beer = sectionBeer[indexPath.row]
        selectedCode = beer[2] as String
        name = beer[0] as String
        id = beer[4] as String
        
        self.performSegueWithIdentifier("onTapToDetail", sender: self)
    }

    /******************************************************************************************
    *
    ******************************************************************************************/
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return tableSections[section]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "onTapToDetail"
        {
            var controller = segue.destinationViewController as CodeViewController
            controller.codeStr = selectedCode
            controller.nameStr = name
            controller.id = self.id
            controller.fromOnTap = true
        }
    }
    
    func filterContentForSearchText(searchText: String)
    {
//        self.filteredBeers = self.itemsOnTap
    }
    
    @IBAction func sidebarButtonPressed(sender: AnyObject)
    {
        revealViewController().revealToggle(sender)
    }
    
    
}

