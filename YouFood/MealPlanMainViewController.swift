
//
//  MealPlanMainViewController.swift
//  YouFood
////  Created by XuMaggie on /07/1218.
//  Copyright © 2018年 Novus. All rights reserved.
//
// Contributers: Maggie Xu, Syou (Cloud) Kanou, Ryan Thompson
//

import UIKit
import Foundation
import CoreData

//global counter
var counter = 0

class MealPlanMainViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,DataEnteredDelegate{
    
    var searches = [DateCollectionViewCell]()
	
    @IBOutlet var nutritionCollectionView: UICollectionView?
	@IBOutlet var calendarCollectionView: UICollectionView?
	@IBOutlet var MonthLabel: UILabel?
	
    @IBAction func AddBreakfast(_ sender: UIButton) {
        counter = 1
    }
    @IBAction func AddLunch(_ sender: UIButton) {
        counter = 2
    }
    @IBAction func AddDinner(_ sender: UIButton) {
        counter = 3
    }

    @IBAction func deleteBreakfast(_ sender: UIButton) {
        if todaysMealPlan.breakfast == nil{
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "There's nothing to delete!"
            alert.addButton(withTitle: "Ok")
            alert.show()
            return
        } else{
            deleteFromCoreData(entityName: "MealPlanBreakfast")
            todaysMealPlan.breakfast = nil
            breakfastSelection.text = "Nothing Selected"
            getNutrientsFromTodaysMealPlan(todaysMealPlan: todaysMealPlan)
        }
    }
    
    @IBAction func deleteLunch(_ sender: Any) {
        if todaysMealPlan.lunch == nil{
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "There's nothing to delete!"
            alert.addButton(withTitle: "Ok")
            alert.show()
            return
        } else{
            deleteFromCoreData(entityName: "MealPlanLunch")
            todaysMealPlan.lunch = nil
            lunchSelection.text = "Nothing Selected"
            getNutrientsFromTodaysMealPlan(todaysMealPlan: todaysMealPlan)
        }
    }
    @IBAction func deleteDinner(_ sender: Any) {
        if todaysMealPlan.dinner == nil{
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "There's nothing to delete!"
            alert.addButton(withTitle: "Ok")
            alert.show()
            return
        } else{
            deleteFromCoreData(entityName: "MealPlanDinner")
            todaysMealPlan.dinner = nil
            dinnerSelection.text = "Nothing Selected"
            getNutrientsFromTodaysMealPlan(todaysMealPlan: todaysMealPlan)
        }
    }
    
    
    
    @IBOutlet weak var breakfastSelection: UILabel!
    @IBOutlet weak var lunchSelection: UILabel!
    @IBOutlet weak var dinnerSelection: UILabel!
    
    
    var todaysMealPlan = oneDayMealPlan()
    
