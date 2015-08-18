//
//  LoginViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/17/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

let kLoginViewControllerIdentifier = "loginViewController"

class LoginViewController: LogoImageViewController {
  @IBOutlet private weak var loginButton: UIButton!
  private var loadingHud: SCLAlertView?
}

// MARK: - View Life Cycle
extension LoginViewController {
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    setupVisuals()
  }
  
  override func viewDidAppear(animated: Bool)
  {
    super.viewDidAppear(animated)
    
    loadingHud?.activityIndicatorView.startAnimating()
  }
  
  private func setupVisuals()
  {
    view.backgroundColor = .backgroundColor
    
    loginButton.setTitleColor(.primaryColor, forState: .Normal)
    loginButton.backgroundColor = .secondaryColor
    loginButton.layer.cornerRadius = 5
  }
}

// MARK: - UI Action
extension LoginViewController {
  @IBAction func loginTapped(sender: AnyObject)
  {
    loadingHud = Utilities.showLoadingAlert("Logging in...", onViewController: self)
    
    SoundCloud.authenticateUser({ (success, error) -> Void in
      self.loadingHud!.hideView()
      
      if success {
        let tabBarController = self.storyboard!.instantiateInitialViewController()!
        self.presentViewController(tabBarController, animated: true, completion: nil)
      }
      else {
        ErrorHandler.handleNetworkingError("user credentials", error: error!)
      }
    })
  }
}