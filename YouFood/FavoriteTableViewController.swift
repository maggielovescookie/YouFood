//
//  FavoriteTableViewController.swift
//  YouFood
//
//  Created by Sukkwon On on 2018-07-29.
//  Copyright © 2018 Novus. All rights reserved.
//

import UIKit
import Firebase


var favoriteRecipes = [Recipe]()
class FavoriteTableViewController: UITableViewController {
    @IBOutlet weak var userNameLabel: UILabel!
    private var databaseHandle_1: DatabaseHandle!
    private var databaseHandle_2: DatabaseHandle!
    
    override func viewWillAppear(_ animated: Bool) {
        // On initial load, retrieve recipes from firebase
        //testRecipes = []
        //filteredRecipes = []

        if favoriteRecipes.count == 0 {
            loadFavoriteRecipes()
            removeFavoriteRecipes()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let uid:String = user.uid
            let userName:String = user.displayName!
            userNameLabel.text = userName+"'s Favorite"
            userNameLabel.textColor = UIColor(red: 0/255, green: 202/255, blue: 157/255, alpha: 1.00)
            userNameLabel.backgroundColor = UIColor(red: 100/255, green: 102/255, blue: 17/255, alpha: 1.00)
            userNameLabel.font = UIFont(name: "HelveticaNeue", size: 25)
            userNameLabel.textAlignment = .center
            let reference = Database.database().reference()
            
            reference.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let favoriteString = value?["favorite"] as? String ?? ""
                // ...
            }) { (error) in
                print(error.localizedDescription)
            }
            
            /*
            let email:String = user.email!
            let displayName:String = user.displayName!
            let photoURL:String = "\(user.photoURL!)"
            //let favorite:String = user.favorite!
            */
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func removeFavoriteRecipes(){
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let uid:String = user.uid
            var ref: DatabaseReference!
            ref = Database.database().reference().child("users").child(uid).child("favorite")
            
            databaseHandle_1 = ref.observe(.childRemoved, with: {(snapshot) -> Void in

                favoriteRecipes.removeAll()
                self.tableView.reloadData()
                ref.removeObserver(withHandle: self.databaseHandle_1)
                //self.loadFavoriteRecipes()
            })
        }
    }
        
    private func loadFavoriteRecipes(){
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let uid:String = user.uid
            var ref: DatabaseReference!
            ref = Database.database().reference().child("users").child(uid).child("favorite")
            
            var refMainStream: DatabaseReference!
            refMainStream = Database.database().reference().child("mainstream")
            
            databaseHandle_2 = ref.observe(.childAdded, with: {(snapshot) -> Void in
                // If there are no recipes
                    
                if (snapshot.value as AnyObject).allKeys == nil{
                    let alert = UIAlertView()
                    alert.title = "Alert"
                    alert.message = "There are currently no recipes available for user favorite"
                    alert.addButton(withTitle: "Ok")
                    alert.show()
                    return

                    /*
                     //=========================================================
                     // Dealing with user's favorite array problems. A recipe that is removed in 'mainstream' stays in favorite array
                     //=========================================================
                    print("**************************")
                    print(snapshot.key)
                    print("**************************")
                    let keyVal = snapshot.key
                    
                    refMainStream.observeSingleEvent(of: .value, with: {(snapshot) -> Void in
                        print(keyVal)
                        let value = snapshot.value
                        let dic = value as! [String: [String:Any]]
                        for index in dic {
                            if index.key == key {
                            }
                        }
                    })
                     //=========================================================
                     // Dealing with user's favorite array problems. A recipe that is removed in 'mainstream' stays in favorite array
                     //=========================================================
                    */
                }
                
                print("?????????????")
                print(snapshot.value)
                print("?????????????")

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
                
                /*
                while i < nutrientsArray.count{
                    nutrients.append(Nutrient(name: nutrientsArray[i], quantity: Float(nutrientsArray[i+1])!, unit: nutrientsArray[i+2]))
                    i += 3
                }
                 */
                
                // Adding the recipe to the table
                favoriteRecipes.append(Recipe(key: key, imageID: imageId, recipeImageUrl: recipeImageUrl, title: title1, author: author, ingredients: ingredients, cuisine: cuisine, mealType: mealType, timeToCook: timeToCook, servings: servings, directions: directions, nutrients: nutrients, numLikes: numLikes))
                
                self.tableView.reloadData()
                
                print("skskskksksksksksskksskskskksksksksks")
                ref.removeObserver(withHandle: self.databaseHandle_2)
            }) { (error) in
                print(error.localizedDescription)
            }
        }
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
        return favoriteRecipes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "FavoriteTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FavoriteTableViewCell
            else{
                fatalError("The dequeued cell is not an instance of FavoriteTableViewCell")
        }
        
        //Fetches the next recipe to be displayed depending on the filter status
        var recipe = Recipe()
        
        print("TTTTTTTTTTTTTTTTTTTTT")
        print(favoriteRecipes.count)
        print(indexPath.row)
        print("TTTTTTTTTTTTTTTTTTTTT")
        
        recipe = favoriteRecipes[indexPath.row]
        
        cell.titleLabel.text = recipe.title
        cell.authorLabel.text = recipe.author
        
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
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
