//
//  MealPlan+CoreDataProperties.swift
//  
//
//  Created by Sukkwon On on 2018-07-30.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension MealPlan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MealPlan> {
        return NSFetchRequest<MealPlan>(entityName: "MealPlan")
    }

    @NSManaged public var breakfastAuthor: String?
    @NSManaged public var breakfastTitle: String?
    @NSManaged public var dateDay: String?
    @NSManaged public var dateMonth: String?
    @NSManaged public var dateYear: String?
    @NSManaged public var dinnerAuthor: String?
    @NSManaged public var dinnerTitle: String?
    @NSManaged public var lunchAuthor: String?
    @NSManaged public var lunchTitle: String?

}
