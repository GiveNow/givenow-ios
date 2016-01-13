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

    @IBOutlet weak var logInLabel: UILabel!
    
    var nameLabel:UILabel!
    var usernameLabel:UILabel!
    var profileImage = UIImageView()
    
    // MARK: - Nib setup
    let loginModalViewController = LoginModalViewController(nibName: "LoginModalViewController", bundle: nil)
    
    let backend = Backend.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHeaderView()
        configureLoginLabel()
        configureProfileInfo()
    }
    
    func configureHeaderView() {
        //Create a view and put it behind the status bar
        let anotherHeaderView = UIView()
        anotherHeaderView.frame = CGRect(x: 0, y: -20, width: view.frame.width, height: 20)
        anotherHeaderView.backgroundColor = UIColor.colorPrimaryDark()
        view.addSubview(anotherHeaderView)
        
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 160)
        headerView.backgroundColor = UIColor.colorPrimaryDark()
        tableView.tableHeaderView = headerView
        
        profileImage.frame = CGRect(x: 20, y: 13, width: 80, height: 80)
        headerView.addSubview(profileImage)
        
        nameLabel = UILabel()
        nameLabel.frame = CGRect(x: 30, y: 93, width: view.frame.width - 50, height: 24)
        nameLabel.font = UIFont.boldSystemFontOfSize(17.0)
        nameLabel.textColor = UIColor.whiteColor()
        headerView.addSubview(nameLabel)
        
        usernameLabel = UILabel()
        usernameLabel.frame = CGRect(x: 30, y: 117, width: view.frame.width - 50, height: 17)
        usernameLabel.font = UIFont.boldSystemFontOfSize(15.0)
        usernameLabel.textColor = UIColor.whiteColor()
        headerView.addSubview(usernameLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
//    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        switch indexPath.section {
//        case 0:
//            return false
//        default:
//            return true
//        }
//    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        default:
            return 1
        }
    }
    
    func configureProfileInfo() {
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
            if let image = UIImage(named: "round_icon") {
                print("set image")
                profileImage.image = image
            }
        }
        else {
            nameLabel.text = "Not logged in"
            usernameLabel.text = ""
            profileImage.image = nil
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
            configureProfileInfo()
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
        configureProfileInfo()
    }
    
    @IBAction func loginCompleted(segue: UIStoryboardSegue) {
        configureLoginLabel()
        configureProfileInfo()
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
