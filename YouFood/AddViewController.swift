//
//  AddViewController.swift
//  YouFood
//
//  Created by Sukkwon On on 2018-07-03.
//  Copyright © 2018 Novus. All rights reserved.
//
//  Contributers: Sukkwon On, Ryan Thompson, Syou (Cloud) Kanou, Maggie Xu
//
//  Known Issues: - Text entries too large for a single tableViewCell gets cut off


import UIKit
import AVFoundation
import Photos
import Firebase

var ingredientNames: [String] = []

class AddViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    //Preparing data for the picker wheels
    
    let cuisines = ["Chinese", "Japanese", "American", "Thai", "Italian", "Greek", "Indian", "Mexican", "Vietnamese", "Mediterranean", "Other"]
    var selectedCuisine: String = "Chinese"
    
    let typeOfMeal = ["Breakfast", "Lunch", "Dinner"]
    var selectedTypeOfMeal: String = "Breakfast"
    
    var i: Int = 1
    var cookTime = [String]()
    var selectedCookTime: String = "1"
    
    var numberServings = [String]()
    var selectedNumberServings: String = "1"
    
    var quantity = ["1/8", "1/4", "1/2", "3/4", "1", "2", "3", "4", "5", "6"]
    var selectedQuantity: String = "1/8"
    
    let units = ["tsp", "tbsp", "cup", "g", "ml", "oz", "lb"]
    var selectedUnit: String = "tsp"
    
    var foodNutrientDataArray: [[String]] = []
    var nutrientData: [Nutrient] = []
    
    //MARK: Properties
    @IBOutlet weak var nameInput: UITextField!
    
    @IBOutlet weak var authorInput: UITextField!
    
    @IBOutlet weak var foodCuisinePicker: UIPickerView!
    
    @IBOutlet weak var typeOfMealPicker: UIPickerView!
    @IBOutlet weak var addTypeOfMealButton: UIButton!
    @IBOutlet weak var addTypeOfMealTable: UITableView!
    var typeOfMealData = [String]()
    
    @IBOutlet weak var cookTimePicker: UIPickerView!
    
    @IBOutlet weak var numberServingsPicker: UIPickerView!
    
    @IBOutlet weak var ingredientInput: SearchTextField!
    @IBOutlet weak var quantityPicker: UIPickerView!
    @IBOutlet weak var unitPicker: UIPickerView!
    var ingredientData = [String]()
    var quantityData = [String]()
    var unitData = [String]()
    
    @IBOutlet weak var addIngredientButton: UIButton!
    @IBOutlet weak var ingredientTable: UITableView!
    var tableData = [String]()
    
    @IBOutlet weak var directionsInput: UITextField!
    @IBOutlet weak var addDirectionsButton: UIButton!
    @IBOutlet weak var directionsTable: UITableView!
    var directionsData = [(Int, String)]()
    
    
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var userImageInput: UIImageView!
    
    @IBOutlet weak var addView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: Navigation
    @IBAction func `return`(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    // Main function for uploading recipes
    @IBAction func uploadRecipe(_ sender: UIButton) {
        
        // Check all required fields are entered
        if ((self.nameInput.text?.isEmpty ?? true) ||
            (self.typeOfMealData.count == 0) ||
            (ingredientData.count == 0) ||
            (self.directionsData.count == 0)){
            
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "Please fill all required entries"
            alert.addButton(withTitle: "Ok")
            alert.show()
            return
        }
        
        // If no author name, make it Anonymous
        if self.authorInput.text?.isEmpty ?? true{
            self.authorInput.text? = "Anonymous"
        }
        //----------------------------------------------------------------------
        //Adding user inputs into database START
        //----------------------------------------------------------------------
        
        //Get a reference to the database so we can upload to it
        let reference = Database.database().reference().child("mainstream").childByAutoId()
        
        //Load a new recipe with all the data
        let newRecipe = Recipe()
        newRecipe.title = self.nameInput.text!
        newRecipe.author = self.authorInput.text!
        newRecipe.cuisine = selectedCuisine
        newRecipe.mealType = typeOfMealData
        newRecipe.timeToCook = Int(selectedCookTime)!
        newRecipe.servings = Int(selectedNumberServings)!
        newRecipe.directions = directionsData
        
        for k in 0 ..< ingredientData.count{
            newRecipe.ingredients.append(Ingredient(name: ingredientData[k], quantity: quantityData[k], unit: unitData[k], tags: []))
        }
        
        var storedDirections: String = ""
        
        for i in 0 ..< newRecipe.directions.count{
            // Don't want a trailing comma at the end of string
            if i == newRecipe.directions.count-1{
                storedDirections += String(newRecipe.directions[i].0) + "^" + String(newRecipe.directions[i].1)
            } else{
                storedDirections += String(newRecipe.directions[i].0) + "^" + String(newRecipe.directions[i].1) + "^"
            }
        }
        
        var storedMealTypes: String = ""
        
        for i in 0 ..< newRecipe.mealType.count{
            // Don't want a trailing comma at the end of string
            if i == newRecipe.mealType.count-1{
                storedMealTypes += String(newRecipe.mealType[i])
            } else{
                storedMealTypes += String(newRecipe.mealType[i]) + ","
            }
        }
        
        var storedIngredients: String = ""
        
        for i in 0 ..< newRecipe.ingredients.count{
            // Don't want a trailing comma at the end of string
            if i == newRecipe.ingredients.count-1{
                storedIngredients += String(newRecipe.ingredients[i].name) + "," + String(newRecipe.ingredients[i].quantity) + "," + String(newRecipe.ingredients[i].unit)
            } else{
                storedIngredients += String(newRecipe.ingredients[i].name) + "," + String(newRecipe.ingredients[i].quantity) + "," + String(newRecipe.ingredients[i].unit) + ","
            }
        }
        
        var storedNutrients: String = ""
        
        for i in 0 ..< nutrientData.count{
            // Don't want a trailing comma at the end of string
            if i == nutrientData.count-1{
                storedNutrients += String(nutrientData[i].name) + "," + String(nutrientData[i].quantity) + "," + String(nutrientData[i].unit)
            } else{
                storedNutrients += String(nutrientData[i].name) + "," + String(nutrientData[i].quantity) + "," + String(nutrientData[i].unit) + ","
            }
        }
        
        
        if (userImageInput.image != nil){
            
            let imageInput:UIImage = resizeImage(image: userImageInput.image!, newWidth: CGFloat(380.0))
            
            let pixelSizeW = (imageInput.size.width) * (imageInput.scale)
            let pixelSizeH = (imageInput.size.height) * (imageInput.scale)
            
            print("------ Printing Size of the image -------")
            print(pixelSizeW)
            print(pixelSizeH)
            print("------ Printing Size of the image -------")
            
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("recipe_images").child("\(imageName).png")
            
            if let uploadData = UIImagePNGRepresentation(imageInput){
                storageRef.putData(uploadData, metadata:nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print("--------------------IMAGE ERROR---------------------")
                        print(error)
                        print("--------------------IMAGE ERROR---------------------")
                        return
                    }
                    
                    storageRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error!.localizedDescription)
                            return
                        }
                        
                        // -------- FIREBASE UPLOADING --------
                        
                        // Upload single value data such as imageID, imageURL, title, author, cuisine, timeToCook, and servings
                        if let recipeImageUrl = url?.absoluteString {
                            let storyDictionary = [
                                "key" : "\(reference.key)",
                                "imageID" : imageName,
                                "title" : "\(newRecipe.title)",
                                "author" : "\(newRecipe.author)",
                                "cuisine" : "\(newRecipe.cuisine)",
                                "timeToCook" : newRecipe.timeToCook,
                                "servings" : newRecipe.servings,
                                "recipeImageUrl" : "\(recipeImageUrl)",
                                "directions" : storedDirections,
                                "mt" : storedMealTypes,
                                "ingredients" : storedIngredients,
                                "nutrients" : storedNutrients,
                                "numLikes" : 0
                                ] as [String : Any]
                            reference.setValue(storyDictionary)
                        }
                    })
                })
            }
        } else{
            let storyDictionary = [
                "key" : "\(reference.key)",
                "imageID" : "",
                "title" : "\(newRecipe.title)",
                "author" : "\(newRecipe.author)",
                "cuisine" : "\(newRecipe.cuisine)",
                "timeToCook" : newRecipe.timeToCook,
                "servings" : newRecipe.servings,
                "recipeImageUrl" : "",
                "directions" : storedDirections,
                "mt" : storedMealTypes,
                "ingredients" : storedIngredients,
                "nutrients" : storedNutrients,
                "numLikes" : 0
                ] as [String : Any]
            reference.setValue(storyDictionary)
        }
        dismiss(animated: true, completion: nil)
        return
    }
    
    // create a method to fetch your photo asset and return an UIImage on completion
    func fetchImage(asset: PHAsset, completion: @escaping  (UIImage) -> ()) {
        let options = PHImageRequestOptions()
        options.version = .original
        PHImageManager.default().requestImageData(for: asset, options: options) {
            data, uti, orientation, info in
            guard let data = data, let image = UIImage(data: data) else { return }
            self.userImageInput.contentMode = .scaleAspectFit
            self.userImageInput.image = image
            print("image size:", image.size)
            completion(image)
        }
    }
    
    @IBAction func selectImage(_ sender: UIButton) {
        let imageController = UIImagePickerController()
        imageController.delegate = self
        imageController.allowsEditing = true
        imageController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imageController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ ingredientPicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        userImageInput.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func requestCameraPermission() {
        print("dd")
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            guard accessGranted == true else { return }
            self.presentCamera()
        })
    }
    
    func presentCamera() {
        print("dds")
        let photoPicker = UIImagePickerController()
        photoPicker.sourceType = .camera
        photoPicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        self.present(photoPicker, animated: true, completion: nil)
    }
    
    func alertCameraAccessNeeded() {
        print("ddss")
        let settingsAppURL = URL(string: UIApplicationOpenSettingsURLString)!
        
        let alert = UIAlertController(
            title: "Need Camera Access",
            message: "Camera access is required to make full use of this app.",
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         nameInput.returnKeyType = .done
         authorInput.returnKeyType = .done
         directionsInput.returnKeyType = .done
         ingredientInput.returnKeyType = .done
         */
        
        scrollView.keyboardDismissMode = .onDrag
        
        directionsTable.estimatedRowHeight = 44
        directionsTable.rowHeight = UITableViewAutomaticDimension
        
        // Keep track of total nutrients with this array for a new recipe
        nutrientData.append(Nutrient(name: "Protein", quantity: 0, unit: "g"))
        nutrientData.append(Nutrient(name: "Fat", quantity: 0, unit: "g"))
        nutrientData.append(Nutrient(name: "Carbohydrate", quantity: 0, unit: "g"))
        nutrientData.append(Nutrient(name: "Calories", quantity: 0, unit: "kcal"))
        nutrientData.append(Nutrient(name: "Fibre", quantity: 0, unit: "g"))
        nutrientData.append(Nutrient(name: "Sugar", quantity: 0, unit: "g"))
        nutrientData.append(Nutrient(name: "Calcium", quantity: 0, unit: "mg"))
        nutrientData.append(Nutrient(name: "Iron", quantity: 0, unit: "mg"))
        nutrientData.append(Nutrient(name: "Magnesium", quantity: 0, unit: "mg"))
        nutrientData.append(Nutrient(name: "Potassium", quantity: 0, unit: "mg"))
        nutrientData.append(Nutrient(name: "Sodium", quantity: 0, unit: "mg"))
        nutrientData.append(Nutrient(name: "Vitamin C", quantity: 0, unit: "mg"))
        nutrientData.append(Nutrient(name: "Vitamin D", quantity: 0, unit: "IU"))
        nutrientData.append(Nutrient(name: "Vitamin K", quantity: 0, unit: "IU"))
        nutrientData.append(Nutrient(name: "B-6", quantity: 0, unit: "mg"))
        nutrientData.append(Nutrient(name: "B-12", quantity: 0, unit: "ug"))
        nutrientData.append(Nutrient(name: "Saturated Fat", quantity: 0, unit: "g"))
        
        //Converting FoodNutrientFile's csv into an array of food and their respective nutrients
        foodNutrientDataArray = foodNutrientDataString.components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
        
        //Preparing data for the picker wheels
        while i <= 120 {
            cookTime.append("\(i)")
            i = i+1
        }
        i = 1
        while i <= 12{
            numberServings.append("\(i)")
            i = i+1
        }
        
        //Preparing suggestions for the SearchTextField (autocomplete suggestions)
        ingredientNames = []
        for k in 0 ..< foodNutrientDataArray.count{
            ingredientNames.append(foodNutrientDataArray[k][0].lowercased())
        }
        ingredientInput.filterStrings(ingredientNames)
        
        //set UI for ingredients search results
        ingredientInput.theme = SearchTextFieldTheme.lightTheme()
        ingredientInput.theme.font = UIFont.systemFont(ofSize: 14)
        ingredientInput.theme.bgColor = UIColor (red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        ingredientInput.maxNumberOfResults = 10
        
        //Setting up relationships of buttons to functions
        
        addTypeOfMealButton.setTitle("+add", for: UIControlState.normal)
        addTypeOfMealButton.addTarget(self, action: #selector(addTypeOfMealButtonAction(_:)), for: .touchUpInside)
        
        addIngredientButton.setTitle("+add", for: UIControlState.normal)
        addIngredientButton.addTarget(self, action: #selector(addIngredientButtonAction(_:)), for: .touchUpInside)
        
        addDirectionsButton.setTitle("+add", for: UIControlState.normal)
        addDirectionsButton.addTarget(self, action: #selector(addDirectionsButtonAction(_:)), for: .touchUpInside)
        
        addImageButton.setTitle("+add", for: UIControlState.normal)
        
        //Setting delegate and data source for ALL pickers and tableviews
        
        foodCuisinePicker.delegate = self
        foodCuisinePicker.dataSource = self
        
        typeOfMealPicker.delegate = self
        typeOfMealPicker.dataSource = self
        addTypeOfMealTable.delegate = self
        addTypeOfMealTable.dataSource = self
        
        cookTimePicker.delegate = self
        cookTimePicker.dataSource = self
        
        numberServingsPicker.delegate = self
        numberServingsPicker.dataSource = self
        
        directionsTable.delegate = self
        directionsTable.dataSource = self
        
        quantityPicker.delegate = self
        quantityPicker.dataSource = self
        
        unitPicker.delegate = self
        unitPicker.dataSource = self
        
        ingredientTable.dataSource = self
        ingredientTable.delegate = self
    }
    
    @objc func addTypeOfMealButtonAction(_ sender: UIButton?){
        if addTypeOfMealTable.isEditing{
            return
        }
        
        //If you try to put in the same time of day again, throw an alert
        if typeOfMealData.contains(selectedTypeOfMeal){
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "\"\(selectedTypeOfMeal)\" has already been added!"
            alert.addButton(withTitle: "Ok")
            alert.show()
            return
        }
        
        //Add to data and display on table
        let indexPath:IndexPath = IndexPath(row: 0, section: 0)
        typeOfMealData.insert(selectedTypeOfMeal, at: 0)
        addTypeOfMealTable.insertRows(at: [indexPath], with: .automatic)
        addTypeOfMealTable.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }
    
    @objc func addIngredientButtonAction(_ sender: UIButton?){
        if ingredientTable.isEditing{
            return
        }
        //If text input is empty, throw an alert
        if self.ingredientInput.text?.isEmpty ?? true {
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "Please enter an ingredient!"
            alert.addButton(withTitle: "Ok")
            alert.show()
            return
        }
        
        // Searching for the queried food
        // Query must come from an autocomplete suggestion
        var found = false
        let query = self.ingredientInput.text!
        var currentFood: String
        for k in 0 ..< foodNutrientDataArray.count{
            currentFood = foodNutrientDataArray[k][0].lowercased()
            
            // If found, add all relevant data to arrays ingredientData, quantityData, and unitData
            if (currentFood == query || currentFood == query.lowercased()){
                ingredientData.insert(currentFood, at: 0)
                quantityData.insert(selectedQuantity, at: 0)
                unitData.insert(selectedUnit, at: 0)
                let temp = "\(currentFood) - \(selectedQuantity) \(selectedUnit)"
                let indexPath:IndexPath = IndexPath(row: 0, section: 0)
                tableData.insert(temp, at: 0)
                ingredientTable.insertRows(at: [indexPath], with: .automatic)
                ingredientTable.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                found = true
            }
        }
        
        // else, throw up an error
        if !found{
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "Please select a suggested item"
            alert.addButton(withTitle: "Ok")
            alert.show()
            return
        }
        
        // calculate nutrient of ingredients
        let query2 = self.ingredientInput.text!
        var currentFood2: String = ""
        var multiplier: Float = 0
        var amountString: String = ""
        var amount: Float = 0
        
        for k in 0 ..< foodNutrientDataArray.count{
            currentFood2 = foodNutrientDataArray[k][0].lowercased()
            
            if (currentFood2 == query2 || currentFood2 == query2.lowercased()){
                
                // if ingredient is a liquid
                if (foodNutrientDataArray[k][18] == "1"){
                    if (self.selectedUnit == "ml"){
                        multiplier = 1
                    } else if (self.selectedUnit == "cup"){
                        multiplier = 236.0588
                    } else if (self.selectedUnit == "tbsp"){
                        multiplier = 14.7868
                    } else if (self.selectedUnit == "tsp"){
                        multiplier = 4.9289
                    }
                }
                    
                    // else, ingredient is a solid
                else{
                    if (self.selectedUnit == "g"){
                        multiplier = 1
                    } else if (self.selectedUnit == "oz"){
                        multiplier = 28.2395
                    } else if (self.selectedUnit == "lb"){
                        multiplier = 543.592
                    } else if (self.selectedUnit == "cup"){
                        multiplier = 226.8
                    } else if (self.selectedUnit == "tsp"){
                        multiplier = 4.76666666
                    } else if (self.selectedUnit == "tbsp"){
                        multiplier = 14.3
                    }
                }
                
                // calculate scaled quantity of nutrients
                amountString = self.selectedQuantity
                
                if (amountString == "1/8"){
                    amount = 0.125
                } else if (amountString == "1/4"){
                    amount = 0.25
                } else if (amountString == "1/3"){
                    amount = 0.3333333333333333
                } else if (amountString == "1/2"){
                    amount = 0.5
                } else if (amountString == "2/3"){
                    amount = 0.6666666666666
                } else if (amountString == "3/4"){
                    amount = 0.75
                } else {
                    amount = Float(amountString)!
                }
                
                for j in 1 ..< 18{
                    nutrientData[j-1].quantity += Float(foodNutrientDataArray[k][j])! * multiplier * amount
                }
                break
            }
        }
        /* Uncomment to make sure nutrients are correct values when excel has been updated
         for k in 0 ..< nutrientData.count {
         print(nutrientData[k].name)
         print(nutrientData[k].quantity)
         print(nutrientData[k].unit)
         }
         */
        self.ingredientInput.text = ""
    }
    
    @objc func addDirectionsButtonAction(_ sender: UIButton?){
        if directionsTable.isEditing{
            return
        }
        if self.directionsInput.text?.isEmpty ?? true {
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "Please enter a direction!"
            alert.addButton(withTitle: "Ok")
            alert.show()
            return
        }
        
        let indexPath:IndexPath = IndexPath(row: directionsData.count, section: 0)
        directionsData.append((0, self.directionsInput.text!))
        directionsTable.insertRows(at: [indexPath], with: .automatic)
        directionsTable.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        self.directionsInput.text = ""
    }
    
    //MARK:- UIPickerViewDataSource methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // Only one coloumn for each picker
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // Setting up number of options each picker has
        if pickerView == foodCuisinePicker{
            return cuisines.count
        } else if pickerView == typeOfMealPicker{
            return typeOfMeal.count
        } else if pickerView == cookTimePicker{
            return cookTime.count
        } else if pickerView == numberServingsPicker{
            return numberServings.count
        } else if pickerView == quantityPicker{
            return quantity.count
        } else if pickerView == unitPicker{
            return units.count
        }
        return 0
    }
    
    //MARK:- UIPickerViewDelegates methods
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Setting up the labels for each option in each picker
        if pickerView == foodCuisinePicker{
            return cuisines[row]
        } else if pickerView == typeOfMealPicker{
            return typeOfMeal[row]
        } else if pickerView == cookTimePicker{
            return cookTime[row]
        } else if pickerView == numberServingsPicker{
            return numberServings[row]
        } else if pickerView == quantityPicker{
            return quantity[row]
        } else if pickerView == unitPicker{
            return units[row]
        }
        return cuisines[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Managing which values change depending on which picker was moved
        if pickerView == foodCuisinePicker{
            selectedCuisine = cuisines[pickerView.selectedRow(inComponent: 0)]
        } else if pickerView == typeOfMealPicker{
            selectedTypeOfMeal = typeOfMeal[pickerView.selectedRow(inComponent: 0)]
        } else if pickerView == cookTimePicker{
            selectedCookTime = cookTime[pickerView.selectedRow(inComponent: 0)]
        } else if pickerView == numberServingsPicker{
            selectedNumberServings = numberServings[pickerView.selectedRow(inComponent: 0)]
        } else if pickerView == quantityPicker{
            selectedQuantity = quantity[pickerView.selectedRow(inComponent: 0)]
        } else if pickerView == unitPicker{
            
            // Quantity of a unit changes depending on the selected unit
            selectedUnit = units[pickerView.selectedRow(inComponent: 0)]
            if (selectedUnit == "tsp"){
                
                // Options for the picker
                quantity = ["1/8", "1/4", "1/2", "3/4", "1", "2", "3", "4", "5", "6"]
                
                // Default value
                selectedQuantity = "1/8"
                
                // Refresh picker
                quantityPicker.reloadAllComponents()
                
                // Select the 0th row to reset
                quantityPicker.selectRow(0, inComponent: 0, animated: true)
                
            } else if (selectedUnit == "tbsp"){
                quantity = ["1/8", "1/4", "1/2", "3/4", "1", "2", "3", "4", "5", "6"]
                selectedQuantity = "1/8"
                quantityPicker.reloadAllComponents()
                quantityPicker.selectRow(0, inComponent: 0, animated: true)
            } else if (selectedUnit == "cup"){
                quantity = ["1/4", "1/3", "1/2", "2/3", "3/4", "1", "2", "3", "4", "5", "6"]
                selectedQuantity = "1/4"
                quantityPicker.reloadAllComponents()
                quantityPicker.selectRow(0, inComponent: 0, animated: true)
            } else if (selectedUnit == "g" || selectedUnit == "ml"){
                quantity = []
                i = 10
                while i <= 1000{
                    quantity.append("\(i)")
                    i = i+10
                }
                selectedQuantity = "10"
                quantityPicker.reloadAllComponents()
                quantityPicker.selectRow(0, inComponent: 0, animated: true)
            } else if (selectedUnit == "oz"){
                quantity = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16"]
                selectedQuantity = "1"
                quantityPicker.reloadAllComponents()
                quantityPicker.selectRow(0, inComponent: 0, animated: true)
            } else if (selectedUnit == "lb"){
                quantity = ["1/4", "1/3", "1/2", "2/3", "3/4", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
                selectedQuantity = "1/4"
                quantityPicker.reloadAllComponents()
                quantityPicker.selectRow(0, inComponent: 0, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Setting up how many cells should be in each tableView
        // This is updated everytime an entry is added to typeOfMeal, ingredientTable, or directionsTable
        if tableView == addTypeOfMealTable{
            return typeOfMealData.count
        } else if tableView == ingredientTable{
            return tableData.count
        } else if tableView == directionsTable{
            return directionsData.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        // Setting up what each cell should say in each tableView
        if tableView == addTypeOfMealTable{
            cell.textLabel?.text = typeOfMealData[indexPath.row]
        } else if tableView == ingredientTable{
            cell.textLabel?.text = tableData[indexPath.row]
        } else if tableView == directionsTable{
            var label = cell.textLabel!
            label.numberOfLines = 0
            label.text = directionsData[indexPath.row].1
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Implements deleting cells in tableViews
        if tableView == addTypeOfMealTable{
            typeOfMealData.remove(at: indexPath.row)
            addTypeOfMealTable.deleteRows(at: [indexPath], with: .fade)
        } else if tableView == ingredientTable{
            tableData.remove(at: indexPath.row)
            ingredientData.remove(at: indexPath.row)
            quantityData.remove(at: indexPath.row)
            unitData.remove(at: indexPath.row)
            ingredientTable.deleteRows(at: [indexPath], with: .fade)
        } else if tableView == directionsTable{
            directionsData.remove(at: indexPath.row)
            directionsTable.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        // Implements the UI for deleting cells in tableViews
        super.setEditing(editing, animated: animated)
        addTypeOfMealTable.setEditing(editing, animated: animated)
        ingredientTable.setEditing(editing, animated: animated)
        directionsTable.setEditing(editing, animated: animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

