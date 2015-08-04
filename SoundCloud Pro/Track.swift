//
//  Track.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/11/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import SwiftyJSON
import Parse

@objc class Track: NSObject, NSCoding {
  var title: String!
  var artist: String!
  var duration: Double!
  var streamURL: String!
  
  private var jsonData: JSON!
  
  init(json: JSON)
  {
    // I wish I could just save jsonData to json or json["origin"] but that doesn't work
    if json["origin"].dictionary != nil {
      title = json["origin"]["title"].string!
      artist = json["origin"]["user"]["username"].string!
      duration = json["origin"]["duration"].doubleValue / 1000
      streamURL = json["origin"]["stream_url"].string! + "?client_id=\(kSoundCloudClientID)"
    } else {
      title = json["title"].string
      artist = json["user"]["username"].string
      duration = json["duration"].doubleValue / 1000
      streamURL = json["stream_url"].string! + "?client_id=\(kSoundCloudClientID)"
    }
    
    jsonData = json["origin"]
    super.init()

    assert(title != nil && artist != nil && duration != nil && streamURL != nil)
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    title = aDecoder.decodeObjectForKey(kTitleKey) as! String
    artist = aDecoder.decodeObjectForKey(kArtistKey) as! String
    duration = aDecoder.decodeDoubleForKey(kDurationKey)
    streamURL = aDecoder.decodeObjectForKey(kStreamURLKey) as! String
    jsonData = JSON(data: aDecoder.decodeObjectForKey(kTrackJSON) as! NSData)
  }
  
  private init(object: PFObject)
  {
    title = object[kTitleKey] as! String
    artist = object[kArtistKey] as! String
    duration = object[kDurationKey] as! Double
    streamURL = object[kStreamURLKey] as! String
  }
}

// MARK: - Interface
extension Track {
  var waveformURL: NSURL? {
    if let urlString = jsonData["waveform_url"].string {
      return NSURL(string: urlString)
    } else {
      return nil
    }
  }
  var artworkURL: NSURL! { return NSURL(string: jsonData["artwork_url"].string!) }
  
  func serializeToParseObject() -> PFObject
  {
    let track = PFObject(className: "Track")
    track[kTitleKey] = title
    track[kArtistKey] = artist
    track[kDurationKey] = duration
    track[kStreamURLKey] = streamURL
    
    return track
  }
  
  class func serializeFromParseObject(track: PFObject) -> Track
  {
    assert(track.parseClassName == "Track", "Can only serialize from Parse Track objects")
    return Track(object: track)
  }
}

// MARK: - Public Helpers
extension Track {
  class func isStreamable(json: JSON) -> Bool
  {
    return json["streamable"].boolValue || json["origin"]["streamable"].boolValue ||
            json["streamURL"].string != nil || json["origin"]["streamURL"].string != nil
  }
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
let kTitleKey = "title"
let kArtistKey = "artist"
let kDurationKey = "duration"
let kStreamURLKey = "streamURL"

extension Track {
  func encodeWithCoder(aCoder: NSCoder)
  {
    try! aCoder.encodeObject(jsonData.rawData(), forKey: kTrackJSON)
    aCoder.encodeObject(title, forKey: kTitleKey)
    aCoder.encodeObject(artist, forKey: kArtistKey)
    aCoder.encodeDouble(duration, forKey: kDurationKey)
    aCoder.encodeObject(streamURL, forKey: kStreamURLKey)
  }
}

// MARK: - Equatable
extension Track {}
func ==(lhs: Track, rhs: Track) -> Bool
{
//  NSLog("\(lhs) == \(rhs)? \((lhs.title == rhs.title && lhs.artist == rhs.artist) || lhs.streamURL == rhs.streamURL)")
  return (lhs.title == rhs.title && lhs.artist == rhs.artist) || lhs.streamURL == rhs.streamURL
}

func !=(lhs: Track, rhs: Track) -> Bool
{
  return !(lhs == rhs)
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