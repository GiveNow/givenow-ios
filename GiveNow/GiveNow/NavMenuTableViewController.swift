//
//  NavMenuTableViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/10/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit
import Parse

class NavMenuTableViewController: UITableViewController, LoginModalViewControllerDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var logInLabel: UILabel!
    
    // MARK: - Nib setup
    let loginModalViewController = LoginModalViewController(nibName: "LoginModalViewController", bundle: nil)
    
    let backend = Backend.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLoginLabel()
        configureProfileCell()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            return false
        default:
            return true
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return 3
        default:
            return 1
        }
    }
    
    func configureProfileCell() {
        if AppState.sharedInstance().isUserRegistered {
            let user = User.currentUser()!
            if user.name != nil {
                nameLabel.text = user.name!
                usernameLabel.text = user.username!
            }
            else {
                nameLabel.text = "Unknown User"
                usernameLabel.text = ""
            }
        }
        else {
            nameLabel.text = "Not logged in"
            usernameLabel.text = ""
        }
    }
    
    func configureLoginLabel() {
        if AppState.sharedInstance().isUserRegistered {
            logInLabel.text = "Log out"
        }
        else {
            logInLabel.text = "Add phone number"
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        if cell.reuseIdentifier != nil {
            switch cell.reuseIdentifier! {
            case "giveNow":
                performSegueWithIdentifier("donate", sender: nil)
            case "volunteer":
                volunteerTapped()
            case "dropOff":
                performSegueWithIdentifier("dropOff", sender: nil)
            case "logIn":
                logInOutTapped()
            default:
                print("No action")
            }
        }
    }
    
    func logInOutTapped() {
        if AppState.sharedInstance().isUserRegistered {
            User.logOut()
            configureProfileCell()
            configureLoginLabel()
        }
        else {
            loginModalViewController.modalPresentationStyle = .OverFullScreen
            loginModalViewController.modalTransitionStyle = .CrossDissolve
            loginModalViewController.delegate = self
            
            presentViewController(loginModalViewController, animated: true, completion: {})
        }
    }
    
    func volunteerTapped() {
        if AppState.sharedInstance().isUserRegistered {
            let user = User.currentUser()!
            backend.fetchVolunteerForUser(user, completionHandler: {(volunteer, error) -> Void in
                if volunteer != nil && volunteer?.isApproved == true {
                    self.performSegueWithIdentifier("dashboard", sender: nil)
                }
                else {
                    self.performSegueWithIdentifier("apply", sender: nil)
                }
            })
        }
        else {
            performSegueWithIdentifier("apply", sender: nil)
        }
    }
    
    func successfulLogin(controller: LoginModalViewController) {
        configureLoginLabel()
        configureProfileCell()
    }
    
    @IBAction func loginCompleted(segue: UIStoryboardSegue) {
        configureLoginLabel()
        configureProfileCell()
    }


    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
