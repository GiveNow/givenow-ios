//
//  ThankYouPromptViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/19/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit

class ThankYouPromptViewController: BaseViewController {

    @IBOutlet weak var promptImage: UIImageView!
    @IBOutlet weak var promptHeader: UILabel!
    @IBOutlet weak var messageBody: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    
    var pickupRequest:PickupRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeStrings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func localizeStrings() {
        promptHeader.text = NSLocalizedString("donation_complete_title", comment: "")
        formatMessageBody()
        doneButton.setTitle(NSLocalizedString("done", comment: ""), forState: .Normal)
        rateButton.setTitle(NSLocalizedString("rate_app", comment: ""), forState: .Normal)
    }
    
    func formatMessageBody(){
        guard let categories = pickupRequest.donationCategories else {
            return
        }
        var message = NSLocalizedString("donation_complete_message_head", comment: "")
        
        for var i = 0; i < categories.count; i++ {
            categories[i].fetchIfNeededInBackgroundWithBlock({(result, error) -> Void in
                let category = result as! DonationCategory
                let categoryName = category.getName()!
                if i == 0 {
                    message += " \(categoryName)"
                }
                else if i < categories.count - 1 {
                    message += ", \(categoryName)"
                }
                else {
                    message += " \(NSLocalizedString("and", comment: "")) \(categoryName) \(NSLocalizedString("donation_complete_message_tail", comment: ""))"
                    self.messageBody.text = message
                }
            })
        }
    }
    
    @IBAction func rateApp() {
        closeDonation()
        //To Do: Open app store to rate app
    }
    
    @IBAction func donePressed() {
        closeDonation()
    }
    
    func closeDonation() {
        backend.markComplete(pickupRequest, completionHandler: {(resut, error) -> Void in
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
//                grandParent.removePendingDonationChildView()
                grandParent.removeEmbeddedViewController(parent)
            }
        }
    }

}
