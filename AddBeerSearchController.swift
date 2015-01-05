//
//  AddBeerSearchController.swift
//  OnTap
//
//  Created by Nick Martinson on 1/5/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

class AddBeerSearchController: SearchViewController
{
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    var upc = ""
    
    override func viewWillAppear(animated: Bool)
    {
        self.title = "Beer Search"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.id = beersReturned[indexPath.row][1] as String
        self.name = beersReturned[indexPath.row][0] as String
        
        openModalPrompt()
        tableView.cellForRowAtIndexPath(indexPath)?.selected = false
    }
    
//    /******************************************************************************************
//    *
//    ******************************************************************************************/
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
//    {
//        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
//        
//        if beersReturned.count > 0
//        {
//            let name = beersReturned[indexPath.row][0] as String
//            let imageStr = beersReturned[indexPath.row][2] as String
//            let breweryName = beersReturned[indexPath.row][3] as String
//            cell.textLabel?.text = name
//            cell.detailTextLabel?.text = breweryName
//            if imageStr != ""
//            {
//                BreweryDBapi().getLabelImage(imageStr) {
//                    (newImage: UIImage) in
//                    var myImage = newImage
//                    cell.imageView?.image = myImage
//                }
//            }
//        }
//        return cell
//    }

    
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func openModalPrompt()
    {
        let alertController = UIAlertController(title: "Tag Beer", message: "Is this the beer you want?", preferredStyle: .Alert)
        let noAction = UIAlertAction(title: "No", style: .Cancel){ void in
            
        }
        let yesAction = UIAlertAction(title: "Yes", style: .Destructive){ void in
            self.tagBeer()
        }
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        self.presentViewController(alertController, animated: true){
            
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "cancelAddBeer"
        {
            
        }
    }
    
    func tagBeer()
    {
        var newBarcode = PFObject(className: "Beer")
        newBarcode.setObject(id, forKey: "beerID")
        newBarcode.setObject(upc, forKey: "barcode")
        newBarcode.saveInBackgroundWithBlock{
            (success: Bool, error: NSError!) -> Void in
            self.dismissViewControllerAnimated(true, completion: { () -> Void in })
        }
    }
    
}