//
//  DonationCategoriesViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/7/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit
import MapKit
import Parse

private let reuseIdentifier = "donationCategory"
private let backend = Backend.sharedInstance()

class DonationCategoriesViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UITextFieldDelegate, ModalLoginViewControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var donationCategories:[DonationCategory]!
    var location:CLLocationCoordinate2D!
    var address:String!
    
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var giveNowButton: UIButton!
    @IBOutlet weak var addNoteButton: UIButton!
    @IBOutlet weak var infoImage: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var doneNoteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextField.delegate = self
        fetchDonationCategories()
        layoutView()
        localizeText()
        validateGiveNowButton()
    }
    
    func layoutView() {
        headerView.addShadow()
        setImages()
        formatNote()
        formatButtons()
    }
    
    func setImages() {
        if let image = UIImage(named: "info") {
            self.infoImage.image = image.imageWithRenderingMode(.AlwaysTemplate)
            self.infoImage.tintColor = UIColor.whiteColor()
        }
    }
    
    func formatNote() {
        doneNoteButton.alpha = 0.0
        noteTextField.alpha = 0.0
    }
    
    func formatButtons() {
        guard let button = giveNowButton else {
            return
        }
        
        if let image = UIImage(named: "add_note") {
            self.addNoteButton.setImage(image.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            self.addNoteButton.tintColor = UIColor.whiteColor()
        }
        
        if let image = UIImage(named: "done-check") {
            self.doneNoteButton.setImage(image.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            self.doneNoteButton.tintColor = UIColor.whiteColor()
        }
        addNoteButton.setTitle(NSLocalizedString("note_add_label", comment: ""), forState: .Normal)
        if let image = UIImage(named: "help") {
            self.helpButton.setImage(image.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            self.helpButton.tintColor = UIColor.whiteColor()
        }
        
        button.layer.cornerRadius = 5.0
        button.addShadow()
    }
    
    func localizeText() {
        giveNowButton.setTitle(NSLocalizedString("button_confirm_donation_label", comment: ""), forState: .Normal)
        infoLabel.text = NSLocalizedString("request_pickup_info_select_categories", comment: "")
        if noteTextField.respondsToSelector("attributedPlaceholder") {
            let attributedDict = [NSForegroundColorAttributeName: UIColor.whiteColor()]
            noteTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("address_field_note_hint", comment: ""), attributes: attributedDict)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    // MARK: Getting data from Parse
    
    func fetchDonationCategories(){
        let query = backend.queryTopNineDonationCategories()
        backend.fetchDonationCategoriesWithQuery(query, completionHandler: {(result, error) -> Void in
            if let error = error {
                print(error)
            }
            else {
                if let donationCategories = result as? [DonationCategory] {
                    self.donationCategories = donationCategories
                    self.collectionView.reloadData()
                    self.validateGiveNowButton()
                }
            }
        })
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if donationCategories != nil {
            return donationCategories.count
        }
        else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DonationCategoryCollectionViewCell
        let donationCategory = donationCategories[indexPath.row]
        configureDonationCategoryCell(cell, donationCategory: donationCategory)
        cell.layer.cornerRadius = 5.0
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        //Assuming a margin of 10.0, and three columns
        let dimension = (view.frame.width - 40) / 3
        let size = CGSize(width: dimension, height: dimension)
        return size
    }
    
    func configureDonationCategoryCell(cell: DonationCategoryCollectionViewCell, donationCategory: DonationCategory) {
        
        addImageToCell(cell, donationCategory: donationCategory)
        cell.categoryLabel.text = donationCategory.getName()
        
        cell.layer.masksToBounds = false
        cell.addShadow()
        
        if donationCategory.selected == true {
            highlightCell(cell)
        }
        else {
            unHighlightCell(cell)
        }
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
    
    //MARK: Selecting cells
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let donationCategory = donationCategories[indexPath.row]
        
        if donationCategory.selected == nil || donationCategory.selected == false {
            donationCategory.selected = true
        }
        else {
            donationCategory.selected = false
        }
        collectionView.reloadItemsAtIndexPaths([indexPath])
        validateGiveNowButton()
    }
    
    func highlightCell(cell: DonationCategoryCollectionViewCell) {
        cell.categoryLabel.backgroundColor = UIColor.colorAccent()
        cell.categoryLabel.textColor = UIColor.whiteColor()
        cell.removeShadow()
    }
    
    func unHighlightCell(cell: DonationCategoryCollectionViewCell) {
        cell.categoryLabel.backgroundColor = UIColor.lightGrayColor()
        cell.categoryLabel.textColor = UIColor.whiteColor()
        cell.addShadow()
    }
    
    //MARK: Completing selection
    
    private func validateGiveNowButton() {
        if let donationCategories = donationCategories {
            let selectedDonationCategories = donationCategories.filter() {$0.selected == true}
            if selectedDonationCategories.count > 0 {
                giveNowButton.enabled = true
                giveNowButton.toggleShadowOn()
                giveNowButton.backgroundColor = UIColor.colorAccent()
            }
            else {
                giveNowButton.toggleShadowOff()
                giveNowButton.enabled = false
                giveNowButton.backgroundColor = UIColor.colorAccentDisabled()
            }
        }
        else {
            giveNowButton.toggleShadowOff()
            giveNowButton.enabled = false
            giveNowButton.backgroundColor = UIColor.colorAccentDisabled()
        }
    }
    
    @IBAction func giveNowButtonTapped(sender: AnyObject) {
        if AppState.sharedInstance().isUserRegistered {
            savePickupRequest()
        }
        else {
            createModalLoginView(self)
        }
    }
    
    func savePickupRequest() {
        let selectedDonationCategories = donationCategories.filter() {$0.selected == true}
        let latitude = location.latitude
        let longitude = location.longitude
        let pfLocation = PFGeoPoint(latitude: latitude, longitude: longitude)
        let note = noteTextField.text
        backend.savePickupRequest(selectedDonationCategories, address: address, location: pfLocation, note: note, completionHandler: { (result, error) -> Void in
            if let error = error {
                print(error)
            }
            else {
                Permissions.registerForNotificationsIfNeeded()
                self.performSegueWithIdentifier("newPickupRequestCreated", sender: nil)
            }
        })
    }
    
    func modalViewDismissedWithResult(controller: ModalLoginViewController) {
        savePickupRequest()
    }
    
    
    @IBAction func addNoteButtonTapped(sender: AnyObject) {
        UIView.animateWithDuration(0.5, animations: {() -> Void in
            
            self.addNoteButton.setTitle("", forState: .Normal)
            self.doneNoteButton.alpha = 1.0
            self.addNoteButton.alpha = 0.0
            self.noteTextField.alpha = 1.0
            }, completion: { finished in
            self.noteTextField.becomeFirstResponder()
        })
    }
    

    @IBAction func doneNoteTapped(sender: AnyObject) {
        noteTextField.resignFirstResponder()
    }
    
    @IBAction func noteEditingEnded(sender: AnyObject) {
        doneEditingNote()
    }
    
    func doneEditingNote() {
        UIView.animateWithDuration(0.5, animations: {() -> Void in
            
            var title:String!
            if self.noteTextField.text != nil && self.noteTextField.text != "" {
                title = "  " + self.noteTextField.text!
                if let image = UIImage(named: "note_added") {
                    self.addNoteButton.setImage(image.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                }
            }
            else {
                title = NSLocalizedString("note_add_label", comment: "")
                if let image = UIImage(named: "add_note") {
                    self.addNoteButton.setImage(image.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                }
            }
            self.addNoteButton.setTitle(title, forState: .Normal)
            self.doneNoteButton.alpha = 0.0
            self.addNoteButton.alpha = 1.0
            self.noteTextField.alpha = 0.0
        })
    }

    @IBAction func helpButtonTapped(sender: AnyObject) {
        
    }
}
