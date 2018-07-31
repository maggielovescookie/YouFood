//
//  MealPlanDate+CoreDataProperties.swift
//  
//
//  Created by Sukkwon On on 2018-07-30.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension MealPlanDate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MealPlanDate> {
        return NSFetchRequest<MealPlanDate>(entityName: "MealPlanDate")
    }

    @NSManaged public var date: String?

}
