//
//  MealPlanLunch+CoreDataProperties.swift
//  
//
//  Created by Sukkwon On on 2018-07-30.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension MealPlanLunch {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MealPlanLunch> {
        return NSFetchRequest<MealPlanLunch>(entityName: "MealPlanLunch")
    }

    @NSManaged public var author: String?
    @NSManaged public var title: String?

}
