//
//  ErrorHandler.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/28/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

class ErrorHandler {
  class func handleNetworkingError(requestDescription: String, error: NSError!)
  {
    let message = "There was a problem \(requestDescription), please check your internet connection and try again."
    Utilities.showLoadingAlert(message, onViewController: nil)
    
    if error != nil {
      NSLog("Error \(requestDescription), details: \(error)")
    } else {
      NSLog("Error \(requestDescription)")
    }
  }
  
  class func handleBackgroundAudioError()
  {
    SCLAlertView().showError("Something went wrong", subTitle: "I couldn't enable playing audio when you exit the app =/", closeButtonTitle: "Ok", duration: 0)    
    NSLog("Could not enable background audio")
  }
}
