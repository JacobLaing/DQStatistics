//
//  Labor+CoreDataProperties.swift
//  DQ Statistics
//
//  Created by Jacob Laing on 4/27/19.
//  Copyright © 2019 Jacob Laing. All rights reserved.
//
//

import Foundation
import CoreData


extension Labor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Labor> {
        return NSFetchRequest<Labor>(entityName: "Labor")
    }

    @NSManaged public var name: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var amount: Double

}
