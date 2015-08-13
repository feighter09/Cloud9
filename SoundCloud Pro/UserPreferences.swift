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

class UserPreferences {
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
  class func addUpvote(track: Track)
  {
    addTrack(track, toTracksForKey: upvoteKey)
    removeDownvote(track)
  }
  
  class func removeUpvote(track: Track)
  {
    removeTrack(track, fromTracksForKey: upvoteKey)
  }
  
  class func addDownvote(track: Track)
  {
    addTrack(track, toTracksForKey: downvoteKey)
    removeUpvote(track)
  }
  
  class func removeDownvote(track: Track)
  {
    removeTrack(track, fromTracksForKey: downvoteKey)
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
