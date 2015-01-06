//
//  CodeViewController.swift
//  OnTap
//
//  Created by Nick Martinson on 12/22/14.
//  Copyright (c) 2014 Nick Martinson. All rights reserved.
//
import Foundation
import UIKit
import CoreData
import Alamofire

class CodeViewController: BaseInfoController, UITabBarDelegate
{
    @IBOutlet weak var commentsTabBar: UITabBar!
    @IBOutlet weak var abvText: UITextView!
    @IBOutlet weak var ibuText: UITextView!
    @IBOutlet weak var onTapText: UITextView!
    @IBOutlet weak var name: UITextView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var styleDescriptionText: UITextView!
    @IBOutlet weak var descriptionPanel: UIView!
    @IBOutlet weak var commentScrollView: UIScrollView!

    var codeStr:String = ""
    var inventoryItems = [Inventory]()
    var fromOnTap = false
    var fromSearch = false
    var commentsHaveBeenLoaded = false
    
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

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
        self.title = ""
        if let tabItem = commentsTabBar.items {
            var description = tabItem[0] as UITabBarItem
            commentsTabBar.selectedItem = description
            descriptionPanel.hidden = false
        }
        
        var navBar = UINavigationBar()
        let navButton = UIBarButtonItem(title: "On Tap", style: .Plain, target: self, action: Selector("changeOnTapPressed"))
        navigationItem.rightBarButtonItem = navButton
        self.view.addSubview(navBar)
        image = ""
        
