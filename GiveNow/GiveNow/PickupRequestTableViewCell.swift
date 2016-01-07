//
//  PickupRequestTableViewCell.swift
//  GiveNow
//
//  Created by Evan Waters on 1/5/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit

class PickupRequestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    var pickupRequest:PickupRequest!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
