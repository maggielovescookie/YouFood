
//
//  MealPlanMainViewController.swift
//  YouFood
//  Created by XuMaggie on /07/1218.
//  Copyright © 2018年 Novus. All rights reserved.
//
//  Contributers: Maggie Xu, Syou (Cloud) Kanou, Ryan Thompson
//

import UIKit
import Foundation
import CoreData

// global counter
// Instead of getting the ID of the segue called 2 viewcontrollers ago, we just set
// a global variable and figure out which type of meal just got added using that
var counter = 0

class MealPlanMainViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,DataEnteredDelegate{
    
    // Reference for the circles that display nutrients
    @IBOutlet var nutritionCollectionView: UICollectionView?
    
    // Reference for the collection that shows which day of the meal plan you have selected
    @IBOutlet var calendarCollectionView: UICollectionView?
    @IBOutlet var MonthLabel: UILabel?
    
    // If we select AddBreakfast, we know the recipe we are getting from the table view is for breakfast
    @IBAction func AddBreakfast(_ sender: UIButton) {
        counter = 1
    }
    // If we select AddLunch, we know the recipe we are getting from the table view is for lunch
    @IBAction func AddLunch(_ sender: UIButton) {
        counter = 2
    }
    // If we select AddDinner, we know the recipe we are getting from the table view is for dinner
    @IBAction func AddDinner(_ sender: UIButton) {
        counter = 3
    }
    
