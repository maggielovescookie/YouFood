//
//  RecipeClasses.swift
//  YouFood
//
//  Created by ckanou on 2018-07-02.
//  Copyright © 2018 Novus. All rights reserved.
//
//  Contributors to this file: Cloud Kanou, Maggie Xu, Sukkwon On, Ryan Thompson
//
//  Custom classes to hold information for recipes

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
    
    //tags is unused. Original purpose was to filter allergies and dietary styles
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
    //key is the reference key in firebase
    var key: String
    
    //imageID is the actual ID of the image stored in firebase
    var imageID: String
    
    //recipeImageUrl holds the URL that downloadss the image
    var recipeImageUrl: String
    
    //actualImage holds the UIImage once downloaded from the database
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

