//
//  RecipeClasses.swift
//  YouFood
//
//  Created by ckanou on 2018-07-02.
//  Copyright © 2018 Novus. All rights reserved.
//
//  Contributors to this file: Cloud (Syou) Kanou, Maggie Xu
//

import Foundation
import UIKit

class Nutrient{
    var name: String
    var quantity: Float
    var unit: String
    
    init(name: String, quantity: Float, unit: String){
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }
}

class Ingredient{
    var name: String = ""
    var quantity: String = ""
    var unit: String = ""
    var tags: [String] = []
    
    init(name: String, quantity: String, unit: String, tags: [String]){
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.tags = tags
    }
    
    init(){
        self.name = ""
        self.quantity = ""
        self.unit = ""
        self.tags = []
    }
    
}

class Recipe{
    var key: String
    var imageID: String
    var recipeImageUrl: String
    var actualImage: UIImage?
    var title: String
    var author: String
    var ingredients: [Ingredient]
    var cuisine: String
    var mealType: [String]
    var timeToCook: Int
    var servings: Int
    var directions: [(Int, String)]
    var nutrients: [Nutrient] = []
    var numLikes: Int
    //var starRating: Double
    
    init(key: String, imageID: String, recipeImageUrl: String,title: String, author: String, ingredients: [Ingredient], cuisine: String, mealType: [String], timeToCook: Int, servings: Int, directions: [(Int, String)], nutrients: [Nutrient], numLikes: Int){
        self.key = key
        self.imageID = imageID
        self.recipeImageUrl = recipeImageUrl
        self.title = title
        self.author = author
        self.ingredients = ingredients
        self.cuisine = cuisine
        self.mealType = mealType
        self.timeToCook = timeToCook
        self.servings = servings
        self.directions = directions
        self.nutrients = nutrients
        self.actualImage = nil
        self.numLikes = numLikes
    }
    
    init(){
        self.key = ""
        self.imageID = ""
        self.recipeImageUrl = ""
        self.title = ""
        self.author = ""
        self.ingredients = []
        self.cuisine = ""
        self.mealType = []
        self.timeToCook = 0
        self.servings = 0
        self.directions = []
        self.nutrients = []
        self.actualImage = nil
        self.numLikes = 0
    }
}

