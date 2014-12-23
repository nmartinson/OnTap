//
//  Inventory.swift
//  OnTap
//
//  Created by Nick Martinson on 12/22/14.
//  Copyright (c) 2014 Nick Martinson. All rights reserved.
//

import Foundation
import CoreData

class Inventory: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var amount: NSNumber

}
