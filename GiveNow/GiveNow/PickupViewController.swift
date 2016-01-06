//
//  PickupViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 12/20/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import UIKit
import Parse

//// https://github.com/GiveNow/givenow-ios/issues/8
//// ToDo:
//Fetch pending donations
//Display donations on a map
//Select a donation and send notification to confirm donation is ready for pick up
//Set donation as picked up and dropped off

class PickupViewController: BaseViewController {
    
    var openPickupRequests:[PickupRequest]!
    
    let backend = Backend.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPickupRequests()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchPickupRequests() {        
        let query = backend.queryOpenPickupRequests()
        backend.fetchPickupRequestsWithQuery(query, completionHandler: { (result, error) -> Void in
            if error != nil {
                print(error)
            }
            else if let pickupRequests = result as? [PickupRequest] {
                self.openPickupRequests = pickupRequests
            }
        })
    
    }
    

}
