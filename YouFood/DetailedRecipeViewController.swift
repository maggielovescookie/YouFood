//
//  ViewController.swift
//  YouFood
//
//  Created by ckanou on 6/27/18.
//  Copyright © 2018 Novus. All rights reserved.
//
//  Contributors to this file: Cloud (Syou) Kanou, Maggie Xu, Sukkwon On
//

import UIKit
import CoreData
import Firebase

class DetailedRecipeViewController: UIViewController {
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var numLikesLabel: UILabel!
    //MARK: Properties
    
    var recipe: Recipe?
    @IBOutlet weak var titleLabel2: UILabel!
    @IBOutlet weak var authorLabel2: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var servingsLabel: UILabel!
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var ratingStackView: RatingController!
    @IBOutlet weak var ingredientDirectionNutritionInformation: UITextView!
    
    @IBAction func reportRecipe(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["cloud.kanou@gmail.com"])
            mail.setSubject("A recipe from YouFood has been reported")
            mail.setMessageBody("A recipe has been reported!\nTitle: \(recipe!.title)\nAuthor: \(recipe!.author)", isHTML: false)
            present(mail, animated: true)
        } else {
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "Your device is not set up to send emails"
            alert.addButton(withTitle: "Ok")
            alert.show()
            return
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    // If a user favorites this recipe, upload the whole recipe under the users unique ID
    @IBAction func buttonIsTapped(_ sender: UIButton) {
        if let recipe = recipe{
            let key:String = recipe.key
            
            let reference = Database.database().reference().child("mainstream").child(key).child("author")
            if favoriteButton.isSelected == false {
                favoriteButton.isSelected = true
                let user = Auth.auth().currentUser
                if let user = user
                {
                    let uid:String = user.uid
                    var ref: DatabaseReference!
                    ref = Database.database().reference()
                    
                    ref.child("mainstream").child(recipe.key).observeSingleEvent(of: .value, with: { (snapshot) in
                        // Get user value
                        let value = snapshot.value as? NSDictionary
                        var numLikes = value?["numLikes"] as? Int ?? -1
                        
                        numLikes += 1
                        recipe.numLikes = numLikes
                        ref.child("mainstream").child(recipe.key).child("numLikes").setValue(numLikes)
                        self.numLikesLabel.text = "\(numLikes) Likes"
                        // ...
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                    
                    var storedDirections: String = ""
                    
                    for i in 0 ..< recipe.directions.count{
                        // Don't want a trailing comma at the end of string
                        if i == recipe.directions.count-1{
                            storedDirections += String(recipe.directions[i].0) + "^" + String(recipe.directions[i].1)
                        } else{
                            storedDirections += String(recipe.directions[i].0) + "^" + String(recipe.directions[i].1) + "^"
                        }
                    }
                    
                    var storedMealTypes: String = ""
                    
                    for i in 0 ..< recipe.mealType.count{
                        // Don't want a trailing comma at the end of string
                        if i == recipe.mealType.count-1{
                            storedMealTypes += String(recipe.mealType[i])
                        } else{
                            storedMealTypes += String(recipe.mealType[i]) + ","
                        }
                    }
                    
                    var storedIngredients: String = ""
                    
                    for i in 0 ..< recipe.ingredients.count{
                        // Don't want a trailing comma at the end of string
                        if i == recipe.ingredients.count-1{
                            storedIngredients += String(recipe.ingredients[i].name) + "," + String(recipe.ingredients[i].quantity) + "," + String(recipe.ingredients[i].unit)
                        } else{
                            storedIngredients += String(recipe.ingredients[i].name) + "," + String(recipe.ingredients[i].quantity) + "," + String(recipe.ingredients[i].unit) + ","
                        }
                    }
                    
                    //**************************************************************
                    var storedNutrients: String = ""
                    
                    for i in 0 ..< recipe.nutrients.count{
                        // Don't want a trailing comma at the end of string
                        if i == recipe.nutrients.count-1{
                            storedNutrients += String(recipe.nutrients[i].name) + "," + String(recipe.nutrients[i].quantity) + "," + String(recipe.nutrients[i].unit)
                        } else{
                            storedNutrients += String(recipe.nutrients[i].name) + "," + String(recipe.nutrients[i].quantity) + "," + String(recipe.nutrients[i].unit) + ","
                        }
                    }
                    //**************************************************************
                    
                    let storyDictionary = [
                        "key" : "\(recipe.key)",
                        "imageID" : "\(recipe.imageID)",
                        "title" : "\(recipe.title)",
                        "author" : "\(recipe.author)",
                        "cuisine" : "\(recipe.cuisine)",
                        "timeToCook" : recipe.timeToCook,
                        "servings" : recipe.servings,
                        "recipeImageUrl" : recipe.recipeImageUrl,
                        "directions" : storedDirections,
                        "mt" : storedMealTypes,
                        "ingredients" : storedIngredients,
                        "nutrients" : storedNutrients,
                        "numLikes" : recipe.numLikes
                        ] as [String : Any]
                    ref.child("users").child(uid).child("favorite").child(recipe.key).setValue(storyDictionary)
                }
            }
            else {
                favoriteButton.isSelected = false
                let user = Auth.auth().currentUser
                if let user = user
                {
                    let uid:String = user.uid
                    var ref: DatabaseReference!
                    ref = Database.database().reference()
                    //----------------------------------------------------------
                    //Remove from favorite array in users
                    //----------------------------------------------------------
                    let referenceToBeRemoved = ref.child("users").child(uid).child("favorite").child(recipe.key)
                    referenceToBeRemoved.setValue(nil)
                    
                    //----------------------------------------------------------
                    //Decrease numLikes of the recipe
                    //----------------------------------------------------------
                    ref.child("mainstream").child(recipe.key).observeSingleEvent(of: .value, with: { (snapshot) in
                        // Get user value
                        let value = snapshot.value as? NSDictionary
                        var numLikes = value?["numLikes"] as? Int ?? -1
                        
                        if(numLikes < 0)
                        {
                            print("DetailedRecipeViewController - error : if(numLikes < 0)")
                            numLikes = 0
                        }
                        else {
                            numLikes -= 1
                        }
                        recipe.numLikes = numLikes
                        ref.child("mainstream").child(recipe.key).child("numLikes").setValue(numLikes)
                        self.numLikesLabel.text = "\(numLikes) Likes"
                        // ...
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    //MARK: Navigation
    @IBAction func `return`(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Displaying all the data from any given recipe.
        
        // textBody is where all the text is held while data is still being converted to strings
        let textBody = NSMutableAttributedString(string: "", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)])
        var infoText: NSMutableAttributedString
        var headerText: NSMutableAttributedString
        
        if let recipe = recipe{
            
            if recipe.actualImage != nil{
                recipeImage.image = recipe.actualImage!
            }
            
            var ref: DatabaseReference!
            ref = Database.database().reference()
            ref.child("mainstream").child(recipe.key).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                var numLikes = value?["numLikes"] as? Int ?? -1
                self.numLikesLabel.text = "\(numLikes) Likes"
            })
            
            // Printing out title, author, cooktime, and servings
            self.titleLabel2.text = recipe.title
            self.authorLabel2.text = recipe.author
            self.minutesLabel.text = "\(recipe.timeToCook) Minutes"
            
            favoriteButton.isSelected = false
            
            let user = Auth.auth().currentUser
            if let user = user
            {
                var ref: DatabaseReference!
                ref = Database.database().reference()
                let uid:String = user.uid
                ref.child("users").child(uid).child("favorite").observe(.childAdded, with: {(snapshot) -> Void in
                    
                    if ((snapshot.value as AnyObject).allKeys != nil){
                        if(snapshot.key == recipe.key) {
                            self.favoriteButton.isSelected = true
                        }
                    }
                })
            }
            self.servingsLabel.text = "Serves \(recipe.servings)"
            
            // Printing out Ingredients header
            headerText = NSMutableAttributedString(string: "Ingredients:\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 27)])
            textBody.append(headerText)
            
            // Printing out Ingredients details
            for singleIngredient in recipe.ingredients{
                infoText = NSMutableAttributedString(string: "\(singleIngredient.name) - \(singleIngredient.quantity) \(singleIngredient.unit)\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)])
                textBody.append(infoText)
            }
            
            // Printing out Directions header
            headerText = NSMutableAttributedString(string: "\nDirections:\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 27)])
            textBody.append(headerText)
            
            // Sorting Directions order
            recipe.directions = recipe.directions.sorted(by: { $0.0 < $1.0 })
            
            // Printing out Directions details
            var i = 1
            for singleDirection in recipe.directions{
                infoText = NSMutableAttributedString(string: "\(i). \(singleDirection.1)\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)])
                textBody.append(infoText)
                i += 1
            }
            
            // Printing out Nutrients header
            headerText = NSMutableAttributedString(string: "\nNutrients:\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 27)])
            textBody.append(headerText)
            
            // Printing out Nutrients details
            
            for singleNutrient in recipe.nutrients{
                infoText = NSMutableAttributedString(string: "\(singleNutrient.name) - \((round(singleNutrient.quantity*100.0) / 100.0)) \(singleNutrient.unit)\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)])
                textBody.append(infoText)
            }
            
            // Changing the text box with all relevant information
            self.ingredientDirectionNutritionInformation.attributedText = textBody
        }
    }
    
    // Unused code
    @IBAction func rateIt(_ sender: Any){
        print(ratingStackView.starRating)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



