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


class CodeViewController: UIViewController
{
    @IBOutlet weak var labelImage: UIImageView!
    @IBOutlet weak var abvText: UITextView!
    @IBOutlet weak var ibuText: UITextView!
    @IBOutlet weak var onTapText: UITextView!
    @IBOutlet weak var addField: UITextField!
    @IBOutlet weak var name: UITextView!
    var codeStr:String = ""
    var nameStr:String = ""
    
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
        println(codeStr)
        var url = "http://api.upcdatabase.org/json/ae64c921a1f7fac054b7af59091d12a9/\(codeStr)"
        Alamofire.request(.GET, url, parameters: nil).responseJSON{ (_,_, data, _) -> Void in
//            println(data!)
            let json = JSON(data!)
            if(json["valid"].stringValue == "false")
            {
                println("NOT VALID")
                self.doSegue()
            }
            else
            {
                let json = JSON(data!)
                let description = json["itemname"].stringValue
                println("Item \(description)")
                item = description
                item = item.stringByReplacingOccurrencesOfString(" ", withString: "_").lowercaseString
            
                var brewURL = "http://api.brewerydb.com/v2/search?q=\(item)&type=beer&key=dacc2d3e348d431bbe07adca89ac2113"
                Alamofire.request(.GET, brewURL, parameters: nil).responseJSON{ (_,_, data, _) -> Void in
    //                println(data)
                    let json = JSON(data!)
                    let description = json["data"][0]["style"]["description"].stringValue
                    let name = json["data"][0]["name"].stringValue
                    let abv = json["data"][0]["abv"].floatValue
                    let ibu = json["data"][0]["ibu"].floatValue
                    let image = json["data"][0]["labels"]["medium"].stringValue
                    
                    self.name.text = "Name: \(name)"
                    self.abvText.text = "ABV: \(abv)%"
                    self.ibuText.text = "IBU: \(ibu)"
                    
                    Alamofire.request(.GET, image, parameters: nil).response{ (_,_, data, _) -> Void in
                        let image = UIImage(data: data! as NSData)
                        self.labelImage.image = image
                    }
                }
            }
        }
    
//        presentItemInfo()
    }
    
    @IBAction func addButton(sender: AnyObject)
    {
        var input = addField.text
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Inventory", inManagedObjectContext: self.managedObjectContext!) as Inventory
        newItem.name = nameStr
        
        let fetchRequest = NSFetchRequest(entityName: "Inventory")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Inventory] {
            newItem.amount = input.toInt()! + Int(fetchResults[0].amount)
        }
        println(newItem.amount)
        
        
        println(input)
    }
    
    @IBAction func dismissDetails(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
    
    
    func doSegue()
    {
        performSegueWithIdentifier("addBeerSegue", sender: self)
    }
    
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
    
    
    
} 