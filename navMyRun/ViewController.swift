//
//  ViewController.swift
//  navMyRun
//
//  Created by bob.ashmore on 17/02/2016.
//  Copyright © 2016 bob.ashmore. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    @IBOutlet weak var facebookImage: UIImageView!
    @IBOutlet weak var facebookName: UILabel!
    @IBOutlet weak var facebookEmail: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton:FBSDKLoginButton = FBSDKLoginButton()
        // Give permission to access email and profile
        loginButton.readPermissions = ["public_profile","email"]
        loginButton.center = self.view.center // center button
        loginButton.frame.origin.y = 35 // Put the facebook button at top of view
        loginButton.delegate = self
        self.view.addSubview(loginButton)
        
        if(FBSDKAccessToken.currentAccessToken() != nil) {
            getData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error == nil {
            print("Login complete.")
            getData()
        } else {
            print(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out...")
        self.facebookName.text = "Not Logged in"
        self.facebookImage.image = nil
    }
    
    func getData() {
        let accessToken = FBSDKAccessToken.currentAccessToken()
        
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email, first_name, last_name, picture.type(large)"], tokenString: accessToken.tokenString, version: nil, HTTPMethod: "GET")
        
        graphRequest.startWithCompletionHandler { (connection, result, error) -> Void in
            if result == nil {
                print(error.localizedDescription)
                return
            }
            // Get the facebook data and deal with optionals
            var name:String = ""
            if let firstName: String = (result.objectForKey("first_name") as? String) {
                name = firstName
            }
            if let lastName: String = (result.objectForKey("last_name") as? String) {
                name = name + " " + lastName
            }
            
            self.facebookName.text = String(format: "Logged in as: %@",name)
            
            if let userEmail: String = result.valueForKey("email") as? String {
                self.facebookEmail.text = String(format: "Email: %@",userEmail)
            }
            // if all optionals unwrap OK then we can setup the image
            if let imageURL: String = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String), let nsurl = NSURL(string: imageURL), let data = NSData(contentsOfURL:nsurl), let image = UIImage(data:data) {
                self.facebookImage.image = image
            }
        }
    }


}

