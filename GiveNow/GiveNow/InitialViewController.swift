//
//  InitialViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/11/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        detectFirstLaunch()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func detectFirstLaunch(){
        print("Detecting first launch")
        let firstLaunch = NSUserDefaults.standardUserDefaults().boolForKey("FirstLaunch")
        if firstLaunch  {
            print("Not the first time")
            performSegueWithIdentifier("mainView", sender: nil)
        }
        else {
            print("The first time")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstLaunch")
            performSegueWithIdentifier("onboarding", sender: nil)
        }
    }

}
