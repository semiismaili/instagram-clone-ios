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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
//        let comment = PFObject(className: "Comment")
//
//        comment["text"] = "Nice shot!"
//
//        comment.saveInBackground{(succes,error) in
//
//            if (succes) {
//
//                print("Save successful")
//
//            } else{
//
//                print("Save failed")
//
//            }
//
//        }
        
        
        let query =  PFQuery(className: "Comment")
        query.getFirstObjectInBackground { (object, error) in
            
            if let comment = object {
                
                comment["text"] = "Awful shot!"
                
                comment.saveInBackground(block: { (succes, error) in
                    
                    if (succes) {
                        print ("update succes")
                    }else{
                        ("update failed")
                    }
                })
                
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

