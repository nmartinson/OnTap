//
//  CoreDataController.swift
//  OnTap
//
//  Created by Nick Martinson on 2/7/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import CoreData

class CoreDataController
{
    
    // Used for Core Data functionality
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
        }()

    
    func getBeerNote(beerID: String) -> BeerNotes?
    {
        let fetchRequest = NSFetchRequest(entityName: "BeerNotes")
        let predicate = NSPredicate(format: "beerID == %@", beerID)
        fetchRequest.predicate = predicate
        if let fetchResults = managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as? [BeerNotes]
        {
            return fetchResults.first
        }
        else
        {
            return nil
        }
    }
    
    func updateBeerNote(beerNote: BeerNotes?, beerID: String, text: String)
    {
        if beerNote == nil
        {
            createBeerNote(self.managedObjectContext!, beerID: beerID, text: text)
        }
        else
        {
            beerNote!.notes = text
        }
        var error: NSError? = nil
        if !self.managedObjectContext!.save(&error)
        {
            println("Error! \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    func createBeerNote(moc: NSManagedObjectContext, beerID: String, text: String) -> BeerNotes
    {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("BeerNotes", inManagedObjectContext: moc) as! BeerNotes
        newItem.beerID = beerID
        newItem.notes = text
        
        var error: NSError? = nil
        if !self.managedObjectContext!.save(&error)
        {
            println("Error! \(error), \(error!.userInfo)")
            abort()
        }
        
        return newItem
    }
    
}