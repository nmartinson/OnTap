//
//  NotesViewController.swift
//  OnTap
//
//  Created by Nick Martinson on 12/31/14.
//  Copyright (c) 2014 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NotesViewController: UIViewController
{
    
    @IBOutlet weak var textField: UITextView!
    var beerID = ""
    var noteObject:BeerNotes?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Beer Notes"
        noteObject = CoreDataController().getBeerNote(beerID)
        textField.text = noteObject?.notes
    }
    
    
    @IBAction func cancelButtonPressed(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject)
    {
        let text = textField.text
        CoreDataController().updateBeerNote(noteObject, beerID: beerID, text: text)
        dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
}