    @IBAction func deleteAllCoreData(_ sender: UIBarButtonItem) {
        let alert =  UIAlertController(title: "Alert", message: "This will delete all your meal history from your phone!", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }}))
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MealPlan")
                request.returnsObjectsAsFaults = false
                do {
                    let resultDate = try context.fetch(request)
                    for dates in resultDate as! [NSManagedObject]{
                        context.delete(dates)
                    }
                } catch {
                    print("Failed")
                }
                do {
                    // make sure to save the deletion
                    try context.save()
                } catch {
                    print("Save Error")
                }
                self.getMealsForDate(day: self.coreDataDay, month: self.coreDataMonth, year: self.coreDataYear)
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteBreakfast(_ sender: UIButton) {
        // If you try to delete a non-existent meal, throw a message
        if todaysMealPlan.breakfast == nil{
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "There's nothing to delete!"
            alert.addButton(withTitle: "Ok")
            alert.show()
            return
        } else{
            // otherwise, delete the meal from core data, set the breakfast to nil, and recalculate nutrients
            deleteFromCoreData(entityName: "MealPlanBreakfast")
            todaysMealPlan.breakfast = nil
            breakfastSelection.text = "Nothing Selected"
            getNutrientsFromTodaysMealPlan(todaysMealPlan: todaysMealPlan)
        }
    }
    
    @IBAction func deleteLunch(_ sender: Any) {
        // If you try to delete a non-existent meal, throw a message
        if todaysMealPlan.lunch == nil{
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "There's nothing to delete!"
            alert.addButton(withTitle: "Ok")
            alert.show()
            return
        } else{
            // otherwise, delete the meal from core data, set the lunch to nil, and recalculate nutrients
            deleteFromCoreData(entityName: "MealPlanLunch")
            todaysMealPlan.lunch = nil
            lunchSelection.text = "Nothing Selected"
            getNutrientsFromTodaysMealPlan(todaysMealPlan: todaysMealPlan)
        }
    }
    @IBAction func deleteDinner(_ sender: Any) {
        // If you try to delete a non-existent meal, throw a message
        if todaysMealPlan.dinner == nil{
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "There's nothing to delete!"
            alert.addButton(withTitle: "Ok")
            alert.show()
            return
        } else{
            // otherwise, delete the meal from core data, set the dinner to nil, and recalculate nutrients
            deleteFromCoreData(entityName: "MealPlanDinner")
            todaysMealPlan.dinner = nil
            dinnerSelection.text = "Nothing Selected"
            getNutrientsFromTodaysMealPlan(todaysMealPlan: todaysMealPlan)
        }
    }
    
    @IBOutlet weak var breakfastSelection: UILabel!
    @IBOutlet weak var lunchSelection: UILabel!
    @IBOutlet weak var dinnerSelection: UILabel!
    
    // The main variable that holds the meal plan recipes and nutrients
    var todaysMealPlan = oneDayMealPlan()
    
    // if the user selected a recipe for the next view controller, check the counter and
    // add the recipe to the corresponding category
    func userDidEnterInformation(mealPlanRecipe: Recipe) {
        var entityName: String
        if counter == 1{
            self.breakfastSelection.text = mealPlanRecipe.title
            todaysMealPlan.breakfast = mealPlanRecipe
            entityName = "MealPlanBreakfast"
        } else if counter == 2{
            self.lunchSelection.text = mealPlanRecipe.title
            todaysMealPlan.lunch = mealPlanRecipe
            entityName = "MealPlanLunch"
        } else{
            self.dinnerSelection.text = mealPlanRecipe.title
            todaysMealPlan.dinner = mealPlanRecipe
            entityName = "MealPlanDinner"
        }
        
        // delete then save to core data because it's much easier than updating
        deleteFromCoreData(entityName: entityName)
        
        saveToCoreData(todaysMealPlan: todaysMealPlan, entityName: entityName)
        
        getMealsForDate(day: coreDataDay, month: coreDataMonth, year: coreDataYear)
        
        getNutrientsFromTodaysMealPlan(todaysMealPlan: todaysMealPlan)
    }
    
    // Delete data from coredata
    func deleteFromCoreData(entityName: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MealPlan")
        request.returnsObjectsAsFaults = false
        do {
            let resultDate = try context.fetch(request)
            for dates in resultDate as! [NSManagedObject]{
                // if the dates match the current selected date, remove everything related to it,
                // including the date itself
                let searchYear = dates.value(forKey: "dateYear") as! String
                let searchDay = dates.value(forKey: "dateDay") as! String
                let searchMonth = dates.value(forKey: "dateMonth") as! String
                if (searchYear == String(coreDataYear) && searchDay == String(coreDataDay) && searchMonth == String(coreDataMonth)){
                    context.delete(dates)
                }
            }
        } catch {
            print("Failed")
        }
        do {
            // make sure to save the deletion
            try context.save()
        } catch {
            print("Save Error")
        }
    }
    
    // save to core data
    func saveToCoreData(todaysMealPlan: oneDayMealPlan, entityName: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // simply set values for the new NSManagedObject.
        // If a type of meal is nil, just set it as an empty string
        let entity = NSEntityDescription.entity(forEntityName: "MealPlan", in: context)
        let newMealPlan = NSManagedObject(entity: entity!, insertInto: context)
        if todaysMealPlan.breakfast != nil{
            newMealPlan.setValue("\(todaysMealPlan.breakfast?.title ?? "")", forKey: "breakfastTitle")
            newMealPlan.setValue("\(todaysMealPlan.breakfast?.author ?? "")", forKey: "breakfastAuthor")
            newMealPlan.setValue("\(todaysMealPlan.breakfast?.key ?? "")", forKey: "bKey")
        }
        if todaysMealPlan.lunch != nil{
            newMealPlan.setValue("\(todaysMealPlan.lunch?.title ?? "")", forKey: "lunchTitle")
            newMealPlan.setValue("\(todaysMealPlan.lunch?.author ?? "")", forKey: "lunchAuthor")
            newMealPlan.setValue("\(todaysMealPlan.lunch?.key ?? "")", forKey: "lKey")
        }
        if todaysMealPlan.dinner != nil{
            newMealPlan.setValue("\(todaysMealPlan.dinner?.title ?? "")", forKey: "dinnerTitle")
            newMealPlan.setValue("\(todaysMealPlan.dinner?.author ?? "")", forKey: "dinnerAuthor")
            newMealPlan.setValue("\(todaysMealPlan.dinner?.key ?? "")", forKey: "dKey")
        }
        
        newMealPlan.setValue("\(coreDataDay)", forKey: "dateDay")
        newMealPlan.setValue("\(coreDataMonth)", forKey: "dateMonth")
        newMealPlan.setValue("\(coreDataYear)", forKey: "dateYear")
        
        do {
            // make sure to save the addition
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    // just go through each recipe in the todaysMealPlan class and add to the array
    func getNutrientsFromTodaysMealPlan(todaysMealPlan: oneDayMealPlan) {
        todaysMealPlan.totalNutrients = []
        for i in 0 ..< foodNutrientLabels.count{
            todaysMealPlan.totalNutrients.append(0)
        }
        
        if (todaysMealPlan.breakfast != nil){
            for i in 0 ..< todaysMealPlan.totalNutrients.count{
                todaysMealPlan.totalNutrients[i] += todaysMealPlan.breakfast!.nutrients[i].quantity/Float(todaysMealPlan.breakfast!.servings)
            }
        }
        if (todaysMealPlan.lunch != nil){
            for i in 0 ..< todaysMealPlan.totalNutrients.count{
                todaysMealPlan.totalNutrients[i] += todaysMealPlan.lunch!.nutrients[i].quantity/Float(todaysMealPlan.lunch!.servings)
            }
        }
        if (todaysMealPlan.dinner != nil){
            for i in 0 ..< todaysMealPlan.totalNutrients.count{
                todaysMealPlan.totalNutrients[i] += todaysMealPlan.dinner!.nutrients[i].quantity/Float(todaysMealPlan.dinner!.servings)
            }
        }
        
        for i in 0 ..< todaysMealPlan.totalNutrients.count{
            nutritions[i].percentage = CGFloat(todaysMealPlan.totalNutrients[i]/nutritions[i].recommendedDailyAmount!)
        }
        nutritionCollectionView?.reloadData()
    }
    
    // Setting up ALL THE DATA for the circle nutrition view visualizer things
    var nutritions:[Nutrition] = {
        var protein = Nutrition()
        protein.title = "Protein"
        protein.recommendedDailyAmount = 51
        protein.trackColor = UIColor(white: 255/255, alpha: 0.2)
        protein.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        protein.percentage = 0
        
        var fat = Nutrition()
        fat.title = "Fat"
        fat.recommendedDailyAmount = 66
        fat.trackColor = UIColor(white: 255/255, alpha: 0.2)
        fat.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        fat.percentage = 0
        
        var Carbs = Nutrition()
        Carbs.title = "Carbohydrates"
        Carbs.recommendedDailyAmount = 275
        Carbs.trackColor = UIColor(white: 255/255, alpha: 0.2)
        Carbs.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        Carbs.percentage = 0
        
        var calories = Nutrition()
        calories.title = "KCalories"
        calories.recommendedDailyAmount = 2000
        calories.trackColor = UIColor(white: 255/255, alpha: 0.2)
        calories.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        calories.percentage = 0
        
        var fiber = Nutrition()
        fiber.title = "Fiber"
        fiber.recommendedDailyAmount = 26.5
        fiber.trackColor = UIColor(white: 255/255, alpha: 0.2)
        fiber.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        fiber.percentage = 0
        
        var sugar = Nutrition()
        sugar.title = "Sugar"
        sugar.recommendedDailyAmount = 25
        sugar.trackColor = UIColor(white: 255/255, alpha: 0.2)
        sugar.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        sugar.percentage = 0
        
        var calcium = Nutrition()
        calcium.title = "Calcium"
        calcium.recommendedDailyAmount = 780
        calcium.trackColor = UIColor(white: 255/255, alpha: 0.2)
        calcium.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        calcium.percentage = 0
        
        var iron = Nutrition()
        iron.title = "Iron"
        iron.recommendedDailyAmount = 10
        iron.trackColor = UIColor(white: 255/255, alpha: 0.2)
        iron.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        iron.percentage = 0
        
        var magnesium = Nutrition()
        magnesium.title = "Magnesium"
        magnesium.recommendedDailyAmount = 210
        magnesium.trackColor = UIColor(white: 255/255, alpha: 0.2)
        magnesium.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        magnesium.percentage = 0
        
        var potassium = Nutrition()
        potassium.title = "Potassium"
        potassium.recommendedDailyAmount = 4500
        potassium.trackColor = UIColor(white: 255/255, alpha: 0.2)
        potassium.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        potassium.percentage = 0
        
        var sodium = Nutrition()
        sodium.title = "Sodium"
        sodium.recommendedDailyAmount = 1500
        sodium.trackColor = UIColor(white: 255/255, alpha: 0.2)
        sodium.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        sodium.percentage = 0
        
        var vitaminC = Nutrition()
        vitaminC.title = "Vitamin C"
        vitaminC.recommendedDailyAmount = 34
        vitaminC.trackColor = UIColor(white: 255/255, alpha: 0.2)
        vitaminC.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        vitaminC.percentage = 0
        
        var vitaminD = Nutrition()
        vitaminD.title = "Vitamin D"
        vitaminD.recommendedDailyAmount = 120
        vitaminD.trackColor = UIColor(white: 255/255, alpha: 0.2)
        vitaminD.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        vitaminD.percentage = 0
        
        var vitaminK = Nutrition()
        vitaminK.title = "Vitamin K"
        vitaminK.recommendedDailyAmount = 105
        vitaminK.trackColor = UIColor(white: 255/255, alpha: 0.2)
        vitaminK.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        vitaminK.percentage = 0
        
        var vitaminB6 = Nutrition()
        vitaminB6.title = "Vitamin B-6"
        vitaminB6.recommendedDailyAmount = 1
        vitaminB6.trackColor = UIColor(white: 255/255, alpha: 0.2)
        vitaminB6.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        vitaminB6.percentage = 0
        
        var vitaminB12 = Nutrition()
        vitaminB12.title = "Vitamin B-12"
        vitaminB12.recommendedDailyAmount = 1
        vitaminB12.trackColor = UIColor(white: 255/255, alpha: 0.2)
        vitaminB12.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        vitaminB12.percentage = 0
        
        var saturatedFat = Nutrition()
        saturatedFat.title = "Saturated Fat"
        saturatedFat.recommendedDailyAmount = 22.4
        saturatedFat.trackColor = UIColor(white: 255/255, alpha: 0.2)
        saturatedFat.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        saturatedFat.percentage = 0
        
        // Need filler so all the important circles actually show up
        var filler = Nutrition()
        filler.title = ""
        filler.trackColor = UIColor(white: 255/255, alpha: 0.2)
        filler.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        filler.percentage = 0
        
        return [protein, fat, Carbs, calories, fiber, sugar, calcium, iron, magnesium, potassium, sodium, vitaminC, vitaminD, vitaminK, vitaminB6, vitaminB12, saturatedFat, filler, filler, filler]
        
    }()
    
    // Set up for the calender collection view
    let Months = ["January","February","March","April","May","June","July","August","September","October","November","December"]
    
    var DaysInMonths = [31,28,31,30,31,30,31,31,30,31,30,31]
    
    var currentMonth = String()
    
    var Direction = 0
    
    var LeapYearCounter = 2
    
    var dayCounter = 0
    
    var day = Calendar.current.component(.day , from: Date())
    var weekday = Calendar.current.component(.weekday, from: Date())
    var month = Calendar.current.component(.month, from: Date()) - 1
    var year = Calendar.current.component(.year, from: Date())
    
    var thisMonth = Calendar.current.component(.month, from: Date()) - 1
    
    // ALL STORED AS INTS
    // core data vars to actually reference to when loading data from care data
    var coreDataDay = Calendar.current.component(.day , from: Date())
    var coreDataMonth = Calendar.current.component(.month, from: Date())
    var coreDataYear = Calendar.current.component(.year, from: Date())
    
    
    
    
    //---------------------------------------------(Next and back buttons)---------------------------------------
    @IBAction func Next(_ sender: Any) {
        switch currentMonth {
        case "December":
            Direction = 1
            
            month = 0
            year += 1
            
            if LeapYearCounter  < 5 {
                LeapYearCounter += 1
            }
            
            if LeapYearCounter == 4 {
                DaysInMonths[1] = 29
            }
            
            if LeapYearCounter == 5{
                LeapYearCounter = 1
                DaysInMonths[1] = 28
            }
            
            currentMonth = Months[0]
            MonthLabel?.text = "\(currentMonth) \(year)"
            calendarCollectionView?.reloadData()
            
            coreDataYear += 1
            coreDataMonth = 1
            
        default:
            Direction = 1
            month += 1
            
            currentMonth = Months[month]
            MonthLabel?.text = "\(currentMonth) \(year)"
            calendarCollectionView?.reloadData()
            
            coreDataMonth += 1
        }
    }
    
    @IBAction func Back(_ sender: Any) {
        switch currentMonth {
        case "January":
            Direction = -1
            
            month = 11
            year -= 1
            
            if LeapYearCounter > 0{
                LeapYearCounter -= 1
            }
            if LeapYearCounter == 0{
                DaysInMonths[1] = 29
                LeapYearCounter = 4
            }else{
                DaysInMonths[1] = 28
            }
            
            currentMonth = Months[month]
            MonthLabel?.text = "\(currentMonth) \(year)"
            calendarCollectionView?.reloadData()
            coreDataMonth = 12
            coreDataYear -= 1
            
        default:
            Direction = -1
            
            month -= 1
            
            currentMonth = Months[month]
            MonthLabel?.text = "\(currentMonth) \(year)"
            calendarCollectionView?.reloadData()
            
            coreDataMonth -= 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // since we have two collection views on this page, we have to make sure we change the right ones
        switch collectionView.tag {
        case 0:
            return nutritions.count

        case 1:
            return DaysInMonths[month]
            
        default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 0:
            let cellA = collectionView.dequeueReusableCell(withReuseIdentifier: "CircularProgressView", for: indexPath) as! CircularProgressView
            cellA.nutrition = nutritions[indexPath.item]
            return cellA
            
        case 1:
            let cellB = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCollectionViewCell", for: indexPath) as! DateCollectionViewCell
            cellB.backgroundColor = UIColor.clear
            
            cellB.DateLabel.text = "\(indexPath.item + 1)"
            
            // days in the weekend have a light gray colour
            let components = DateComponents(year: year, month: month+1 , day: indexPath.item + 1)
            let theDay = Calendar.current.date(from: components)
            
            if Calendar.current.isDateInWeekend(theDay!){
                cellB.DateLabel.textColor = UIColor.lightGray
                
            }else{
                cellB.DateLabel.textColor = UIColor.black
                
            }
            // the current day has a magenta colour
            if indexPath.row == day-1 && thisMonth == month{
                cellB.backgroundColor = UIColor.magenta
            }
            return cellB
            
        default:
            fatalError()
        }
        
    }
    
    // function to load todaysMealPlan class and change the labels on the page
    func getMealsForDate (day: Int, month: Int, year: Int){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let requestMealPlan = NSFetchRequest<NSFetchRequestResult>(entityName: "MealPlan")
        requestMealPlan.returnsObjectsAsFaults = false
        
        do{
            var foundDate = false
            let results = try context.fetch(requestMealPlan)
            // if the array of dates doesn't even contain anything, set everything to the default
            if results.count == 0{
                todaysMealPlan.breakfast = nil
                todaysMealPlan.lunch = nil
                todaysMealPlan.dinner = nil
                self.dinnerSelection.text = "Nothing Selected"
                self.lunchSelection.text = "Nothing Selected"
                self.breakfastSelection.text = "Nothing Selected"
                getNutrientsFromTodaysMealPlan(todaysMealPlan: todaysMealPlan)
                return
            }
            for data in results as! [NSManagedObject]{
                // simply retrieve data from core data
                let searchYear = data.value(forKey: "dateYear") as! String
                let searchDay = data.value(forKey: "dateDay") as! String
                let searchMonth = data.value(forKey: "dateMonth") as! String
                
                let searchBTitle = data.value(forKey: "breakfastTitle") as? String ?? ""
                let searchBAuthor = data.value(forKey: "breakfastAuthor") as? String ?? ""
                let searchBKey = data.value(forKey: "bKey") as? String ?? ""
                
                let searchLTitle = data.value(forKey: "lunchTitle") as? String ?? ""
                let searchLAuthor = data.value(forKey: "lunchAuthor") as? String ?? ""
                let searchLKey = data.value(forKey: "lKey") as? String ?? ""
                
                let searchDTitle = data.value(forKey: "dinnerTitle") as? String ?? ""
                let searchDAuthor = data.value(forKey: "dinnerAuthor") as? String ?? ""
                let searchDKey = data.value(forKey: "dKey") as? String ?? ""
                
                // if we find the correct day, load the data
                if (searchYear == String(coreDataYear) && searchDay == String(coreDataDay) && searchMonth == String(coreDataMonth)){
                    foundDate = true
                    
                    // if a title is not empty, put in the title of the recipe in the label and put it into todaysMealPlan
                    if searchBTitle != ""{
                        self.breakfastSelection.text = searchBTitle
                        for i in 0 ..< testRecipes.count{
                            if (testRecipes[i].title == searchBTitle && testRecipes[i].author == searchBAuthor && testRecipes[i].key == searchBKey){
                                todaysMealPlan.breakfast = testRecipes[i]
                            }
                        }
                    } else{
                        // else, make the label nothing selected and nil the todaysMealPlan.breakfast
                        self.breakfastSelection.text = "Nothing Selected"
                        todaysMealPlan.breakfast = nil
                    }
                    // if a title is not empty, put in the title of the recipe in the label and put it into todaysMealPlan
                    if searchLTitle != ""{
                        self.lunchSelection.text = searchLTitle
                        for i in 0 ..< testRecipes.count{
                            if (testRecipes[i].title == searchLTitle && testRecipes[i].author == searchLAuthor && testRecipes[i].key == searchLKey){
                                todaysMealPlan.lunch = testRecipes[i]
                            }
                        }
                    } else{
                        // else, make the label nothing selected and nil the todaysMealPlan.lunch
                        self.lunchSelection.text = "Nothing Selected"
                        todaysMealPlan.lunch = nil
                    }
                    // if a title is not empty, put in the title of the recipe in the label and put it into todaysMealPlan
                    if searchDTitle != ""{
                        self.dinnerSelection.text = searchDTitle
                        for i in 0 ..< testRecipes.count{
                            if (testRecipes[i].title == searchDTitle && testRecipes[i].author == searchDAuthor && testRecipes[i].key == searchDKey){
                                todaysMealPlan.dinner = testRecipes[i]
                            }
                        }
                    } else{
                        // else, make the label nothing selected and nil the todaysMealPlan.lunch
                        self.dinnerSelection.text = "Nothing Selected"
                        todaysMealPlan.dinner = nil
                    }
                }
            }
            if !foundDate{
                // if the date is not found, set everything to the default
                todaysMealPlan.breakfast = nil
                todaysMealPlan.lunch = nil
                todaysMealPlan.dinner = nil
                self.dinnerSelection.text = "Nothing Selected"
                self.lunchSelection.text = "Nothing Selected"
                self.breakfastSelection.text = "Nothing Selected"
            }
            getNutrientsFromTodaysMealPlan(todaysMealPlan: todaysMealPlan)
        } catch{
            fatalError()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        getMealsForDate(day: coreDataDay, month: coreDataMonth, year: coreDataYear)
        
        // tapping on the title of the recipe takes you to the detailed view of it
        let tapOnBreakfast = UITapGestureRecognizer(target: self, action: #selector(MealPlanMainViewController.tapBreakfast))
        breakfastSelection.isUserInteractionEnabled = true
        breakfastSelection.addGestureRecognizer(tapOnBreakfast)
        
        let tapOnLunch = UITapGestureRecognizer(target: self, action: #selector(MealPlanMainViewController.tapLunch))
        lunchSelection.isUserInteractionEnabled = true
        lunchSelection.addGestureRecognizer(tapOnLunch)
        
        let tapOnDinner = UITapGestureRecognizer(target: self, action: #selector(MealPlanMainViewController.tapDinner))
        dinnerSelection.isUserInteractionEnabled = true
        dinnerSelection.addGestureRecognizer(tapOnDinner)
        
        // setting properties, delegates, and data sources of all collection views
        nutritionCollectionView?.register(CircularProgressView.self, forCellWithReuseIdentifier: "CircularProgressView")
        calendarCollectionView?.register(DateCollectionViewCell.self, forCellWithReuseIdentifier: "DateCollectionViewCell")
        
        (nutritionCollectionView?.collectionViewLayout as! UICollectionViewFlowLayout).estimatedItemSize = CGSize(width: 100, height: 100)
        (nutritionCollectionView?.collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing = 5
        
        (nutritionCollectionView?.collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing = 20
        
        
        nutritionCollectionView?.contentInset = UIEdgeInsetsMake(10, 10, 10, 10)
        nutritionCollectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        
        nutritionCollectionView?.dataSource = self
        nutritionCollectionView?.delegate = self
        
        nutritionCollectionView?.tag = 0
        calendarCollectionView?.tag = 1
        
        calendarCollectionView?.dataSource = self
        calendarCollectionView?.delegate = self
        
        // instantiate the views
        self.view.addSubview(nutritionCollectionView!)
        self.view.addSubview(calendarCollectionView!)
        
        currentMonth = Months[month]
        MonthLabel?.text = "\(currentMonth) \(year)"
    }
    
    // registers selections on the calender view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == nutritionCollectionView {
            return
        }
        collectionView.cellForItem(at: indexPath as IndexPath)?.backgroundColor = UIColor.cyan
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! DateCollectionViewCell
        coreDataDay = Int(cell.DateLabel.text!)!
        
        // whenever you click on a day, attempt to load the meals for that day
        // also, makes the calender date cyan
        getMealsForDate(day: coreDataDay, month: coreDataMonth, year: coreDataYear)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == nutritionCollectionView {
            return
        }
        // whenever a cell is deselected, get rid of the cyan colour
        // however, if it's the current date turn it back to magenta
        if indexPath.row == day-1  && thisMonth == month{
            collectionView.cellForItem(at: indexPath as IndexPath)?.backgroundColor = UIColor.magenta
        } else{
            collectionView.cellForItem(at: indexPath as IndexPath)?.backgroundColor = UIColor.clear
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectRecipe" {
            if let nav = segue.destination as? SelectRecipeNavigationViewController{
                if let selectRecipeVC = nav.viewControllers[0] as? SelectRecipeTableViewController{
                    selectRecipeVC.delegate = self
                }
            }
        } else if segue.identifier == "mealPlanBreakfastDetail"{
            if let nav = segue.destination as? RecipeNavigationController{
                if let detailsVC = nav.viewControllers[0] as? DetailedRecipeViewController{
                    detailsVC.recipe = todaysMealPlan.breakfast
                }
            }
        } else if segue.identifier == "mealPlanLunchDetail"{
            if let nav = segue.destination as? RecipeNavigationController{
                if let detailsVC = nav.viewControllers[0] as? DetailedRecipeViewController{
                    detailsVC.recipe = todaysMealPlan.lunch
                }
            }
        } else if segue.identifier == "mealPlanDinnerDetail"{
            if let nav = segue.destination as? RecipeNavigationController{
                if let detailsVC = nav.viewControllers[0] as? DetailedRecipeViewController{
                    detailsVC.recipe = todaysMealPlan.dinner
                }
            }
        }
    }
    
    // if you attempt to bring up the detailed view of a recipe without having one selected, throw and alert
    @objc func tapBreakfast(sender:UITapGestureRecognizer) {
        if todaysMealPlan.breakfast != nil{
            self.performSegue(withIdentifier: "mealPlanBreakfastDetail", sender: self)
        } else {
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "You haven't selected an meal yet!"
            alert.addButton(withTitle: "Ok")
            alert.show()
            return
        }
    }
    // if you attempt to bring up the detailed view of a recipe without having one selected, throw and alert
    @objc func tapLunch(sender:UITapGestureRecognizer) {
        if todaysMealPlan.lunch != nil{
            self.performSegue(withIdentifier: "mealPlanLunchDetail", sender: self)
        } else {
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "You haven't selected an meal yet!"
            alert.addButton(withTitle: "Ok")
            alert.show()
            return
        }
    }
    // if you attempt to bring up the detailed view of a recipe without having one selected, throw and alert
    @objc func tapDinner(sender:UITapGestureRecognizer) {
        if todaysMealPlan.dinner != nil{
            self.performSegue(withIdentifier: "mealPlanDinnerDetail", sender: self)
        } else {
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "You haven't selected an meal yet!"
            alert.addButton(withTitle: "Ok")
            alert.show()
            return
        }
    }
}
