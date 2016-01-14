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
    
    var selectedIndex = NSIndexPath(forItem: 0, inSection: 0)
    
    // MARK: - Nib setup
    let loginModalViewController = LoginModalViewController(nibName: "LoginModalViewController", bundle: nil)
    
    let backend = Backend.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHeaderView()
//        configureLoginLabel()
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
    
//    func configureLoginLabel() {
//        if AppState.sharedInstance().isUserRegistered {
//            logInLabel.text = "Log out"
//        }
//        else {
//            logInLabel.text = "Add phone number"
//        }
//    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("menuCell") as! MenuTableViewCell
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell.menuImage.image = self.templatedImageFromName("pin-drop")
                cell.cellLabel.text = "Give Now"
            case 1:
                cell.menuImage.image = self.templatedImageFromName("car")
                cell.cellLabel.text = "Volunteer"
            default:
                cell.menuImage.image = templatedImageFromName("city")
                cell.cellLabel.text = "Drop Off"
            }
        }
        else {
            cell.menuImage.image = templatedImageFromName("power")
            cell.cellLabel.text = "Log out"
        }
        if indexPath == selectedIndex {
            highlightCell(cell)
        }
        else {
            unhighlightCell(cell)
        }
        return cell
    }
    
    func templatedImageFromName(name: String) -> UIImage {
        if let image = UIImage(named: name) {
            return image.imageWithRenderingMode(.AlwaysTemplate)
        }
        else {
            return UIImage()
        }
    }
    
    func highlightCell(cell: MenuTableViewCell) {
        cell.backgroundColor = UIColor.colorAccent()
        cell.menuImage.tintColor = UIColor.whiteColor()
        cell.cellLabel.textColor = UIColor.whiteColor()
    }
    
    func unhighlightCell(cell: MenuTableViewCell) {
        cell.backgroundColor = UIColor.whiteColor()
        cell.menuImage.tintColor = UIColor.blackColor()
        cell.cellLabel.textColor = UIColor.blackColor()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                performSegueWithIdentifier("donate", sender: nil)
            case 1:
                volunteerTapped()
            default:
                performSegueWithIdentifier("dropOff", sender: nil)
            }
            self.selectedIndex = indexPath
        }
        else {
            logInOutTapped()
        }
        tableView.reloadData()
    }
    
    
    func logInOutTapped() {
        if AppState.sharedInstance().isUserRegistered {
            User.logOut()
            configureProfileInfo()
//            configureLoginLabel()
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
//        configureLoginLabel()
        configureProfileInfo()
    }
    
    @IBAction func loginCompleted(segue: UIStoryboardSegue) {
//        configureLoginLabel()
        configureProfileInfo()
    }

}


class MenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    
}
