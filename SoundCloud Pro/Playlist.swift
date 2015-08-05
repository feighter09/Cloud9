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
  func addContributor(contributor: PFUser)
  {
    contributors.append(contributor)
    parsePlaylist { (playlist) -> Void in
      playlist.saveEventually(nil)
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
