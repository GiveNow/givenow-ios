//
//  MyPendingDonationViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/12/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit
import Parse

private let reuseIdentifier = "donationCategory"
private let backend = Backend.sharedInstance()

class MyPendingDonationViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet weak var donationIcon: UIImageView!
    @IBOutlet weak var yourDonationLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var infoImage: UIImageView!
    @IBOutlet weak var helpButton: UIButton!
    
    var pickupRequest:PickupRequest!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        layoutView()
    }
    
    func layoutView() {
        addNote()
        localizeText()
        templateImages()
        setHeaderBasedOnRequestStatus()
    }

    func localizeText() {
        yourDonationLabel.text = NSLocalizedString("your_donation_label", comment: "")
        cancelButton.setTitle(NSLocalizedString("cancel_donation_button", comment: ""), forState: .Normal)
        
    }
    
    func templateImages() {
        if let image = UIImage(named: "info") {
            self.infoImage.image = image.imageWithRenderingMode(.AlwaysTemplate)
            self.infoImage.tintColor = UIColor.whiteColor()
        }
        if let image = UIImage(named: "store") {
            donationIcon.image = image.imageWithRenderingMode(.AlwaysTemplate)
            donationIcon.tintColor = UIColor.whiteColor()
        }
        if let image = UIImage(named: "help") {
            helpButton.setImage(image.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            helpButton.tintColor = UIColor.whiteColor()
        }
    }
    
    func addNote() {
        if let note = pickupRequest.note {
            self.noteLabel.text = note
        }
        else {
            self.noteLabel.text = nil
        }
    }
    
    func setHeaderBasedOnRequestStatus() {
        headerLabel.text = ""
        if pickupRequest.pendingVolunteer == nil && pickupRequest.confirmedVolunteer == nil {
            self.headerLabel.text = NSLocalizedString("request_status_waiting", comment: "")
        }
        else if pickupRequest.pendingVolunteer != nil && pickupRequest.confirmedVolunteer == nil {
            getNameForPendingHeader()
        }
        else if pickupRequest.confirmedVolunteer != nil {
            displayConfirmedHeader()
        }
        else {
            self.headerLabel.text = ""
        }
    }
    
    // This function is more or less duplicated on the menu prompt
    func getNameForPendingHeader() {
        if let user = pickupRequest.pendingVolunteer {
            user.fetchIfNeededInBackgroundWithBlock({(result, error) -> Void in
                if let volunteer = result as? User {
                    if let name = volunteer.name {
                        self.displayPendingHeader(name)
                    }
                    else {
                        let name = String.localizedString("a_volunteer")
                        self.displayPendingHeader(name)
                    }
                }
                else {
                    let name = String.localizedString("a_volunteer")
                    self.displayPendingHeader(name)
                }
            })
        }
    }
    
    
    func displayPendingHeader(name: String) {
        headerLabel.text = String.localizedStringWithParameters("push_notif_volunteer_is_ready_to_pickup", phoneNumber: nil, name: name, code: nil)
    }
    
    func displayConfirmedHeader() {
        let phoneNumberText = AppState.sharedInstance().userPhoneNumberOrReplacementText
        headerLabel.text = String.localizedStringWithParameters("request_status_volunteer_confirmed", phoneNumber: phoneNumberText, name: nil, code: nil)
    }
    

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        let title = NSLocalizedString("dialog_cancelDonation_title", comment: "")
        let message = NSLocalizedString("dialog_cancelDonation_message", comment: "")
        let yes = NSLocalizedString("dialog_cancelDonation_positiveButton", comment: "")
        let no = NSLocalizedString("dialog_cancelDonation_negativeButton", comment: "")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: yes, style: .Default, handler: { alert in
            self.cancelPickupRequest()
        }))
        alertController.addAction(UIAlertAction(title: no, style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: {})
    }
    
    // MARK: Collection View configuration
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let donationCategories = pickupRequest.donationCategories else {
            return 0
        }
        return donationCategories.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DonationCategoryCollectionViewCell
        let donationCategory = pickupRequest.donationCategories![indexPath.row]
        configureDonationCategoryCell(cell, donationCategory: donationCategory)
        cell.layer.cornerRadius = 5.0
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let size = CGSize(width: 120.0, height: 120.0)
        return size
    }
    
    func configureDonationCategoryCell(cell: DonationCategoryCollectionViewCell, donationCategory: DonationCategory) {
        
        addImageToCell(cell, donationCategory: donationCategory)
        cell.categoryLabel.text = donationCategory.getName()
    }
    
    func addImageToCell(cell: DonationCategoryCollectionViewCell, donationCategory: DonationCategory) {
        backend.getImageForDonationCategory(donationCategory, completionHandler: {(image, error) -> Void in
            if let image = image {
                cell.categoryImage.image = image
            }
            else if let error = error {
                print(error)
            }
        })
    }
    
    func cancelPickupRequest() {
        backend.markPickupRequestAsInactive(pickupRequest, completionHandler: {(result, error) -> Void in
            if let error = error {
                print(error)
            }
            else {
                if let parent = self.parentViewController as? DonatingViewController {
                    parent.initializeSearchController()
                    parent.centerMapOnUserLocation()
                    parent.myPickupRequest = nil
                    parent.navigationItem.title = ""
                }
                self.willMoveToParentViewController(nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }
        })
    }

    @IBAction func helpButtonTapped(sender: AnyObject) {
        
    }

}
