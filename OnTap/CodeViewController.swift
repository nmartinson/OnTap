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
    @IBOutlet weak var onTapText: UITextView!
    @IBOutlet weak var addField: UITextField!
    @IBOutlet weak var country: UITextView!
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
    
    override func viewWillAppear(animated: Bool)
    {
        var url = "http://www.outpan.com/api/get-product.php?barcode=\(codeStr)&apikey=3a3657604cc7b7f103cfce13c9c01839"
//        println(url)
        Alamofire.request(.GET, url, parameters: nil).responseJSON{ (_,_, data, _) -> Void in
            println(data!)
            let json = JSON(data!)
            let name = json["name"].stringValue
            self.nameStr = name
            let country = json["attributes"]["Country"].stringValue
            self.name.text = "Name: \(name)"
            self.country.text = "Country: \(country)"
        }
        presentItemInfo()
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