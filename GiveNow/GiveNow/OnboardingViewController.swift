//
//  OnboardingViewController.swift
//  GiveNow
//
//  Created by Brennan Stehling on 12/16/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import UIKit

// TODO: implement
// See https://github.com/GiveNow/givenow-ios/issues/4
// See https://github.com/GiveNow/givenow-ios/issues/5

class OnboardingViewController: BaseViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var pageControl : UIPageControl!
    
    typealias OnboardingText = (title: String, details: String)
    
    struct CellConfig {
        let color : UIColor
        let text : OnboardingText
        let imageName : String
    }
    
    static let onboardingTextArray : [OnboardingText]  = [
        ("Welcome to Give Now.",
        "GiveNow lets you donate from anywhere."),
        
        ("We show you what's needed most in your area.",
        "You select what you want to donate."),
        
        ("Tell us where to pick it up.",
        "Simply pinpoint a spot on the map. You can even add special instructions like apartment numbers or gate codes."),
        
        ("We take care of the rest.",
        "A trusted volunteer driver will pick up your donation. We'll contact you to coordinate the pickup.")
    ]
    
    let onboardingConfigs = [
        CellConfig(color: UIColor.greenColor(), text: onboardingTextArray[0], imageName: "onboarding_2_image"),
        CellConfig(color: UIColor.orangeColor(), text: onboardingTextArray[1], imageName: "onboarding_2_image"),
        CellConfig(color: UIColor.blueColor(), text: onboardingTextArray[2], imageName:  "onboarding_3_image"),
        CellConfig(color: UIColor.purpleColor(), text: onboardingTextArray[3], imageName: "onboarding_4_image"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.view.frame.size
    }
    
    //MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row < onboardingConfigs.count {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("OnboardingCell", forIndexPath: indexPath) as! OnboardingCollectionViewCell
            let cellConfig = onboardingConfigs[indexPath.row]
            cell.backgroundColor = cellConfig.color
            cell.mainLabel.text = cellConfig.text.title
            cell.detailsLabel.text = cellConfig.text.details
            cell.imageView.image = UIImage(named: cellConfig.imageName)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SignInCell", forIndexPath: indexPath)
            cell.backgroundColor = UIColor.magentaColor()
            return cell
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onboardingConfigs.count + 1 //Sign In Cell
    }
    
    //MARK: UICollectionViewDelegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageWidth = self.view.frame.size.width
        self.pageControl.currentPage = Int(scrollView.contentOffset.x / pageWidth)
    }

}

class OnboardingCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var mainLabel : UILabel!
    @IBOutlet weak var detailsLabel : UILabel!
    @IBOutlet weak var imageView : UIImageView!
}
