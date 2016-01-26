//
//  NavMenuTableViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/10/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit
import Parse

class NavMenuTableViewController: UITableViewController, ModalLoginViewControllerDelegate {

    @IBOutlet weak var logInLabel: UILabel!
    
    var nameLabel:UILabel!
    var usernameLabel:UILabel!
    var profileImage = UIImageView()
    
    var selectedIndex = NSIndexPath(forItem: 0, inSection: 0)
    
    let backend = Backend.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHeaderView()
        configureProfileInfo()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        configureProfileInfo()
        tableView.reloadData()
    }

    // MARK: - Table view

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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("menuCell") as! MenuTableViewCell
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell.menuImage.image = UIImage.templatedImageFromName("pin-drop")
                cell.cellLabel.text = NSLocalizedString("navigation_item_1", comment: "")
            case 1:
                cell.menuImage.image = UIImage.templatedImageFromName("car")
                cell.cellLabel.text = NSLocalizedString("navigation_item_2", comment: "")
            default:
                cell.menuImage.image = UIImage.templatedImageFromName("city")
                cell.cellLabel.text = NSLocalizedString("navigation_item_3", comment: "")
            }
        }
        else {
            cell.menuImage.image = UIImage.templatedImageFromName("power")
            cell.cellLabel.text = self.setLoginLabel()
        }
        if indexPath == selectedIndex {
            highlightCell(cell)
        }
        else {
            unhighlightCell(cell)
        }
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                performSegueWithIdentifier("donate", sender: nil)
            case 1:
                performSegueWithIdentifier("dashboard", sender: nil)
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
    
    // MARK: Delegate
    
    func modalViewDismissedWithResult(controller: ModalLoginViewController) {
        configureProfileInfo()
        tableView.reloadData()
    }
    
    // MARK: Private
    
    private func configureHeaderView() {
        //Create a view and put it behind the status bar
        let topHeaderFrame = CGRect(x: 0, y: -20, width: view.frame.width, height: 20)
        view.addCustomUIView(topHeaderFrame, backgroundColor: UIColor.colorPrimaryDark())
        
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 160)
        headerView.backgroundColor = UIColor.colorPrimaryDark()
        tableView.tableHeaderView = headerView
        
        profileImage.frame = CGRect(x: 20, y: 13, width: 80, height: 80)
        headerView.addSubview(profileImage)
        
        let nameLabelFrame = CGRect(x: 30, y: 93, width: view.frame.width - 50, height: 24)
        nameLabel = headerView.addCustomUILabel(nameLabelFrame, font: UIFont.boldSystemFontOfSize(17.0), textColor: UIColor.whiteColor())
        
        let usernameLabelFrame = CGRect(x: 30, y: 117, width: view.frame.width - 50, height: 17)
        usernameLabel = headerView.addCustomUILabel(usernameLabelFrame, font: UIFont.boldSystemFontOfSize(15.0), textColor: UIColor.whiteColor())
    }
    
    private func configureProfileInfo() {
        if AppState.sharedInstance().isUserRegistered {
            if let user = User.currentUser() {
                if let name = user.name {
                    nameLabel.text = name
                }
                else {
                    nameLabel.text = NSLocalizedString("unknown_user", comment: "")
                }
                if let username = user.username {
                    usernameLabel.text = username
                }
                else {
                    usernameLabel.text = ""
                }
                if let image = UIImage(named: "round_icon") {
                    profileImage.image = image
                }
            }
        }
        else {
            nameLabel.text = NSLocalizedString("not_logged_in", comment: "")
            usernameLabel.text = ""
            profileImage.image = nil
        }
    }
    
    private func setLoginLabel() -> String {
        if AppState.sharedInstance().isUserRegistered {
            return NSLocalizedString("title_sign_out", comment: "")
        }
        else {
            return NSLocalizedString("add_phone_number", comment: "")
        }
    }
    
    private func highlightCell(cell: MenuTableViewCell) {
        cell.backgroundColor = UIColor.colorAccent()
        cell.menuImage.tintColor = UIColor.whiteColor()
        cell.cellLabel.textColor = UIColor.whiteColor()
    }
    
    private func unhighlightCell(cell: MenuTableViewCell) {
        cell.backgroundColor = UIColor.whiteColor()
        cell.menuImage.tintColor = UIColor.blackColor()
        cell.cellLabel.textColor = UIColor.blackColor()
    }
    
    private func logInOutTapped() {
        if AppState.sharedInstance().isUserRegistered {
            User.logOut()
            sendUserToOnboardingFlow()
        }
        else {
            createModalLoginView(self)
        }
    }
    
    private func sendUserToOnboardingFlow() {
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

}


class MenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    
}