        // Executes when no barcode was found
        if !fromOnTap && !fromSearch
        {
            var postQuery = PFQuery(className: "Beer")
            postQuery.whereKey("barcode", equalTo: codeStr)
            postQuery.findObjectsInBackgroundWithBlock{
                (objects: [AnyObject]!, error: NSError!) -> Void in
                let results = objects as NSArray
                if results.count > 0
                {
                    let beerID = results[0].objectForKey("beerID") as String
                    self.beerID = beerID
                    BreweryDBapi().searchBeerByID(beerID) {
                        (result: Dictionary<String,AnyObject>?) in
                        self.setBeerLabels(result!)
                    }
                    
                }
                else
                {
                    println("Nothing returned")
                    self.doSegue()
                }
            }
        }
        else
        {
            // retrieves the beer information and sets the labels in the view
            BreweryDBapi().searchBeerByID(beerID) {
                (result: Dictionary<String,AnyObject>?) in
                self.setBeerLabels(result!)
                self.image = result!["imageStr"] as String
                self.getLabelImage(self.image)
            }
            self.onTapText.text = "On tap: 0"
        }
        let (success, num, newItem) = fetchLog("id")
        onTapText.text = "On tap: \(num)"
    }
    
    func setBeerLabels(data: NSDictionary)
    {
        self.title = (data["breweryName"] as String)
        self.nameStr = data["name"] as String
        var ibu = data["ibu"] as Float
        var abv = data["abv"] as Float
        var description = data["description"] as String
        var styleDescription = data["styleDescription"] as String
        self.image = data["imageStr"] as String
        
        BreweryDBapi().getLabelImage(self.image) {
            (newImage: UIImage) in
            var myImage = newImage
            self.labelImage.image = myImage
        }
        
        self.name.text = "Name: \(nameStr)"
        self.abvText.text = "ABV: \(abv)%"
        self.ibuText.text = "IBU: \(ibu)"
        self.descriptionText.text = description
        self.styleDescriptionText.text = styleDescription
    }
    

    /******************************************************************************************
    *
    ******************************************************************************************/
    func checkOnTap() -> Bool
    {
        let fetchRequest = NSFetchRequest(entityName: "Inventory")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Inventory] {
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
                let predicate = NSPredicate(format: "id == %@", beerID)
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
    func addToTap(newItem: Inventory, oldAmount: Int, newAmount: Int) -> Int
    {
        newItem.amount = oldAmount + newAmount
        
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
    *   Gets called immediately before performing segue. 
    *   Passes the barcode to the next AddBeerController
    ******************************************************************************************/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if( segue.identifier == "addBeerSegue")
        {
            var controller = segue.destinationViewController as AddBeerSearchController
            controller.upc = codeStr
        }
        else if segue.identifier == "toNewPost"
        {
            var controller = segue.destinationViewController as NewPostViewController
            controller.beerID = self.beerID
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
        let fetchRequest = NSFetchRequest(entityName: "Inventory")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Inventory] {
            if(!fetchResults.isEmpty)
            {
                onTapText.text = "On Tap: \(fetchResults[0].amount)"
            }
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
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
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func changeOnTapPressed()
    {
        let alertController = UIAlertController(title: "Modify Inventory", message: "Add or remove from tap", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel){ void in
            
        }
        let addAction = UIAlertAction(title: "Add", style: .Default){ void in
            
            var text = (alertController.textFields![0] as UITextField).text
            
            if text != ""
            {
                var input = text.toInt()!
                let (success, number, item) = self.fetchLog("id")
                if success
                {
                    var num = self.addToTap(item!,oldAmount: number, newAmount: input)
                    self.onTapText.text = "On tap: \(num)"
                }
                else
                {
                    var newItem = self.createInManagedObjectContext(self.managedObjectContext!, name: self.nameStr, amount: input, barcode: self.codeStr, id: self.beerID, image: self.image)
                    self.onTapText.text = "On tap: \(newItem.amount.stringValue)"
                }
            }
        }
        let removeAction = UIAlertAction(title: "Remove", style: .Destructive){ void in
            var text = (alertController.textFields![0] as UITextField).text
            
            if text != ""
            {
                var input = text.toInt()!
                let (success, number, item) = self.fetchLog("id")
                if success
                {
                    var num = self.addToTap(item!,oldAmount: number, newAmount: -input)
                    self.onTapText.text = "On tap: \(num)"
                }
                else
                {
                    var newItem = self.createInManagedObjectContext(self.managedObjectContext!, name: self.nameStr, amount: input, barcode: self.codeStr, id: self.beerID, image: self.image)
                    self.onTapText.text = "On tap: \(newItem.amount.stringValue)"
                }
            }
        }
        alertController.addAction(addAction)
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        alertController.addTextFieldWithConfigurationHandler{ (textField) in
            textField.placeholder = "0"
        }
        self.presentViewController(alertController, animated: true){
            
        }
    }

    
    /******************************************************************************************
    *
    ******************************************************************************************/
    @IBAction func notesPressed(sender: AnyObject)
    {
        
    }

    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!)
    {
        var selectedItem = tabBar.selectedItem
        if let item = tabBar.items {
            var description = item[0] as UITabBarItem
            var comments = item[1] as UITabBarItem
            
            switch selectedItem!
            {
                case description:
                    commentScrollView.hidden = true
                    descriptionPanel.hidden = false
                case comments:
                    descriptionPanel.hidden = true
                    commentScrollView.hidden = false
                    if !commentsHaveBeenLoaded
                    {
                        getComments()
                        commentsHaveBeenLoaded = true
                    }
                default:
                    break
            }
        }
    }
    
    /******************************************************************************************
    * Allows for placing an image in a dynamically created imageview
    ******************************************************************************************/
    func getLabelImage(imageStr: String, newImage: UIImageView)
    {
        Alamofire.request(.GET,imageStr).responseImage({ (request, _, image, error) -> Void in
            if error == nil && image != nil{
                newImage.image = image
            }
        })
    }
    
    
    func getComments()
    {
        var friendsRequest = FBRequest.requestForMyFriends()
        friendsRequest.startWithCompletionHandler { (connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            if !(error != nil)
            {
                let resultDict = result as NSDictionary
                let data = resultDict["data"] as NSArray
                let element = data[0] as NSDictionary
                let id = element["id"] as String
            }
        }
        
        var postQuery = PFQuery(className: "Post")
        postQuery.whereKey("beerID", equalTo: beerID)
        postQuery.findObjectsInBackgroundWithBlock{
            (objects: [AnyObject]!, error: NSError!) -> Void in
            let results = objects as NSArray
            var yPos:CGFloat = 10.0
            for(var i = 0; i < results.count; i++)
            {
                let name = results[i].objectForKey("name") as String
                let imageURL = results[i].objectForKey("imageURL") as String
                var image = UIImageView(frame: CGRectMake(16.0, yPos, 80.0, 50.0))
                self.getLabelImage(imageURL, newImage: image)
                var text = UITextView(frame: CGRectMake(115.0, yPos, 250, 50.0))
                text.editable = false
                var content = results[i].objectForKey("textContent") as String
                text.text = "name: \(name)\n\(content)"
                self.commentScrollView.addSubview(text)
                self.commentScrollView.addSubview(image)
                yPos += 70
            }
            self.commentScrollView.contentSize = CGSizeMake(600, CGFloat(70*results.count))
        }
    }
    
} 