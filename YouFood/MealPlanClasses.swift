//
//   MealPlanClasses.swift
//  YouFood
//
//  Created by ckanou on 7/24/18.
//  Copyright © 2018 Novus. All rights reserved.
//
// Contributers: Syou (Cloud) Kanou, Ryan Thompson

import Foundation

class oneDayMealPlan{
    
    var breakfast: Recipe?
    var lunch: Recipe?
    var dinner: Recipe?
    
    var totalNutrients: [Float]
    
    init(){
        totalNutrients = []
        for i in 0 ..< foodNutrientLabels.count{
            totalNutrients.append(0)
        }
        print(totalNutrients)
    }
}

