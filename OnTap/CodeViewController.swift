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

/******************************************************************************************
*  Extends Alamofire library to serialize the retrieval of images
******************************************************************************************/
extension Alamofire.Request
{
    class func imageResponseSerializer() -> Serializer{
        return { request, response, data in
            if( data == nil) {
                return (nil,nil)
            }
            let image = UIImage(data: data!, scale: UIScreen.mainScreen().scale)
            
            return (image, nil)
        }
    }
    
    func responseImage(completionHandler: (NSURLRequest, NSHTTPURLResponse?, UIImage?, NSError?) -> Void) -> Self{
        return response(serializer: Request.imageResponseSerializer(), completionHandler: { (request, response, image, error) in
            completionHandler(request, response, image as? UIImage, error)
        })
    }
}

class CodeViewController: UIViewController
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
    var codeStr:String = ""
    var nameStr:String = ""
    var inventoryItems = [Inventory]()
    
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
        var item = ""

        var url = "http://www.outpan.com/api/get-product.php?barcode=\(codeStr)&apikey=3a3657604cc7b7f103cfce13c9c01839"
        Alamofire.request(.GET, url, parameters: nil).responseJSON{ (_,_, data, _) -> Void in
            let json = JSON(data!)
            let name = json["name"].stringValue

            if(name == "")
            {
                println("NOT VALID")
                self.doSegue()
            }
            else
            {
                self.callBreweryDB(name)
            }
        }
        let (success, num, newItem) = fetchLog()
        onTapText.text = "On tap: \(num)"
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func callBreweryDB(name: String)
    {
        var item = name
        item = item.stringByReplacingOccurrencesOfString(" ", withString: "+").lowercaseString
        
        var brewURL = "http://api.brewerydb.com/v2/search?q=\(item)&type=beer&ids=1&key=dacc2d3e348d431bbe07adca89ac2113"
        Alamofire.request(.GET, brewURL, parameters: nil).responseJSON{ (_,_, data, _) -> Void in
//            println(data!)
            let json = JSON(data!)
            let description = json["data"][0]["description"].stringValue
            let styleDescription = json["data"][0]["style"]["description"].stringValue
            let name = json["data"][0]["name"].stringValue
            let abv = json["data"][0]["abv"].floatValue
            let ibu = json["data"][0]["ibu"].floatValue
            let image = json["data"][0]["labels"]["medium"].stringValue
            
            self.nameStr = name
            self.name.text = "Name: \(name)"
            self.abvText.text = "ABV: \(abv)%"
            self.ibuText.text = "IBU: \(ibu)"
            self.descriptionText.text = description
            self.styleDescriptionText.text = styleDescription
            
            Alamofire.request(.GET,image).responseImage({ (request, _, image, error) -> Void in
                if error == nil && image != nil{
                    self.labelImage.image = image
                }
            })
        }

    }
    
    /******************************************************************************************
    *   Gets called when the add button is pressed. It is used for adding or removing beers
    *   from the On Tap list
    ******************************************************************************************/
    @IBAction func addButton(sender: AnyObject)
    {
        addField.resignFirstResponder()

        var input = addField.text.toInt()!
        let (success, number, item) = fetchLog()
        if success
        {
            var num = addToTap(item!,oldAmount: number)
            onTapText.text = "On tap: \(num)"
        }
        else
        {
            var newItem = createInManagedObjectContext(self.managedObjectContext!, name: nameStr, amount: input, barcode: codeStr)
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
    func fetchLog() -> (Bool, Int, Inventory?)
    {
        let fetchRequest = NSFetchRequest(entityName: "Inventory")
        
        let sortDescriptor = NSSortDescriptor(key: "barcode", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "barcode == %@", codeStr)
        fetchRequest.predicate = predicate
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Inventory] {
            if fetchResults.count > 0
            {
                inventoryItems = fetchResults
                return (true, Int(inventoryItems[0].amount), inventoryItems[0])
            }
        }

        println("MO LOG")
        return (false, 0, nil)
        
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func addToTap(newItem: Inventory, oldAmount: Int) -> Int
    {
        newItem.name = nameStr
        newItem.barcode = codeStr
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
    
    
    func createInManagedObjectContext(moc: NSManagedObjectContext, name: String, amount: Int, barcode: String) -> Inventory {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Inventory", inManagedObjectContext: moc) as Inventory
        newItem.name = name
        newItem.amount = amount
        newItem.barcode = barcode
        
        var error: NSError? = nil
        if !self.managedObjectContext!.save(&error)
        {
            println("Error! \(error), \(error!.userInfo)")
            abort()
        }
        
        return newItem
    }
    
} 