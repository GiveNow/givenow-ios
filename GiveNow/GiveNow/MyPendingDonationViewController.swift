//
//  MyPendingDonationViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/12/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit

class MyPendingDonationViewController: BaseViewController {
    
    @IBOutlet weak var donationIcon: UIImageView!
    @IBOutlet weak var yourDonationLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pickupRequest:PickupRequest!

    override func viewDidLoad() {
        super.viewDidLoad()
        setDonationIcon()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDonationIcon() {
        donationIcon.image = UIImage(named: "store")!.imageWithRenderingMode(.AlwaysTemplate)
        donationIcon.tintColor = UIColor.whiteColor()
    }
    

    @IBAction func cancelButtonTapped(sender: AnyObject) {
    }


}
