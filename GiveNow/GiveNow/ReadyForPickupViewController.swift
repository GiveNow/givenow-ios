//
//  ReadyForPickupViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/16/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit

class ReadyForPickupViewController: BaseViewController {
    
    @IBOutlet weak var promptImage: UIImageView!
    @IBOutlet weak var promptHeader: UILabel!
    @IBOutlet weak var messageBody: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    var pickupRequest:PickupRequest!

    override func viewDidLoad() {
        super.viewDidLoad()
        localizeStrings()
        
        if let address = pickupRequest.address {
            addressLabel.text = address
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func localizeStrings() {
        let headerText = NSLocalizedString("push_notif_volunteer_is_ready_to_pickup", comment: "")
        promptHeader.text = addVolunteerNameIfAvailable(headerText)
        messageBody.text = NSLocalizedString("dialog_accept_pending_volunteer", comment: "")
        yesButton.setTitle(NSLocalizedString("yes", comment: ""), forState: .Normal)
        noButton.setTitle(NSLocalizedString("no", comment: ""), forState: .Normal)
    }
    
    func addVolunteerNameIfAvailable(inputString: String) -> String {
        var outputString:String = inputString.stringByReplacingOccurrencesOfString("{Volunteer}", withString: NSLocalizedString("a_volunteer", comment: ""))
        do {
            let user = try pickupRequest.donor?.fetchIfNeeded()
            if let name = user!.name {
                outputString = inputString.stringByReplacingOccurrencesOfString("{Volunteer}", withString: name)
            }
        } catch _ {
            print("Error getting name")
        }
        return outputString
    }

}
