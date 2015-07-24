//
//  Track.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/11/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import SwiftyJSON

@objc class Track: NSObject, NSCoding {
  private var jsonData: JSON
  
  init(json: JSON)
  {
    jsonData = json
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    jsonData = JSON(data: aDecoder.decodeObjectForKey(kTrackJSON) as! NSData)
  }
}

// MARK: - Interface
extension Track {
  var title: String! { return jsonData["origin"]["title"].string }
  var artist: String! { return jsonData["origin"]["user"]["username"].string }
  var duration: Double! { return jsonData["origin"]["duration"].doubleValue / 1000 }
  var streamURL: String! { return jsonData["origin"]["stream_url"].string! + "?client_id=\(kSoundCloudClientID)" }
  
  var waveformURL: NSURL? {
    if let urlString = jsonData["origin"]["waveform_url"].string {
      return NSURL(string: urlString)
    } else {
      return nil
    }
  }
  var artworkURL: NSURL! { return NSURL(string: jsonData["origin"]["artwork_url"].string!) }
}

// MARK: - Helpers
extension Track {
  private func milliToString(milliSeconds: Double?) -> String!
  {
    return ""
  }
}

// MARK: - NSCoding
let kTrackJSON = "json"

extension Track {
  func encodeWithCoder(aCoder: NSCoder)
  {
    try! aCoder.encodeObject(jsonData.rawData(), forKey: kTrackJSON)
  }
}

// MARK: - Equatable
extension Track {}
func ==(lhs: Track, rhs: Track) -> Bool
{
//  NSLog("\(lhs) == \(rhs)? \((lhs.title == rhs.title && lhs.artist == rhs.artist) || lhs.streamURL == rhs.streamURL)")
  return (lhs.title == rhs.title && lhs.artist == rhs.artist) || lhs.streamURL == rhs.streamURL
}

func ==(lhs: AnyObject, rhs: Track) -> Bool
{
  if lhs is Track { return lhs as! Track == rhs }
  return false
}

func ==(lhs: Track, rhs: AnyObject) -> Bool
{
  return rhs == lhs
}

func ===(lhs: Track, rhs: Track) -> Bool
{
  return lhs == rhs
}

// MARK: - Hashable
extension Track {
  override var hashValue: Int { return title.hashValue } // This doesn't work
}

// MARK: - Debug Printing
extension Track: CustomDebugStringConvertible {
  override var description: String { return "\(artist): \(title)" }
  override var debugDescription: String { return description }
}