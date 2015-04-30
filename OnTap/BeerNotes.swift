//
//  BeerNotesModel.swift
//  OnTap
//
//  Created by Nick Martinson on 2/7/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import CoreData

class BeerNotes: NSManagedObject
{
    
    @NSManaged var beerID: String
    @NSManaged var notes: String
    
}