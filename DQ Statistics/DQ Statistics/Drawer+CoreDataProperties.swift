//
//  Drawer+CoreDataProperties.swift
//  DQ Statistics
//
//  Created by Jacob Laing on 5/3/19.
//  Copyright © 2019 Jacob Laing. All rights reserved.
//
//

import Foundation
import CoreData


extension Drawer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Drawer> {
        return NSFetchRequest<Drawer>(entityName: "Drawer")
    }

    @NSManaged public var name: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var deposited: Double
    @NSManaged public var counted: Double

}
