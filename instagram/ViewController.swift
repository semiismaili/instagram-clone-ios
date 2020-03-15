//
//  ViewController.swift
//  instagram
//
//  Created by Semi Ismaili on 3/14/20.
//  Copyright © 2020 Semi Ismaili. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    var signupModeActive = true //tells if user is signing up or loggging in
    
    func displayAlert(title: String,message: String){ //helper function to display alerts
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil )
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBAction func signupOrLogin(_ sender: Any) { //gets called on button click for either Sing Up or Log In
        
        if email.text == "" || password.text == ""{
            
            displayAlert(title:"Error in form",message:"Please enter an email and password")
            
        } else { //email and pass fields aren't empty :
            
            
            let activityIndicator =  UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) //creates spinner
            activityIndicator.center = self.view.center //centers spinner
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle =  UIActivityIndicatorViewStyle.gray
            
            view.addSubview(activityIndicator) //adds spinner to this view
            
            activityIndicator.startAnimating()
            
            UIApplication.shared.beginIgnoringInteractionEvents() //disables interaction with app
            
            
            
            if(signupModeActive){ //if user is signing up
                
                 print("Signing up....")
                
                let user = PFUser()
                user.username = email.text
                user.password = password.text
                user.email = email.text
                
                user.signUpInBackground(block: { (succe, error) in
                    
                    activityIndicator.stopAnimating() //stops spinner
                    UIApplication.shared.endIgnoringInteractionEvents() //allows inteaction again
                    
                    
                    if let error = error {
                        
                        self.displayAlert(title: "Could not sign you up", message: error.localizedDescription)
                       
                        print(error)
                        
                    } else {
                        // Hooray! Let them use the app now.
                        print("Signed up!")
                    }
                })
                
            } else { //if user is logging in
                
                PFUser.logInWithUsername(inBackground: email.text!, password: password.text!, block: { (user, error) in
                    
                    activityIndicator.stopAnimating() //stops spinner
                    UIApplication.shared.endIgnoringInteractionEvents() //allows inteaction again
                    
                    if user != nil {
                        
                        print("Login successful")
                        
                    } else {
                        
                        var errorText = "Unknown error: please try again!"
                        
                        if let error = error {
                            
                            errorText =  error.localizedDescription
                            
                        }
                        
                        self.displayAlert(title: "Could not log you in", message: errorText)

                        
                    }
                    
                })
                
            }
            
           
            
        }
        
    }
    
    @IBOutlet weak var signupOrLoginButton: UIButton!
    
    
    @IBAction func switchLoginMode(_ sender: Any) {
        
        if (signupModeActive) {
            
            signupModeActive = false
            
            signupOrLoginButton.setTitle("Log In", for: [])
            
            switchLoginModeButton.setTitle("Sign Up", for: [])
            
        } else {
            
            signupModeActive = true
            
            signupOrLoginButton.setTitle("Sign Up", for: [])
            
            switchLoginModeButton.setTitle("Log In", for: [])
            
        }
        
    }
    
    @IBOutlet weak var switchLoginModeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

