//
//  UserPreferences.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/20/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

let kOnTheGoPlaylistName = "On The Go"
let kRecentsPlaylistName = "Recents"

@objc protocol UserPreferencesListener: Listener {
  optional func upvoteStatusChangedForTrack(track: Track, upvoted: Bool)
  optional func downvoteStatusChangedForTrack(track: Track, downvoted: Bool)
}

class UserPreferences {
  static var listeners = ListenerArray<UserPreferencesListener>()
  
  private static let settings = NSUserDefaults.standardUserDefaults()

  private static let upvoteKey = "upvotes"
  private static let downvoteKey = "downvotes"
  private static let onTheGoPlaylistKey = "onTheGoPlaylist"
  private static let recentsPlaylistKey = "recentsPlaylist"
}

// MARK: - General
extension UserPreferences {
  class func clearAllSettings()
  {
    upvotes = []
    downvotes = []

    recentsPlaylist = Playlist(name: "", tracks: [])
    onTheGoPlaylist = Playlist(name: "", tracks: [])
  }
}

// MARK: - Votes
extension UserPreferences {
  class func removeUpvote(track: Track)
  {
    removeTrack(track, fromTracksForKey: upvoteKey)
  }
  
  class func toggleUpvote(track: Track)
  {
    let addUpvote = !upvotes.contains(track)
    if addUpvote {
      addTrack(track, toTracksForKey: upvoteKey)
      removeTrack(track, fromTracksForKey: downvoteKey)
    }
    else {
      removeTrack(track, fromTracksForKey: upvoteKey)
    }
    
    // Usually a UI update for vote buttons, announce on main queue here to forget about it in multiple implementations
    listeners.announceOnMainQueue { listener in listener.upvoteStatusChangedForTrack?(track, upvoted: addUpvote) }
  }
  
  class func removeDownvote(track: Track)
  {
    removeTrack(track, fromTracksForKey: downvoteKey)
  }
  
  class func toggleDownvote(track: Track)
  {
    let addDownvote = !downvotes.contains(track)
    if addDownvote {
      addTrack(track, toTracksForKey: downvoteKey)
      removeTrack(track, fromTracksForKey: upvoteKey)
    }
    else {
      removeTrack(track, fromTracksForKey: downvoteKey)
    }
    
    listeners.announceOnMainQueue { listener in listener.downvoteStatusChangedForTrack?(track, downvoted: addDownvote) }
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
    addTrack(track, toTracksForKey: onTheGoPlaylistKey)
  }
  
  class func removeTrackFromOnTheGoPlaylist(track: Track)
  {
    removeTrack(track, fromTracksForKey: onTheGoPlaylistKey)
  }
  
  private(set) static var onTheGoPlaylist: Playlist {
    get { return Playlist(name: kOnTheGoPlaylistName, tracks: getTracksForKey(onTheGoPlaylistKey)) }
    set { saveTracks(newValue.tracks, forKey: onTheGoPlaylistKey) }
  }
}

// MARK: - Recently Played
extension UserPreferences {
  class func addTrackToRecentlyPlayed(track: Track)
  {
    addTrack(track, toTracksForKey: recentsPlaylistKey, toBeginning: true)
  }
  
  class func removeTrackFromRecentlyPlayed(track: Track)
  {
    removeTrack(track, fromTracksForKey: recentsPlaylistKey)
  }
  
  private(set) static var recentsPlaylist: Playlist {
    get { return Playlist(name: kRecentsPlaylistName, tracks: getTracksForKey(recentsPlaylistKey)) }
    set { saveTracks(newValue.tracks, forKey: recentsPlaylistKey) }
  }
}

// MARK: - Helpers
extension UserPreferences {
  private class func addTrack(track: Track, toTracksForKey key: String, toBeginning beginning: Bool = false)
  {
    var tracks = getTracksForKey(key)
    
    if beginning {
      tracks.insert(track, atIndex: 0)
    }
    else {
      tracks.append(track)
    }
    
    saveTracks(tracks, forKey: key)
  }
  
  private class func removeTrack(track: Track, fromTracksForKey key: String)
  {
    var tracks = getTracksForKey(key)
    
    if let index = tracks.indexOf({ $0 == track }) {
      tracks.removeAtIndex(index)
      saveTracks(tracks, forKey: key)
    }
  }
  
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
