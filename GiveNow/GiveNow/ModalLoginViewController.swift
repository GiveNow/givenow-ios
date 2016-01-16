//
//  ModalLoginViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/14/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit

protocol ModalLoginViewControllerDelegate {
    func modalViewDismissedWithResult(controller:ModalLoginViewController)
}

class ModalLoginViewController: BaseViewController, UIGestureRecognizerDelegate, LoginViewControllerDelegate {
    
    var delegate:ModalLoginViewControllerDelegate!
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
        let loginView = LoginViewController(nibName: "LoginViewController", bundle: nil)
        loginView.delegate = self
        loginView.isModal = true
        addChildViewController(loginView)
        
        let frame = CGRect(x: 20, y: 80, width: view.frame.width - 40, height: view.frame.height/2 - 80)
        loginView.view.frame = frame
        view.addSubview(loginView.view)
        loginView.didMoveToParentViewController(self)
    }
    
    func successfulLogin(controller: LoginViewController) {
        delegate.modalViewDismissedWithResult(self)
        dismissViewControllerAnimated(true, completion: {})
    }
    
    
}
