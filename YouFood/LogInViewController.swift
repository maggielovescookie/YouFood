//
//  LogInViewController.swift
//  YouFood
//
//  Created by Sukkwon On on 2018-07-28.
//  Copyright © 2018 Novus. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LogInViewController: UIViewController, GIDSignInUIDelegate{
    @IBAction func signInAction(_ sender: GIDSignInButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var logInButton: GIDSignInButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() == true{
            GIDSignIn.sharedInstance().signInSilently()
        }
        else { // May not need this else statement
            GIDSignIn.sharedInstance().uiDelegate = self
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
