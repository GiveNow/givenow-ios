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
    
    var pickupRequest:PickupRequest!

    override func viewDidLoad() {
        super.viewDidLoad()
        setDonationIcon()
        collectionView.delegate = self
        collectionView.dataSource = self
        localizeText()
    }

    func localizeText() {
        headerLabel.text = NSLocalizedString("request_status_waiting", comment: "")
        yourDonationLabel.text = NSLocalizedString("your_donation_label", comment: "")
        cancelButton.setTitle(NSLocalizedString("cancel_donation_button", comment: ""), forState: .Normal)
        
    }
    
    func setDonationIcon() {
        if let image = UIImage(named: "store") {
            donationIcon.image = image.imageWithRenderingMode(.AlwaysTemplate)
            donationIcon.tintColor = UIColor.whiteColor()
        }
    }
    

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        backend.markPickupRequestAsInactive(pickupRequest, completionHandler: {(result, error) -> Void in
            if error != nil {
                print(error)
            }
            else {
                if let parent = self.parentViewController as? DonatingViewController {
                    parent.searchController.searchBar.hidden = false
                    parent.myPickupRequest = nil
                }
                self.willMoveToParentViewController(nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }
        })
    }
    
    // MARK: Collection View configuration
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if pickupRequest != nil && pickupRequest.donationCategories != nil {
            return pickupRequest.donationCategories!.count
        }
        else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DonationCategoryCollectionViewCell
        let donationCategory = pickupRequest.donationCategories![indexPath.row]
        configureDonationCategoryCell(cell, donationCategory: donationCategory)
        
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
            if image != nil {
                cell.categoryImage.image = image
            }
            else if error != nil {
                print(error)
            }
        })
    }


}
