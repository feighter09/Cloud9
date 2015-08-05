//
//  Playlist.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/29/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit
import SwiftyJSON
import Parse

enum PlaylistType: String {
  case Normal, Shared
}

class Playlist {
  var name: String
  var tracks: [Track]
  var trackCount: Int { return tracks.count }
  private(set) var contributors: [PFUser]!
  
  var type: PlaylistType { return parseId == nil ? .Normal : .Shared }
  private var parseId: String!

  init(json: JSON)
  {
    name = json["title"].string!
    tracks = json["tracks"].array!.filter { Track.isStreamable($0) }
                                  .map { Track(json: $0) }
  }
  
  init(parsePlaylist: ParsePlaylist)
  {
    name = parsePlaylist.name
    tracks = parsePlaylist.tracks.map { Track.serializeFromParseObject($0) }
    contributors = parsePlaylist.contributors
    parseId = parsePlaylist.objectId
  }
}

// MARK: - Interface
extension Playlist {
  func addContributor(contributor: PFUser, callback: SuccessCallback)
  {
    if contributors.contains({ $0.objectId == contributor.objectId }) {
      callback(success: true, error: nil)
      return
    }
    
    contributors.append(contributor)
    parsePlaylist { (playlist) -> Void in
      playlist.contributors.append(contributor)
      playlist.saveEventually(callback)
    }
  }
  
  func parsePlaylist(callback: (playlist: ParsePlaylist!) -> Void)
  {
    ParsePlaylist.query()?.getObjectInBackgroundWithId(parseId, block: { (object, error) -> Void in
      if error == nil {
        callback(playlist: object as! ParsePlaylist)
      } else {
        callback(playlist: nil)
      }
    })
  }
}

// MARK: - Equatable
extension Playlist: Equatable {
}

func ==(lhs: Playlist, rhs: Playlist) -> Bool
{
  return lhs.name == rhs.name && lhs.tracks == rhs.tracks && lhs.contributors == rhs.contributors
}