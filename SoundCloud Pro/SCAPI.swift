//
//  SCAPI.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/10/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import SwiftyJSON

typealias NetworkCallback = (response: NSURLResponse!, responseData: NSData!, error: NSError!) -> Void
typealias FetchTracksCallback = (tracks: [Track]!, error: NSError!) -> Void

class SoundCloud {
  private static var nextStreamUrl: String?
}

// MARK: - Interface
extension SoundCloud {
  class func getStream(callback: FetchTracksCallback)
  {
    getStreamWithURLString(kSCSoundCloudAPIURL + "me/activities/tracks/affiliated", callback: callback)
  }
  
  class func getMoreStream(callback: FetchTracksCallback)
  {
    getStreamWithURLString(nextStreamUrl!, callback: callback)
  }
  
  class func getTracksMatching(searchString: String, callback: FetchTracksCallback)
  {
    let params = ["q": searchString]
    GET(kSCSoundCloudAPIURL + "tracks", params: params) { (response, responseData, error) -> Void in
      if requestSucceeded(response, error: error) {
        let tracks = processSearchJSON(responseData)
        callback(tracks: tracks, error: nil)
      } else {
        callback(tracks: nil, error: error)
      }
    }
  }
  
  private class func getStreamWithURLString(urlString: String, callback: FetchTracksCallback)
  {
    let params = ["limit": "30"]
    GET(urlString, params: params) { (response, responseData, error) -> Void in
      if requestSucceeded(response, error: error) {
        let tracks = processStreamJSON(responseData)
        callback(tracks: tracks, error: nil)
      } else {
        callback(tracks: nil, error: error)
      }
    }
  }
}

// MARK: - Helpers
extension SoundCloud {
  private class func GET(urlString: String, params: [NSObject: AnyObject], callback: NetworkCallback)
  {
    SCRequest.performMethod(SCRequestMethodGET,
                            onResource: NSURL(string: urlString),
                            usingParameters: params,
                            withAccount: SCSoundCloud.account(),
                            sendingProgressHandler: nil,
                            responseHandler: callback)
  }
  
  private class func requestSucceeded(response: NSURLResponse, error: NSError?) -> Bool
  {
    if let httpResponse = response as? NSHTTPURLResponse {
      return httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
    }
    
    return error != nil
  }
  
  private class func processStreamJSON(data: NSData) -> [Track]
  {
    let json = JSON(data: data)
    print("stream json: \(json)")
    nextStreamUrl = json["next_href"].string
    
    let tracks = json["collection"].array!.filter { !$0["type"].stringValue.hasPrefix("playlist") }  // remove playlist types for now
                                          .map { Track(json: $0) }
                                          // this is fucked up. .contains doesn't by default call "==" on all the elements
                                          .filter { track in !UserPreferences.downvotes.contains { track == $0 } }
                                          .uniqueElements()
    return tracks
  }
  
  private class func processSearchJSON(data: NSData) -> [Track]
  {
    let json = JSON(data: data)
    print("search json: \(json)")
    return json.array!.map { Track(json: $0) }
  }
}
