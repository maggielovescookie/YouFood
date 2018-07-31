//
//  MealPlanDinner+CoreDataProperties.swift
//  
//
//  Created by Sukkwon On on 2018-07-30.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension MealPlanDinner {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MealPlanDinner> {
        return NSFetchRequest<MealPlanDinner>(entityName: "MealPlanDinner")
    }

    @NSManaged public var author: String?
    @NSManaged public var title: String?

}
