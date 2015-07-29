//
//  SCAPI.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/10/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import SwiftyJSON

typealias StreamFetchCallback = (tracks: [Track]!, error: NSError!) -> Void

class SoundCloud {
  private static var nextStreamUrl: String?
}

// MARK: - Interface
extension SoundCloud {
  class func getStream(callback: StreamFetchCallback)
  {
    getStreamWithURLString(kSCSoundCloudAPIURL + "me/activities/tracks/affiliated", callback: callback)
  }
  
  class func getMoreStream(callback: StreamFetchCallback)
  {
    getStreamWithURLString(nextStreamUrl!, callback: callback)
  }
  
  private class func getStreamWithURLString(urlString: String, callback: StreamFetchCallback)
  {
    let url = NSURL(string: urlString)
    let params = ["limit": "30"]
    SCRequest.performMethod(SCRequestMethodGET,
                            onResource: url,
                            usingParameters: params,
                            withAccount: SCSoundCloud.account(),
                            sendingProgressHandler: nil) { (response, data, error) -> Void in
      NSLog("response: \(response)")
      if requestSucceeded(response, error: error) {
        processStreamJSON(data, callback: callback)
      } else {
        callback(tracks: nil, error: error)
      }
    }
  }
}

// MARK: - Helpers
extension SoundCloud {
  private class func requestSucceeded(response: NSURLResponse, error: NSError?) -> Bool
  {
    if let httpResponse = response as? NSHTTPURLResponse {
      return httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
    }
    
    return error != nil
  }
  
  private class func processStreamJSON(data: NSData, callback: StreamFetchCallback)
  {
    let json = JSON(data: data)
    print("stream json: \(json)")
    nextStreamUrl = json["next_href"].string
    
    let tracks = json["collection"].array!.filter { !$0["type"].stringValue.hasPrefix("playlist") }  // remove playlist types for now
                                          .map { Track(json: $0) }
                                          // this is fucked up. .contains doesn't by default call "==" on all the elements
                                          .filter { track in !UserPreferences.downvotes.contains { track == $0 } }
                                          .uniqueElements()
    callback(tracks: tracks, error: nil)
  }
}
