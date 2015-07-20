//
//  SCAPI.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/10/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import SwiftyJSON

class SoundCloud {
  private static var nextStreamUrl: String?
  
  class func getStream(callback: (tracks: [Track]) -> Void)
  {
    let url = urlWithEndpoint("me/activities/tracks/affiliated")
    let params = ["limit": "30"]
    SCRequest.performMethod(SCRequestMethodGET,
                            onResource: url,
                            usingParameters: params,
                            withAccount: SCSoundCloud.account(),
                            sendingProgressHandler: nil) { (response, data, error) -> Void in
      NSLog("response: \(response)")
                              if requestSucceeded(response, error: error) {
      processStreamJSON(data, callback: callback)
                              }
    }
  }

}

// MARK: - Helpers
extension SoundCloud {
  private class func urlWithEndpoint(endpoint: String) -> NSURL!
  {
    return NSURL(string: kSCSoundCloudAPIURL + endpoint)
  }
  
  private class func requestSucceeded(response: NSURLResponse, error: NSError?) -> Bool
  {
    if let httpResponse = response as? NSHTTPURLResponse {
      return httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
    }
    
    return error != nil
  }
  
  private class func processStreamJSON(data: NSData, callback: (tracks: [Track]) -> Void)
  {
    let json = JSON(data: data)
    NSLog("stream json: \(json)")
    
    let tracks = json["collection"].array!.map { return Track(json: $0) }
    callback(tracks: tracks)
  }
}
