//
//  RecipeNavigationController.swift
//  YouFood
//
//  Created by ckanou on 6/28/18.
//  Copyright © 2018 Novus. All rights reserved.
//
//  Contributors to this file: Cloud (Syou) Kanou, Maggie Xu
//
//
// This class required for sending data from the RecipeTableViewController to the DetailedRecipeViewController

import UIKit

class RecipeNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //}
}

