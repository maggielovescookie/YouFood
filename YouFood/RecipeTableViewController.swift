//
//  RecipeTableViewController.swift
//  YouFood
//
//  Created by ckanou on 6/28/18.
//  Copyright © 2018 Novus. All rights reserved.
//
//  Contributors to this file: Cloud (Syou) Kanou, Sukkwon On, Maggie Xu, Ryan Thompson
//
//  Changes required: Add a way to favorite and report recipes
//

import UIKit
import CoreData
import Firebase
import os.log

var testRecipes = [Recipe]()
var filteredRecipes = [Recipe]()
var recipesLoaded = false

var fiveStar: UIImage = UIImage(named: "5starImage.png")!
var fourStar: UIImage = UIImage(named: "4starImage.png")!
var threeStar: UIImage = UIImage(named: "3starImage.png")!
var twoStar: UIImage = UIImage(named: "2starImage.png")!
var oneStar: UIImage = UIImage(named: "1starImage.png")!


class RecipeTableViewController: UITableViewController {
    //MARK: Properties
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewWillAppear(_ animated: Bool) {
        // On initial load, retrieve recipes from firebase
        /*
         testRecipes.removeAll()
         filteredRecipes.removeAll()
         self.tableView.reloadData()
         */
        self.tableView.reloadData()
        if !recipesLoaded {
            loadTestRecipes()
            recipesLoaded = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //=============================
        
        //==============================
        //Setting up parameters for searchController
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "What do you want to eat?"
        searchController.searchBar.scopeButtonTitles = ["All", "Breakfast", "Lunch", "Dinner"]
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = UIColor(red: 0/255, green: 202/255, blue: 157/255, alpha: 1.00)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRecipe))
        addButton.tintColor = UIColor(red: 0/255, green: 202/255, blue: 157/255, alpha: 1.00)
        self.navigationItem.leftBarButtonItem = addButton
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func addRecipe() {
        self.performSegue(withIdentifier: "addrecp", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering(){
            return filteredRecipes.count
        }
        return testRecipes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "RecipeTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RecipeTableViewCell
            else{
                fatalError("The dequeued cell is not an instance of RecipeTableViewCell")
        }
        
        //Fetches the next recipe to be displayed depending on the filter status
        var recipe = Recipe()
        
        if isFiltering(){
            recipe = filteredRecipes[indexPath.row]
        } else {
            recipe = testRecipes[indexPath.row]
        }
        
        cell.titleLabel.text = recipe.title
        cell.authorLabel.text = recipe.author
        cell.numLikesLabel.text = "\(recipe.numLikes) Likes"
        
        let imageUrlString = recipe.recipeImageUrl
        
        if (recipe.recipeImageUrl != "" && recipe.actualImage == nil){
            cell.tag = indexPath.row
            
            let image_url: NSURL = NSURL(string: imageUrlString)!
            if let image_from_url_request: NSURLRequest = NSURLRequest(url: image_url as URL) {
                NSURLConnection.sendAsynchronousRequest(
                    image_from_url_request as URLRequest, queue: OperationQueue.main,
                    completionHandler: {(response: URLResponse?,
                        data: Data?,
                        error: Error?) -> Void in
                        
                        if error == nil && data != nil && cell.tag == indexPath.row {
                            DispatchQueue.main.async {
                                // create UIImage
                                let imageToCache = UIImage(data: data!)
                                // add image to cache THIS IS WHERE THE IMAGE IS STORED!!!
                                recipe.actualImage = imageToCache
                                cell.recipeImageView.image = recipe.actualImage
                                //cell.recipeImageView.image = imageToCache
                                
                            }
                        }
                }
                )
            }
        } else if recipe.actualImage != nil{
            cell.recipeImageView.image = recipe.actualImage
        }
        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // If user wants to look at a recipe in more detail
        if segue.identifier == "DetailedRecipeViewController"{
            //Making sure the destination is correct
            guard let selectedRecipeCell = sender as? RecipeTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            //Getting the selected recipe
            guard let indexPath = tableView.indexPath(for: selectedRecipeCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            //Selected recipe is different depending on filter status
            var selectedRecipe = Recipe()
            if isFiltering(){
                selectedRecipe = filteredRecipes[indexPath.row]
            } else {
                selectedRecipe = testRecipes[indexPath.row]
            }
            
            //Can't pass data to a nagivationController directly. Must keep going through scenes until DetailedRecipeViewController
            if segue.identifier == "DetailedRecipeViewController"{
                if let nav = segue.destination as? RecipeNavigationController{
                    if let detailsVC = nav.viewControllers[0] as? DetailedRecipeViewController{
                        detailsVC.recipe = selectedRecipe
                    }
                }
            }
        }
            // Else, user wants to upload a recipe
        else if segue.identifier == "AddViewController"{
        }
    }
    
    //MARK: Private Methods
    
    private func loadTestRecipes(){
        //let group = DispatchGroup()
        var ref: DatabaseReference!
        ref = Database.database().reference().child("mainstream")
        
        //group.enter()
        //DispatchQueue.global(qos: .background).async{
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            
            // If there are no recipes
            if (snapshot.value as AnyObject).allKeys == nil{
                let alert = UIAlertView()
                alert.title = "Alert"
                alert.message = "There are currently no recipes available"
                alert.addButton(withTitle: "Ok")
                alert.show()
                return
            }
            
            
            // Initializing variables that are used for the recipe class
            var key: String = ""
            var title1: String = ""
            var author: String = ""
            var cuisine: String = ""
            var imageId: String = ""
            var recipeImageUrl: String = ""
            var timeToCook: Int = 0
            var servings: Int = 0
            var directions: [(Int, String)] = []
            var mealType: [String] = []
            var ingredients: [Ingredient] = []
            var nutrients: [Nutrient] = []
            var numLikes: Int = 0
            
            // Getting single values from Firebase
            let value = snapshot.value as? NSDictionary
            key = value?["key"] as? String ?? ""
            title1 = value?["title"] as? String ?? ""
            author = value?["author"] as? String ?? ""
            cuisine = value?["cuisine"] as? String ?? ""
            imageId = value?["imageID"] as? String ?? ""
            recipeImageUrl = value?["recipeImageUrl"] as? String ?? ""
            timeToCook = value?["timeToCook"] as? Int ?? -1
            servings = value?["servings"] as? Int ?? -1
            numLikes = value?["numLikes"] as? Int ?? -1
            
            
            let directionsString = value?["directions"] as? String ?? ""
            var directionsArray = [String]()
            directionsArray = directionsString.components(separatedBy: "^")
            var i = 0
            while i < directionsArray.count{
                directions.append((0, directionsArray[i + 1]))
                i += 2
            }
            
            let mealTypeString = value?["mt"] as? String ?? ""
            var mealTypeArray = [String]()
            mealTypeArray = mealTypeString.components(separatedBy: ",")
            i = 0
            while i < mealTypeArray.count{
                mealType.append(mealTypeArray[i])
                i += 1
            }
            
            let ingredientsString = value?["ingredients"] as? String ?? ""
            var ingredientsArray = [String]()
            ingredientsArray = ingredientsString.components(separatedBy: ",")
            i = 0
            while i < ingredientsArray.count{
                ingredients.append(Ingredient(name: ingredientsArray[i], quantity: ingredientsArray[i+1], unit: ingredientsArray[i+2], tags: []))
                i += 3
            }
            
            let nutrientsString = value?["nutrients"] as? String ?? ""
            var nutrientsArray = [String]()
            nutrientsArray = nutrientsString.components(separatedBy: ",")
            i = 0
            while i < nutrientsArray.count{
                nutrients.append(Nutrient(name: nutrientsArray[i], quantity: Float(nutrientsArray[i+1])!, unit: nutrientsArray[i+2]))
                i += 3
            }
            
            // Adding the recipe to the table
            testRecipes.append(Recipe(key: key, imageID: imageId, recipeImageUrl: recipeImageUrl, title: title1, author: author, ingredients: ingredients, cuisine: cuisine, mealType: mealType, timeToCook: timeToCook, servings: servings, directions: directions, nutrients: nutrients, numLikes: numLikes))
            
            self.tableView.reloadData()
        })
    }
    
    func searchBarIsEmpty() -> Bool {
        //Returns true if bar is empty
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String){
        //The main search function. Includes query matching and scope matching
        filteredRecipes = testRecipes.filter({( recipe : Recipe) -> Bool in
            let doesScopeMatch = scope == "All" || recipe.mealType.contains(scope)
            
            if searchBarIsEmpty(){
                return doesScopeMatch
            } else {
                return (doesScopeMatch && recipe.title.lowercased().contains(searchText.lowercased())) || (doesScopeMatch && recipe.author.lowercased().contains(searchText.lowercased()))
            }
        })
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
}

//Required for the search bar
extension RecipeTableViewController: UISearchResultsUpdating{
    //MARK: UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController){
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

//Required for the scope bar
extension RecipeTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

