//
//  ReadyForPickupViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/16/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit

protocol ReadyForPickupViewControllerDelegate {
    func donationIsReadyForPickup(controller:ReadyForPickupViewController)
    func donationIsNotReadyForPickup(controller: ReadyForPickupViewController)
}

class ReadyForPickupViewController: BaseViewController {
    
    @IBOutlet weak var messageImage: UIImageView!
    @IBOutlet weak var messageHeader: UILabel!
    @IBOutlet weak var messageBody: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    var delegate:ReadyForPickupViewControllerDelegate!
    var pickupRequest:PickupRequest!

    override func viewDidLoad() {
        super.viewDidLoad()
        localizeStrings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func localizeStrings() {
        let headerText = NSLocalizedString("push_notif_volunteer_is_ready_to_pickup", comment: "")
        messageHeader.text = addVolunteerNameIfAvailable(headerText)
        messageBody.text = NSLocalizedString("dialog_accept_pending_volunteer", comment: "")
        yesButton.setTitle(NSLocalizedString("yes", comment: ""), forState: .Normal)
        noButton.setTitle(NSLocalizedString("no", comment: ""), forState: .Normal)
    }
    
    func addVolunteerNameIfAvailable(inputString: String) -> String {
        if let name = pickupRequest.pendingVolunteer?.name {
            let outputString = inputString.stringByReplacingOccurrencesOfString("{Volunteer}", withString: name)
            return outputString
        }
        else {
            let outputString = inputString.stringByReplacingOccurrencesOfString("{Volunteer}", withString: NSLocalizedString("a_volunteer", comment: ""))
            return outputString
        }
    }

}
