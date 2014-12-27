//
//  CodeViewController.swift
//  OnTap
//
//  Created by Nick Martinson on 12/22/14.
//  Copyright (c) 2014 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CoreData


class CodeViewController: UIViewController, UIScrollViewDelegate
{
    var request: Alamofire.Request?
    @IBOutlet weak var labelImage: UIImageView!
    @IBOutlet weak var abvText: UITextView!
    @IBOutlet weak var ibuText: UITextView!
    @IBOutlet weak var onTapText: UITextView!
    @IBOutlet weak var addField: UITextField!
    @IBOutlet weak var name: UITextView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var styleDescriptionText: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    var codeStr:String = ""
    var nameStr:String = ""
    var inventoryItems = [Inventory]()
    var fromOnTap = false
    var fromSearch = false
    var image = ""
    var id = ""
    
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

    /******************************************************************************************
    *   Prevents the scrollview from horizontal scrolling
    ******************************************************************************************/
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        var item = ""
        image = ""
        
        if !fromOnTap && !fromSearch
        {
            println("not from ontap or search")
            var url = "http://www.outpan.com/api/get-product.php?barcode=\(codeStr)&apikey=3a3657604cc7b7f103cfce13c9c01839"
            Alamofire.request(.GET, url, parameters: nil).responseJSON{ (_,_, data, _) -> Void in
                let json = JSON(data!)
                let name = json["name"].stringValue
                
                if(name == "")
                {
                    self.doSegue()
                }
                else
                {
                    self.callBreweryDB(name)
                }
            }
        }
        else
        {
            searchByID(id)
            self.onTapText.text = "On tap: 0"
        }
        let (success, num, newItem) = fetchLog("id")
        onTapText.text = "On tap: \(num)"
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func searchByID(id: String)
    {
        var brewURL = "http://api.brewerydb.com/v2/beers?ids=\(id)&type=beer&p=1&key=dacc2d3e348d431bbe07adca89ac2113"
        Alamofire.request(.GET, brewURL, parameters: nil).responseJSON{ (_,_, data, _) -> Void in
            let json = JSON(data!)
            let totalResults = json["totalResults"].intValue
            
            if totalResults > 0
            {
                let description = json["data"][0]["description"].stringValue
                let styleDescription = json["data"][0]["style"]["description"].stringValue
                let abv = json["data"][0]["abv"].floatValue
                let ibu = json["data"][0]["ibu"].floatValue
                var name = json["data"][0]["name"].stringValue
                var imageStr = json["data"][0]["labels"]["medium"].stringValue
                if imageStr == ""
                {
                    imageStr = "http://www.brewerydb.com/img/glassware/pint_medium.png"
                }
                self.nameStr = name
                self.image = imageStr
                self.name.text = "Name: \(name)"
                self.abvText.text = "ABV: \(abv)%"
                self.ibuText.text = "IBU: \(ibu)"
                self.descriptionText.text = description
                self.styleDescriptionText.text = styleDescription
                
                Alamofire.request(.GET,imageStr).responseImage({ (request, _, image, error) -> Void in
                    if error == nil && image != nil{
                        self.labelImage.image = image
                    }
                })

            }
        }
        
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func callBreweryDB(name: String)
    {
        var item = name
        item = item.stringByReplacingOccurrencesOfString(" ", withString: "+").lowercaseString
        
        var brewURL = "http://api.brewerydb.com/v2/search?q=\(item)&type=beer&p=1&key=dacc2d3e348d431bbe07adca89ac2113"
        Alamofire.request(.GET, brewURL, parameters: nil).responseJSON{ (_,_, data, _) -> Void in
            println(data!)
            let json = JSON(data!)
            let description = json["data"][0]["description"].stringValue
            let styleDescription = json["data"][0]["style"]["description"].stringValue
            let name = json["data"][0]["name"].stringValue
            let abv = json["data"][0]["abv"].floatValue
            let ibu = json["data"][0]["ibu"].floatValue
            var imageStr = json["data"][0]["labels"]["medium"].stringValue
            var idStr = json["data"][0]["id"].stringValue
            println("ImageStr \(imageStr)")
            if imageStr == ""
            {
                imageStr = "http://www.brewerydb.com/img/glassware/pint_medium.png"
            }
            self.image = imageStr
            self.nameStr = name
            self.id = idStr
            self.name.text = "Name: \(name)"
            self.abvText.text = "ABV: \(abv)%"
            self.ibuText.text = "IBU: \(ibu)"
            self.descriptionText.text = description
            self.styleDescriptionText.text = styleDescription
            
            Alamofire.request(.GET,imageStr).responseImage({ (request, _, image, error) -> Void in
                if error == nil && image != nil{
                    self.labelImage.image = image
                }
            })
        }

    }

//    func setBeerLabels(data: NSDictionary)
//    {
//        self.nameStr = name
//        self.name.text = "Name: \(name)"
//        self.abvText.text = "ABV: \(abv)%"
//        self.ibuText.text = "IBU: \(ibu)"
//        self.descriptionText.text = description
//        self.styleDescriptionText.text = styleDescription
//
//    }
    
    /******************************************************************************************
    *   Gets called when the add button is pressed. It is used for adding or removing beers
    *   from the On Tap list
    ******************************************************************************************/
    @IBAction func addButton(sender: AnyObject)
    {
        addField.resignFirstResponder()

        var input = addField.text.toInt()!
        let (success, number, item) = fetchLog("barcode")
        if success
        {
            var num = addToTap(item!,oldAmount: number)
            onTapText.text = "On tap: \(num)"
        }
        else
        {
            var newItem = createInManagedObjectContext(self.managedObjectContext!, name: nameStr, amount: input, barcode: codeStr, id: id, image: image)
            onTapText.text = "On tap: \(newItem.amount.stringValue)"
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func checkOnTap() -> Bool
    {
        let fetchRequest = NSFetchRequest(entityName: "Inventory")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Inventory] {
            println("Count \(fetchResults.count)")
            if fetchResults.count > 0
            {
                var num = fetchResults[0].barcode
                return true
            }
        }
        return false
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func fetchLog(searchBy: String) -> (Bool, Int, Inventory?)
    {
        let fetchRequest = NSFetchRequest(entityName: "Inventory")
        let sortDescriptor = NSSortDescriptor(key: "barcode", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        switch(searchBy)
        {
            case "barcode":
                let predicate = NSPredicate(format: "barcode == %@", codeStr)
                fetchRequest.predicate = predicate
            case "id":
                let predicate = NSPredicate(format: "id == %@", id)
                fetchRequest.predicate = predicate
            default:
                return (false, 0, nil)
        }
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Inventory] {
            if fetchResults.count > 0
            {
                inventoryItems = fetchResults
                return (true, Int(inventoryItems[0].amount), inventoryItems[0])
            }
        }
        return (false, 0, nil)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func addToTap(newItem: Inventory, oldAmount: Int) -> Int
    {
        newItem.amount = oldAmount + addField.text.toInt()!
        
        var error: NSError? = nil
        if !self.managedObjectContext!.save(&error)
        {
            println("Error! \(error), \(error!.userInfo)")
            abort()
        }
        return Int(newItem.amount)
    }
    
    /******************************************************************************************
    *   Returns back to the previous view controller
    ******************************************************************************************/
    @IBAction func dismissDetails(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
    
    /******************************************************************************************
    *   Gets called immediately before performing segue. 
    *   Passes the barcode to the next AddBeerController
    ******************************************************************************************/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if( segue.identifier == "addBeerSegue")
        {
            var controller = segue.destinationViewController as AddBeerController
            controller.upc = codeStr
        }
    }
    
    /******************************************************************************************
    *   Performs the segue to AddBeerController
    ******************************************************************************************/
    func doSegue()
    {
        performSegueWithIdentifier("addBeerSegue", sender: self)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func presentItemInfo()
    {
        println("present Item")
        let fetchRequest = NSFetchRequest(entityName: "Inventory")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Inventory] {
            if(!fetchResults.isEmpty)
            {
//                println(fetchResults[0].name)
                println(fetchResults[0].amount)
                onTapText.text = "On Tap: \(fetchResults[0].amount)"
            }
        }
    }
    
    
    func createInManagedObjectContext(moc: NSManagedObjectContext, name: String, amount: Int, barcode: String, id: String, image: String) -> Inventory
    {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Inventory", inManagedObjectContext: moc) as Inventory
        newItem.name = name
        newItem.amount = amount
        newItem.barcode = barcode
        newItem.image = image
        newItem.id  = id
        
        var error: NSError? = nil
        if !self.managedObjectContext!.save(&error)
        {
            println("Error! \(error), \(error!.userInfo)")
            abort()
        }
        
        return newItem
    }
    
} 