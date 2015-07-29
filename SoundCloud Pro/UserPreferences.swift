//
//  UserPreferences.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/20/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

class UserPreferences {
  private static let settings = NSUserDefaults.standardUserDefaults()

  private static let upvoteKey = "upvotes"
  private static let downvoteKey = "downvotes"
}

// MARK: - Interface
extension UserPreferences {
  class func addUpvote(track: Track)
  {
    upvotes = upvotes + [track]
    removeDownvote(track)
  }
  
  class func removeUpvote(track: Track)
  {
    // Can only delete 1 at a time as per UITableView's requirements on deletion of a row
    if let index = upvotes.indexOf({ $0 == track }) {
      upvotes.removeAtIndex(index)
      saveTracks(upvotes, forKey: upvoteKey)
    }
  }
  
  class func addDownvote(track: Track)
  {
    downvotes = downvotes + [track]
    removeUpvote(track)
  }
  
  class func removeDownvote(track: Track)
  {
    // Can only delete 1 at a time as per UITableView's requirements on deletion of a row
    if let index = downvotes.indexOf({ $0 == track }) {
      downvotes.removeAtIndex(index)
      saveTracks(downvotes, forKey: downvoteKey)
    }
  }
  
  private(set) static var upvotes: [Track] {
    get { return getTracksForKey(upvoteKey) }
    set { saveTracks(newValue, forKey: upvoteKey)
    }
  }
  
  private(set) static var downvotes: [Track] {
    get { return getTracksForKey(downvoteKey) }
    set { saveTracks(newValue, forKey: downvoteKey) }
  }
  
  class func clearAllSettings()
  {
    upvotes = []
    downvotes = []
  }
}

// MARK: - Helpers
extension UserPreferences {
  private class func saveTracks(tracks: [Track], forKey key: String)
  {
    let tracksData = tracks.map { NSKeyedArchiver.archivedDataWithRootObject($0) }
    settings.setValue(tracksData, forKey: key)
    settings.synchronize()
  }
  
  private class func getTracksForKey(key: String) -> [Track]
  {
    return settings.arrayForKey(key)?.map { NSKeyedUnarchiver.unarchiveObjectWithData($0 as! NSData)! } as? [Track] ?? []
  }
}
