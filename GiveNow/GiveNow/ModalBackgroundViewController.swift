//
//  ModalBackgroundViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/14/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit

protocol ModalBackgroundViewControllerDelegate {
    func modalViewDismissedWithResult(controller:ModalBackgroundViewController)
}

class ModalBackgroundViewController: BaseViewController, UIGestureRecognizerDelegate, LoginModalViewControllerDelegate {
    
    var delegate:ModalBackgroundViewControllerDelegate!
    var backgroundView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackgroundView()
        displayModalLoginView()
    }
    
    func configureBackgroundView() {
        backgroundView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height))
        backgroundView.backgroundColor = UIColor.darkGrayColor()
        backgroundView.alpha = 0.8
        view.addSubview(backgroundView)
        
        addTapGestureRecognizer()
    }
    
    func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: Selector("backgroundTapped:"))
        tap.delegate = self
        backgroundView.addGestureRecognizer(tap)
    }
    
    func backgroundTapped(sender: UIGestureRecognizer? = nil) {
        dismissViewControllerAnimated(true, completion: {})
    }
    
    func displayModalLoginView() {
        let modalLoginView = LoginModalViewController(nibName: "LoginModalViewController", bundle: nil)
        modalLoginView.delegate = self
        modalLoginView.isModal = true
        addChildViewController(modalLoginView)
        
        let frame = CGRect(x: 20, y: 80, width: view.frame.width - 40, height: view.frame.height/2 - 80)
        modalLoginView.view.frame = frame
        view.addSubview(modalLoginView.view)
        modalLoginView.didMoveToParentViewController(self)
    }
    
    func successfulLogin(controller: LoginModalViewController) {
        delegate.modalViewDismissedWithResult(self)
        dismissViewControllerAnimated(true, completion: {})
    }
    
}
