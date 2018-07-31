//
//  SelectRecipeTableViewController.swift
//  YouFood
//
//  Created by ckanou on 7/24/18.
//  Copyright © 2018 Novus. All rights reserved.
//
// Contributers: Syou (Cloud) Kanou, Ryan Thompson
//

import UIKit

protocol DataEnteredDelegate: class {
    func userDidEnterInformation(mealPlanRecipe: Recipe)
}

class SelectRecipeTableViewController: UITableViewController {
    
    //MARK: Properties
    weak var delegate: DataEnteredDelegate? = nil
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBAction func `return`(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting up parameters for searchController
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "What do you want to eat?"
        searchController.searchBar.scopeButtonTitles = ["All", "Breakfast", "Lunch", "Dinner"]
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = UIColor(red: 0/255, green: 202/255, blue: 157/255, alpha: 1.00)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        
        let cellIdentifier = "SelectRecipeTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SelectRecipeTableViewCell
            else{
                fatalError("The dequeued cell is not an instance of SelectRecipeTableViewCell")
        }
        // Configure the cell...
        
        var recipe = Recipe()
        
        if isFiltering(){
            recipe = filteredRecipes[indexPath.row]
        } else {
            recipe = testRecipes[indexPath.row]
        }
        
        cell.titleLabel2.text = recipe.title
        cell.authorLabel2.text = recipe.author
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedRecipe = Recipe()
        if isFiltering(){
            selectedRecipe = filteredRecipes[indexPath.row]
        } else {
            selectedRecipe = testRecipes[indexPath.row]
        }
        
        delegate?.userDidEnterInformation(mealPlanRecipe: selectedRecipe)
        
        dismiss(animated: true, completion: nil)
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
    
    
    //MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If user wants to look at a recipe in more detail
        if segue.identifier == "GetDailyMeals"{
            //Making sure the destination is correct
            guard let selectedRecipeCell = sender as? SelectRecipeTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
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
            //Passing data to meal plan
            if segue.identifier == "GetDailyMeals"{
                if let nav = segue.destination as? SelectRecipeNavigationViewController{
                    if let detailsVC = nav.viewControllers[0] as? MealPlanMainViewController{
                        detailsVC.mealHolder = selectedRecipe
     
                    }
                }
            }
            // Get the new view controller using segue.destinationViewController.
            // Pass the selected object to the new view controller.
        }
    }
 */
    
    
    // MARK: Private Methods
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
                return doesScopeMatch && (recipe.title.lowercased().contains(searchText.lowercased()) ||
                    recipe.author.lowercased().contains(searchText.lowercased()))
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
extension SelectRecipeTableViewController: UISearchResultsUpdating{
    //MARK: UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController){
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

//Required for the scope bar
extension SelectRecipeTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