    func userDidEnterInformation(mealPlanRecipe: Recipe) {
        var entityName: String
        //print(counter)
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
        
        deleteFromCoreData(entityName: entityName)
        
        saveToCoreData(entityName: entityName, mealPlanRecipe: mealPlanRecipe)
        
        getNutrientsFromTodaysMealPlan(todaysMealPlan: todaysMealPlan)
    }
    
    
    func deleteFromCoreData(entityName: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                context.delete(data)
            }
        } catch {
            print("Failed")
        }
        do {
            try context.save()
        } catch {
            print("Save Error")
        }
    }
    
    func saveToCoreData(entityName: String, mealPlanRecipe: Recipe){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        let newRecipe = NSManagedObject(entity: entity!, insertInto: context)
        newRecipe.setValue("\(mealPlanRecipe.title)", forKey: "title")
        newRecipe.setValue("\(mealPlanRecipe.author)", forKey: "author")
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func getNutrientsFromTodaysMealPlan(todaysMealPlan: oneDayMealPlan) {
        todaysMealPlan.totalNutrients = []
        for i in 0 ..< foodNutrientLabels.count{
            todaysMealPlan.totalNutrients.append(0)
        }
        
        if (self.breakfastSelection.text != "Nothing Selected"){
            for i in 0 ..< todaysMealPlan.totalNutrients.count{
                todaysMealPlan.totalNutrients[i] += todaysMealPlan.breakfast!.nutrients[i].quantity/Float(todaysMealPlan.breakfast!.servings)
            }
        }
        if (self.lunchSelection.text != "Nothing Selected"){
            for i in 0 ..< todaysMealPlan.totalNutrients.count{
                todaysMealPlan.totalNutrients[i] += todaysMealPlan.lunch!.nutrients[i].quantity/Float(todaysMealPlan.lunch!.servings)
            }
        }
        if (self.dinnerSelection.text != "Nothing Selected"){
            for i in 0 ..< todaysMealPlan.totalNutrients.count{
                todaysMealPlan.totalNutrients[i] += todaysMealPlan.dinner!.nutrients[i].quantity/Float(todaysMealPlan.dinner!.servings)
            }
        }
        
        for i in 0 ..< todaysMealPlan.totalNutrients.count{
            nutritions[i].percentage = CGFloat(todaysMealPlan.totalNutrients[i]/nutritions[i].recommendedDailyAmount!)
        }
        nutritionCollectionView?.reloadData()
    }
	
	
    var nutritions:[Nutrition] = {
        var protein = Nutrition()
        protein.title = "Protein"
        protein.recommendedDailyAmount = 51
        protein.trackColor = UIColor(white: 255/255, alpha: 0.2)
        protein.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        //protein.percentage = proteinPC
        protein.percentage = 0
        
        var fat = Nutrition()
        fat.title = "Fat"
        fat.recommendedDailyAmount = 66
        fat.trackColor = UIColor(white: 255/255, alpha: 0.2)
        fat.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        //fat.percentage = fatPC
        fat.percentage = 0
        
        var Carbs = Nutrition()
        Carbs.title = "Carbohydrates"
        Carbs.recommendedDailyAmount = 275
        Carbs.trackColor = UIColor(white: 255/255, alpha: 0.2)
        Carbs.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        //Carbs.percentage = carbonhydratePC
        Carbs.percentage = 0
        
        var calories = Nutrition()
        calories.title = "KCalories"
        calories.recommendedDailyAmount = 2000
        calories.trackColor = UIColor(white: 255/255, alpha: 0.2)
        calories.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        //calories.percentage = caloriesPC
        calories.percentage = 0
        
        var fiber = Nutrition()
        fiber.title = "Fiber"
        fiber.recommendedDailyAmount = 26.5
        fiber.trackColor = UIColor(white: 255/255, alpha: 0.2)
        fiber.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        //fiber.percentage = fiberPC
        fiber.percentage = 0
        
        var sugar = Nutrition()
        sugar.title = "Sugar"
        sugar.recommendedDailyAmount = 25
        sugar.trackColor = UIColor(white: 255/255, alpha: 0.2)
        sugar.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        //sugar.percentage = sugarPC
        sugar.percentage = 0
        
        var calcium = Nutrition()
        calcium.title = "Calcium"
        calcium.recommendedDailyAmount = 780
        calcium.trackColor = UIColor(white: 255/255, alpha: 0.2)
        calcium.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        //calcium.percentage = calciumPC
        calcium.percentage = 0
        
        var iron = Nutrition()
        iron.title = "Iron"
        iron.recommendedDailyAmount = 10
        iron.trackColor = UIColor(white: 255/255, alpha: 0.2)
        iron.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        //iron.percentage = ironPC
        iron.percentage = 0
        
        var magnesium = Nutrition()
        magnesium.title = "Magnesium"
        magnesium.recommendedDailyAmount = 210
        magnesium.trackColor = UIColor(white: 255/255, alpha: 0.2)
        magnesium.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        //magnesium.percentage = magnesiumPC
        magnesium.percentage = 0
        
        var potassium = Nutrition()
        potassium.title = "Potassium"
        potassium.recommendedDailyAmount = 4500
        potassium.trackColor = UIColor(white: 255/255, alpha: 0.2)
        potassium.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        //potassium.percentage = potassiumPC
        potassium.percentage = 0
        
        var sodium = Nutrition()
        sodium.title = "Sodium"
        sodium.recommendedDailyAmount = 1500
        sodium.trackColor = UIColor(white: 255/255, alpha: 0.2)
        sodium.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        //sodium.percentage = sodiumPC
        sodium.percentage = 0
        
        var vitaminC = Nutrition()
        vitaminC.title = "Vitamin C"
        vitaminC.recommendedDailyAmount = 34
        vitaminC.trackColor = UIColor(white: 255/255, alpha: 0.2)
        vitaminC.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        //vitaminC.percentage = vitaminCPC
        vitaminC.percentage = 0
        
        var vitaminD = Nutrition()
        vitaminD.title = "Vitamin D"
        vitaminD.recommendedDailyAmount = 120
        vitaminD.trackColor = UIColor(white: 255/255, alpha: 0.2)
        vitaminD.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        //vitaminD.percentage = vitaminDPC
        vitaminD.percentage = 0
        
        var vitaminK = Nutrition()
        vitaminK.title = "Vitamin K"
        vitaminK.recommendedDailyAmount = 105
        vitaminK.trackColor = UIColor(white: 255/255, alpha: 0.2)
        vitaminK.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        //vitamink.percentage = vitaminkPC
        vitaminK.percentage = 0
        
        var vitaminB6 = Nutrition()
        vitaminB6.title = "Vitamin B-6"
        vitaminB6.recommendedDailyAmount = 1
        vitaminB6.trackColor = UIColor(white: 255/255, alpha: 0.2)
        vitaminB6.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        //vitaminB6.percentage = vitaminB6PC
        vitaminB6.percentage = 0
        
        var vitaminB12 = Nutrition()
        vitaminB12.title = "Vitamin B-12"
        vitaminB12.recommendedDailyAmount = 1
        vitaminB12.trackColor = UIColor(white: 255/255, alpha: 0.2)
        vitaminB12.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        //vitaminB12.percentage = vitaminB12PC
        vitaminB12.percentage = 0
        
        var saturatedFat = Nutrition()
        saturatedFat.title = "Saturated Fat"
        saturatedFat.recommendedDailyAmount = 22.4
        saturatedFat.trackColor = UIColor(white: 255/255, alpha: 0.2)
        saturatedFat.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        //saturatedFat.percentage = saturatedFatPC
        saturatedFat.percentage = 0
        
        var filler = Nutrition()
        filler.title = ""
        filler.trackColor = UIColor(white: 255/255, alpha: 0.2)
        filler.shapeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        filler.percentage = 0

        return [protein, fat, Carbs, calories, fiber, sugar, calcium, iron, magnesium, potassium, sodium, vitaminC, vitaminD, vitaminK, vitaminB6, vitaminB12, saturatedFat, filler, filler, filler]
        
    }()
    
	
	let Months = ["January","February","March","April","May","June","July","August","September","October","November","December"]
	
	var DaysInMonths = [31,28,31,30,31,30,31,31,30,31,30,31]
	
	var currentMonth = String()
	
	var Direction = 0
	
	var LeapYearCounter = 2
	
	var dayCounter = 0
	
	var day = Calendar.current.component(.day , from: Date())
	var weekday = Calendar.current.component(.weekday, from: Date())
	var month = Calendar.current.component(.month, from: Date())
	var year = Calendar.current.component(.year, from: Date())
	
	
	
	
	
	
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
			
			currentMonth = Months[month - 1]
			MonthLabel?.text = "\(currentMonth) \(year)"
			calendarCollectionView?.reloadData()
		default:
			Direction = 1
			month += 1
			
			currentMonth = Months[month - 1]
			MonthLabel?.text = "\(currentMonth) \(year)"
			calendarCollectionView?.reloadData()
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
			
			currentMonth = Months[month - 1]
			MonthLabel?.text = "\(currentMonth) \(year)"
			calendarCollectionView?.reloadData()
			
		default:
			Direction = -1
			
			month -= 1
			
			currentMonth = Months[month - 1]
			MonthLabel?.text = "\(currentMonth) \(year)"
			calendarCollectionView?.reloadData()
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch collectionView.tag {
		case 0:
			//print(nutritions.count)
			return nutritions.count
			
			
		case 1:
			print(DaysInMonths[month - 1])
			print(day)
			
			return DaysInMonths[month - 1]
			
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
			
			let components = DateComponents(year: year, month: month, day: indexPath.item + 1)
			let theDay = Calendar.current.date(from: components)
			
			if Calendar.current.isDateInWeekend(theDay!){
				cellB.DateLabel.textColor = UIColor.lightGray
				print("weekend")
			}else{
				cellB.DateLabel.textColor = UIColor.black
				print("weekday")
			}
			print("\(indexPath.item + 1)")
			print(cellB.DateLabel.text)
            
            /*
            let tapOnDate = UITapGestureRecognizer(target: self, action: #selector(MealPlanMainViewController.tapDate))
            cellB.isUserInteractionEnabled = true
            cellB.addGestureRecognizer(tapOnDate)
            */
			
			//if currentMonth == Months[Calendar.current.component(.month, from: Date()) - 1] && syear == Calendar.current.component(.year, from: Date()) && indexPath.item + 1 == day {
            print("!\(indexPath.row) \(day)")
			if indexPath.row+1 == day{
                print("!ON THE SAME DAY")
				collectionView.selectItem(at: IndexPath(row: indexPath.row+1, section: 0), animated: false, scrollPosition: [])
                 calendarCollectionView?.cellForItem(at: IndexPath(row: indexPath.row+1, section: 0))?.backgroundColor = UIColor.cyan
			}
			return cellB
			
		default:
			fatalError()
		}
		
	}
    override func viewDidLoad() {
        
		super.viewDidLoad()
		
        // Set up coredata
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Load data from core data if there is anything there
        let requestBreakfast = NSFetchRequest<NSFetchRequestResult>(entityName: "MealPlanBreakfast")
        requestBreakfast.returnsObjectsAsFaults = false
        let requestLunch = NSFetchRequest<NSFetchRequestResult>(entityName: "MealPlanLunch")
        requestLunch.returnsObjectsAsFaults = false
        let requestDinner = NSFetchRequest<NSFetchRequestResult>(entityName: "MealPlanDinner")
        requestDinner.returnsObjectsAsFaults = false
        do {
            let resultBreakfast = try context.fetch(requestBreakfast)
            let resultLunch = try context.fetch(requestLunch)
            let resultDinner = try context.fetch(requestDinner)
            for data in resultBreakfast as! [NSManagedObject] {
                let searchTitle = data.value(forKey: "title") as! String
                let searchAuthor = data.value(forKey: "author") as! String
                for i in 0 ..< testRecipes.count{
                    if (testRecipes[i].title == searchTitle && testRecipes[i].author == searchAuthor){
                        todaysMealPlan.breakfast = testRecipes[i]
                        self.breakfastSelection.text = todaysMealPlan.breakfast?.title
                    }
                }
            }
            for data in resultLunch as! [NSManagedObject] {
                let searchTitle = data.value(forKey: "title") as! String
                let searchAuthor = data.value(forKey: "author") as! String
                for i in 0 ..< testRecipes.count{
                    if (testRecipes[i].title == searchTitle && testRecipes[i].author == searchAuthor){
                        todaysMealPlan.lunch = testRecipes[i]
                        self.lunchSelection.text = todaysMealPlan.lunch?.title
                    }
                }
            }
            for data in resultDinner as! [NSManagedObject] {
                let searchTitle = data.value(forKey: "title") as! String
                let searchAuthor = data.value(forKey: "author") as! String
                for i in 0 ..< testRecipes.count{
                    if (testRecipes[i].title == searchTitle && testRecipes[i].author == searchAuthor){
                        todaysMealPlan.dinner = testRecipes[i]
                        self.dinnerSelection.text = todaysMealPlan.dinner?.title
                    }
                }
            }
            getNutrientsFromTodaysMealPlan(todaysMealPlan: todaysMealPlan)
        } catch {
            print("Error")
        }
        let tapOnBreakfast = UITapGestureRecognizer(target: self, action: #selector(MealPlanMainViewController.tapBreakfast))
        breakfastSelection.isUserInteractionEnabled = true
        breakfastSelection.addGestureRecognizer(tapOnBreakfast)
        
        let tapOnLunch = UITapGestureRecognizer(target: self, action: #selector(MealPlanMainViewController.tapLunch))
        lunchSelection.isUserInteractionEnabled = true
        lunchSelection.addGestureRecognizer(tapOnLunch)
        
        let tapOnDinner = UITapGestureRecognizer(target: self, action: #selector(MealPlanMainViewController.tapDinner))
        dinnerSelection.isUserInteractionEnabled = true
        dinnerSelection.addGestureRecognizer(tapOnDinner)
        
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

		self.view.addSubview(nutritionCollectionView!)
		self.view.addSubview(calendarCollectionView!)
		
		if (calendarCollectionView == nil){
			print("calendar nil")
		}
        
		currentMonth = Months[month - 1]
		MonthLabel?.text = "\(currentMonth) \(year)"
        
        print(day)
        calendarCollectionView?.allowsMultipleSelection = false
        calendarCollectionView?.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: [])
        calendarCollectionView?.cellForItem(at: IndexPath(row: 0, section: 0))?.backgroundColor = UIColor.cyan
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == nutritionCollectionView {
            return
        }
        print(indexPath)
        collectionView.cellForItem(at: indexPath as IndexPath)?.backgroundColor = UIColor.cyan
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! DateCollectionViewCell
        print(cell.DateLabel.text)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == nutritionCollectionView {
            return
        }
        collectionView.cellForItem(at: indexPath as IndexPath)?.backgroundColor = UIColor.clear
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
    
    @objc func tapDate(cell:DateCollectionViewCell, sender:UITapGestureRecognizer){
        print ("Hello")
        print(cell.DateLabel.text)
    }
}



