//
//  MyDashboardTableViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/5/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit

class MyDashboardTableViewController: UITableViewController {
    
    var myDashboardPendingPickups:[PickupRequest]!
    var myDashboardConfirmedPickups:[PickupRequest]!
    let backend = Backend.sharedInstance()
    
    @IBOutlet var dashboardTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMyDashboardPendingPickups()
        fetchMyDashboardConfirmedPickups()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Fetch data
    
    func fetchMyDashboardPendingPickups() {
        let query = backend.queryMyDashboardPendingPickups()
        backend.fetchPickupRequestsWithQuery(query, completionHandler: { (result, error) -> Void in
            if error != nil {
                print(error)
            }
            else if let pickupRequests = result as? [PickupRequest] {
                self.myDashboardPendingPickups = pickupRequests
                self.dashboardTable.reloadData()
            }
        })
        
    }
    
    func fetchMyDashboardConfirmedPickups() {
        let query = backend.queryMyDashboardConfirmedPickups()
        backend.fetchPickupRequestsWithQuery(query, completionHandler: { (result, error) -> Void in
            if error != nil {
                print(error)
            }
            else if let pickupRequests = result as? [PickupRequest] {
                self.myDashboardConfirmedPickups = pickupRequests
                self.dashboardTable.reloadData()
            }
        })
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if myDashboardPendingPickups != nil {
                return self.myDashboardPendingPickups.count
            }
            else {
                return 0
            }
        default:
            if myDashboardConfirmedPickups != nil {
                return self.myDashboardConfirmedPickups.count
            }
            else {
                return 0
            }
        }

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pickupRequest", forIndexPath: indexPath) as! PickupRequestTableViewCell
        
        switch indexPath.section {
        case 0:
            cell.pickupRequest = myDashboardPendingPickups[indexPath.row]
            configurePendingPickupCell(cell)
        default:
            cell.pickupRequest = myDashboardConfirmedPickups[indexPath.row]
            configureConfirmedPickupCell(cell)
        }

        return cell
    }
    
    func configurePendingPickupCell(cell: PickupRequestTableViewCell) {
        cell.statusLabel.text = "Waiting for Donor"
        if cell.pickupRequest.address != nil {
            cell.addressLabel.text = cell.pickupRequest.address!
        }
        cell.accessoryType = .None
    }
    
    func configureConfirmedPickupCell(cell: PickupRequestTableViewCell) {
        cell.statusLabel.text = "Ready for Pickup"
        if cell.pickupRequest.address != nil {
            cell.addressLabel.text = cell.pickupRequest.address!
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            print("No action on pending pickup")
        default:
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! PickupRequestTableViewCell
            performSegueWithIdentifier("viewConfirmedPickup", sender: cell)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewConfirmedPickup" {
            let cell = sender as! PickupRequestTableViewCell
            let pickupDonationViewController = segue.destinationViewController as! PickupDonationViewController
            pickupDonationViewController.pickupRequest = cell.pickupRequest
        }
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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
