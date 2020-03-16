//
//  PostViewController.swift
//  instagram
//
//  Created by Semi Ismaili on 3/16/20.
//  Copyright © 2020 Semi Ismaili. All rights reserved.
//

import UIKit
import Parse

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageToPost: UIImageView!
    
    @IBOutlet weak var comment: UITextField!
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self //gives control to PostViewController as UIImagePickerControllerDelegate
        
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    @IBAction func postImage(_ sender: Any) {
        
        if let image = imageToPost.image { //if there is an image selected
        
        let post = PFObject(className: "Post") //create a new Post class in Parse
        
        post["message"] = comment.text
        
        post["userId"] = PFUser.current()?.objectId
            
            
            let activityIndicator =  UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) //creates spinner
            activityIndicator.center = self.view.center //centers spinner
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle =  UIActivityIndicatorViewStyle.gray
            
            view.addSubview(activityIndicator) //adds spinner to this view
            
            activityIndicator.startAnimating()
            
            UIApplication.shared.beginIgnoringInteractionEvents() //disables interaction with app
            
            
            if let imageData = UIImagePNGRepresentation(image) { //if PNG representasion is possible
                
                let imageFile = PFFileObject(name: "image.png", data: imageData) //create the Parse File from png
                
                post["imageFile"] = imageFile
                
                post.saveInBackground(block: { (success, error) in //savinf the instance of Post
                    
                    activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if(success){
                        
                        self.displayAlert(title: "Success", message: "Your image has been posted!")
                        
                        self.comment.text = ""
                        
                        self.imageToPost.image = nil
                        
                        
                    } else {
                        
                        var errorText = "Unknown error. Please try to post again!"
                        
                        if let error = error {
                            
                            errorText = error.localizedDescription
                        }
                        
                        self.displayAlert(title: "Failed", message: errorText)

                    }
                    
                })
            }
            
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageToPost.image = image
            
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func displayAlert(title:String, message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
