//
//  NavMenuTableViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/10/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit
import Parse

class NavMenuTableViewController: UITableViewController, ModalBackgroundViewControllerDelegate {

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
    
    func getLoginLabel() -> String {
        if AppState.sharedInstance().isUserRegistered {
            return "Log out"
        }
        else {
            return "Add phone number"
        }
    }
    
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
            cell.cellLabel.text = self.getLoginLabel()
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
            sendUserToOnboardingFlow()
        }
        else {
            createModalBackgroundView()
//            loginModalViewController.modalPresentationStyle = .OverFullScreen
//            loginModalViewController.modalTransitionStyle = .CrossDissolve
//            loginModalViewController.delegate = self
//            
//            presentViewController(loginModalViewController, animated: true, completion: {})
        }
    }

    func createModalBackgroundView() {
        let modalBackground = ModalBackgroundViewController()
        modalBackground.modalPresentationStyle = .OverFullScreen
        modalBackground.modalTransitionStyle = .CrossDissolve
        modalBackground.delegate = self
        presentViewController(modalBackground, animated: true, completion: {})
    }
    
    func sendUserToOnboardingFlow() {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "FirstLaunch")
        if let parent = parentViewController as? SWRevealViewController {
            if let initial = parent.parentViewController as? InitialViewController {
                initial.displayOnboardingViewController()
            }
            parent.willMoveToParentViewController(nil)
            parent.view.removeFromSuperview()
            parent.removeFromParentViewController()
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
    
    func modalViewDismissedWithResult(controller: ModalBackgroundViewController) {
        configureProfileInfo()
        tableView.reloadData()
    }
    
    @IBAction func loginCompleted(segue: UIStoryboardSegue) {
        configureProfileInfo()
        tableView.reloadData()
    }

}


class MenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    
}

protocol ModalBackgroundViewControllerDelegate {
    func modalViewDismissedWithResult(controller:ModalBackgroundViewController)
}

class ModalBackgroundViewController: UIViewController, UIGestureRecognizerDelegate, LoginModalViewControllerDelegate {
    
    var delegate:ModalBackgroundViewControllerDelegate!
    var backgroundView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackgroundView()
        displayModalLoginView()
    }
    
    func configureBackgroundView() {
        backgroundView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height))
        backgroundView.backgroundColor = UIColor.darkGrayColor()
        backgroundView.alpha = 0.8
        view.addSubview(backgroundView)
        
        addTapGestureRecognizer()
    }
    
    func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: Selector("backgroundTapped:"))
        tap.delegate = self
        backgroundView.addGestureRecognizer(tap)
    }
    
    func backgroundTapped(sender: UIGestureRecognizer? = nil) {
        dismissViewControllerAnimated(true, completion: {})
    }
    
    func displayModalLoginView() {
        let modalLoginView = LoginModalViewController(nibName: "LoginModalViewController", bundle: nil)
        modalLoginView.delegate = self
        addChildViewController(modalLoginView)
        
        let frame = CGRect(x: 20, y: 80, width: view.frame.width - 40, height: view.frame.height/2 - 80)
        modalLoginView.view.frame = frame
        view.addSubview(modalLoginView.view)
        modalLoginView.didMoveToParentViewController(self)
    }
    
    func successfulLogin(controller: LoginModalViewController) {
        delegate.modalViewDismissedWithResult(self)
        dismissViewControllerAnimated(true, completion: {})
    }
    
}
