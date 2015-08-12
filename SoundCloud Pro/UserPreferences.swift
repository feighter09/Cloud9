//
//  UserPreferences.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/20/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

let kOnTheGoPlaylistName = "On The Go"

class UserPreferences {
  private static let settings = NSUserDefaults.standardUserDefaults()

  private static let upvoteKey = "upvotes"
  private static let downvoteKey = "downvotes"
  private static let onTheGoPlaylistKey = "onTheGoPlaylist"
}

// MARK: - General
extension UserPreferences {
  class func clearAllSettings()
  {
    upvotes = []
    downvotes = []
  }
}

// MARK: - Votes
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
}

// MARK: - On The Go Playlist
extension UserPreferences {
  class func addTrackToOnTheGoPlaylist(track: Track)
  {
    let newTracks = onTheGoPlaylist.tracks + [track]
    saveTracks(newTracks, forKey: onTheGoPlaylistKey)
  }
  
  class func removeTrackFromOnTheGoPlaylist(track: Track)
  {
    var tracks = onTheGoPlaylist.tracks

    if let index = tracks.indexOf({ $0 == track }) {
      tracks.removeAtIndex(index)
      saveTracks(tracks, forKey: onTheGoPlaylistKey)
    }
  }
  
  private(set) static var onTheGoPlaylist: Playlist {
    get { return Playlist(name: kOnTheGoPlaylistName, tracks: getTracksForKey(onTheGoPlaylistKey)) }
    set { saveTracks(newValue.tracks, forKey: onTheGoPlaylistKey) }
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
