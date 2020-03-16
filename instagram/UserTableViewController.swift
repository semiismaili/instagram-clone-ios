//
//  UserTableViewController.swift
//  instagram
//
//  Created by Semi Ismaili on 3/15/20.
//  Copyright © 2020 Semi Ismaili. All rights reserved.
//

import UIKit
import Parse

class UserTableViewController: UITableViewController {
    
    var usernames = [""] //all the usernames
    var objectIds = [""] //corresponding objectIds of those usernames
    
    var isFollowing = ["": false] //dictionary where key = objectId
    //value = whether the current user follows the user with that objectId or not
    
    var refresher: UIRefreshControl = UIRefreshControl()
    
    @IBAction func logoutUser(_ sender: Any) {
        
        PFUser.logOut()
        
        performSegue(withIdentifier: "logoutSegue", sender: self)
        
    }
    
    @objc func updateTable(){
        
        
        let query = PFUser.query()
        
        query?.whereKey("username", notEqualTo: PFUser.current()?.username) //we dont wanna show ourselves
        
        query?.findObjectsInBackground(block: { (users, error) in  //users is an array of PFObjects or PFUsers
            
            if error != nil {
                
                print (error)
                
            } else if let users = users {
                
                self.usernames.removeAll() //removes the initalization empty string element
                self.objectIds.removeAll()
                self.isFollowing.removeAll()
                
                for object in users {
                    
                    if let user = object as? PFUser { //if object is indeed a user
                        
                        if var username = user.username {  //and they've got a username
                            
                            if let objectId = user.objectId { //and also an objectId
                                
                                username = String(username.split(separator: "@")[0]) //throw the @example.com to get username only
                                
                                self.usernames.append(username)
                                self.objectIds.append(objectId)
                                
                                let query =  PFQuery(className: "Following")
                                
                                query.whereKey("follower", equalTo: PFUser.current()?.objectId)
                                query.whereKey("following", equalTo: objectId)
                                
                                query.findObjectsInBackground(block: { (objects, error) in //objects type is [PFObject]
                                    
                                    if let objects = objects { //see if objects array exists
                                        
                                        if objects.count > 0 { //se if it has an element
                                            
                                            self.isFollowing[objectId] = true
                                            
                                        } else {
                                            
                                            self.isFollowing[objectId] = false
                                            
                                        }
                                        
                                        if self.usernames.count == self.isFollowing.count { //if we are finished with all the users
                                            
                                            self.tableView.reloadData()     //only then update the table
                                            
                                            self.refresher.endRefreshing()  //and only then end refreshing (updating the table from pulling down)

                                            
                                        }
                                    }
                                    
                                })
                                
                                
                                
                            }
                        }
                        
                    }
                    
                }
                
                
            }
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTable()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh!") //What appears at the top
        
        refresher.addTarget(self, action: #selector(UserTableViewController.updateTable), for: UIControlEvents.valueChanged) //handling pull to refresh
        
        tableView.addSubview(refresher)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        // Configure the cell...
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier", for: indexPath)
        
        cell.textLabel?.text = usernames[indexPath.row]  //corresponds to prototype cell with identifier cellReuseIdentifier
        
        if let followsBoolean = isFollowing[objectIds[indexPath.row]] { //see if it is actually a Boolean (if it exists)
            
            if followsBoolean { //if current user follows user at this table cell
                
                cell.accessoryType=UITableViewCellAccessoryType.checkmark
                
            }
        }
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if let followsBoolean = isFollowing[objectIds[indexPath.row]] { //see if it is actually a Boolean (if it exists)
            
            if followsBoolean { //if following, unfollow:
                
                isFollowing[objectIds[indexPath.row]] = false //unfollow locally
                
                cell?.accessoryType=UITableViewCellAccessoryType.none //remove checkmark
                
                let query =  PFQuery(className: "Following")
                
                query.whereKey("follower", equalTo: PFUser.current()?.objectId)
                query.whereKey("following", equalTo: objectIds[indexPath.row])
                
                query.findObjectsInBackground(block: { (objects, error) in //objects type is [PFObject]
                    
                    if let objects = objects { //see if objects array exists
                        
                        
                        for object in objects { //delete the entries from Following table in Parse
                            
                            object.deleteInBackground()
                            
                        }
                        
                        self.tableView.reloadData()
                        
                    }
                    
                })
                
                
                
            } else {
                
                isFollowing[objectIds[indexPath.row]] = true //follow locally
                
                cell?.accessoryType = UITableViewCellAccessoryType.checkmark //add checkmark
                
                let following = PFObject(className: "Following")
                
                following["follower"] = PFUser.current()?.objectId
                
                following["following"] = objectIds[indexPath.row]
                
                following.saveInBackground() //save to Parse
                
            }
        }
        
        
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
