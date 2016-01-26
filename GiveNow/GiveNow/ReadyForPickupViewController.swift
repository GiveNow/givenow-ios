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
        let nameText = LocalizationHelper.nameForDonor(pickupRequest)
        promptHeader.text = String.localizedStringWithParameters("push_notif_volunteer_is_ready_to_pickup", phoneNumber: nil, name: nameText, code: nil)
        messageBody.text = NSLocalizedString("dialog_accept_pending_volunteer", comment: "")
        yesButton.setTitle(NSLocalizedString("yes", comment: ""), forState: .Normal)
        noButton.setTitle(NSLocalizedString("no", comment: ""), forState: .Normal)
    }
    
    @IBAction func donationIsNotReady() {
        backend.indicatePickupRequestIsNotReady(pickupRequest, completionHandler: {(result, error) -> Void in
            if let error = error {
                print(error)
            }
            else {
                self.dismissPrompt()
            }
        })
    }
    
    @IBAction func donationIsReady() {
        backend.confirmVolunteerForPickupRequest(pickupRequest, completionHandler: {(result, error) -> Void in
            if let error = error {
                print(error)
            }
            else {
                self.dismissPrompt()
            }
        })
    }
    
    func dismissPrompt() {
        if let parent = parentViewController as? ModalPromptViewController {
            if let grandParent = parent.parentViewController as? DonatingViewController {
                grandParent.updatePendingDonationChildView()
                grandParent.removeEmbeddedViewController(parent)
            }
        }
    }

}
