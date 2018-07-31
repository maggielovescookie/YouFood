//
//  Users+CoreDataProperties.swift
//  
//
//  Created by Sukkwon On on 2018-07-30.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Users {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Users> {
        return NSFetchRequest<Users>(entityName: "Users")
    }

    @NSManaged public var age: String?
    @NSManaged public var password: String?
    @NSManaged public var username: String?

}
