//
//  Parse+PromiseKit.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/3/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit
import Parse
import PromiseKit

extension PFUser {
  class func promiseSignUp(username: String, password: String) -> Promise<Bool>
  {
    return Promise<Bool> { fulfill, reject in
      let user = PFUser()
      user.username = username
      user.password = password
      user.signUpInBackgroundWithBlock({ (success, error) -> Void in
        if error == nil {
          fulfill(success)
        } else {
          reject(error!)
        }
      })
    }
  }
  
  class func promiseLogIn(username: String, password: String) -> Promise<PFUser>
  {
    return Promise<PFUser> { fulfill, reject in
      PFUser.logInWithUsernameInBackground(username, password: password, block: { (user, error) -> Void in
        if error == nil && user != nil {
          fulfill(user!)
        } else {
          reject(error!)
        }
      })
    }
  }
}