//
//  Track.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/11/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import SwiftyJSON

class Track {
  private var jsonData: JSON
  
  init(json: JSON)
  {
    jsonData = json
  }
}

// MARK: - Interface
extension Track {
  var title: String! { return jsonData["origin"]["title"].string }
  var artist: String! { return jsonData["origin"]["user"]["username"].string }
  var duration: Double! { return jsonData["origin"]["duration"].doubleValue / 1000 }
  var streamURL: String! { return jsonData["origin"]["stream_url"].string }
  
  var waveformURL: NSURL? {
    if let urlString = jsonData["origin"]["waveform_url"].string {
      return NSURL(string: urlString)
    } else {
      return nil
    }
  }
  var artworkURL: NSURL! { return NSURL(string: jsonData["origin"]["artwork_url"].string!) }
}

// MARK: - Equatable
extension Track: Equatable {}
func ==(lhs: Track, rhs: Track) -> Bool
{
  return lhs.title == rhs.title && lhs.artist == rhs.artist
}

// MARK: - Helpers
extension Track {
  private func milliToString(milliSeconds: Double?) -> String!
  {
    return ""
  }
}