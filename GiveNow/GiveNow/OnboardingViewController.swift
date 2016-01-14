//
//  OnboardingViewController.swift
//  GiveNow
//
//  Created by Brennan Stehling on 12/16/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import UIKit

class OnboardingViewController: BaseViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate, LoginModalViewControllerDelegate {
    
    @IBOutlet weak var pageControl : UIPageControl?
    
    typealias OnboardingText = (title: String, details: String)
    
    struct CellConfig {
        let color : UIColor
        let text : OnboardingText
        let imageName : String
    }
    
    //TODO: Localize
    static let onboardingTextArray : [OnboardingText]  = [
        
        (NSLocalizedString("onboarding_1_title", comment: ""), NSLocalizedString("onboarding_1_description", comment: "")),
        
        (NSLocalizedString("onboarding_2_title", comment: ""), NSLocalizedString("onboarding_2_description", comment: "")),
        
        (NSLocalizedString("onboarding_3_title", comment: ""), NSLocalizedString("onboarding_3_description", comment: "")),
        
        (NSLocalizedString("onboarding_4_title", comment: ""), NSLocalizedString("onboarding_4_description", comment: ""))
    ]
    
    let onboardingConfigs = [
        CellConfig(color: UIColor.colorPrimary(), text: onboardingTextArray[0], imageName: "round_icon"),
        CellConfig(color: UIColor.colorPrimaryDark(), text: onboardingTextArray[1], imageName: "onboarding_2_image"),
        CellConfig(color: UIColor.colorPrimary(), text: onboardingTextArray[2], imageName:  "onboarding_3_image"),
        CellConfig(color: UIColor.colorAlternate(), text: onboardingTextArray[3], imageName: "onboarding_4_image"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.view.frame.size
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onboardingConfigs.count + 1 //Sign In Cell
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row < onboardingConfigs.count {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("OnboardingCell", forIndexPath: indexPath)
            let cellConfig = onboardingConfigs[indexPath.row]
            cell.backgroundColor = cellConfig.color
            if let onboardingCell = cell as? OnboardingCollectionViewCell {
                onboardingCell.mainLabel?.text = cellConfig.text.title
                onboardingCell.detailsLabel?.text = cellConfig.text.details
                onboardingCell.imageView?.image = UIImage(named: cellConfig.imageName)
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SignInCell", forIndexPath: indexPath) as! SignUpCollectionViewCell
            cell.backgroundColor = UIColor.colorAccent()
            addLoginControllerToCell(cell)
            return cell
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageWidth = self.view.frame.size.width
        self.pageControl?.currentPage = Int(scrollView.contentOffset.x / pageWidth)
    }
    
    // MARK: Login
    
    private func addLoginControllerToCell(cell: UICollectionViewCell) {
        let modalLoginView = LoginModalViewController(nibName: "LoginModalViewController", bundle: nil)
        modalLoginView.delegate = self
        modalLoginView.isModal = false
        
        //To Do: Replace this with parent 'embed' method
        addChildViewController(modalLoginView)
        let frame = CGRect(x: 20, y: 80, width: view.frame.width - 40, height: view.frame.height/2 - 80)
        modalLoginView.view.frame = frame
        cell.addSubview(modalLoginView.view)
        modalLoginView.didMoveToParentViewController(self)
    }
    
    func successfulLogin(controller: LoginModalViewController) {
        dismissOnboardingView()
    }
    
    @IBAction func addAPhoneNumberLater(sender: AnyObject) {
        dismissOnboardingView()
    }
    
    func dismissOnboardingView() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstLaunch")
        
        if let parent = self.parentViewController as? InitialViewController {
            parent.displayMainViewController()
        }
        else {
            print("Not the parent")
        }
        
        removeEmbeddedViewController(self)
    }

}

class OnboardingCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var mainLabel : UILabel?
    @IBOutlet weak var detailsLabel : UILabel?
    @IBOutlet weak var imageView : UIImageView?
}

// MARK: Log in
class SignUpCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var addPhoneLaterButton: UIButton!
    
    override func awakeFromNib() {
        orLabel.text = NSLocalizedString("onboarding_or", comment: "")
        addPhoneLaterButton.setTitle(NSLocalizedString("onboarding_add_phone_number_later_button", comment: ""), forState: .Normal)
        super.awakeFromNib()
    }
    
    
}
