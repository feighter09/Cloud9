//
//  ParsePlaylist.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/4/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit
import Parse

class ParsePlaylist: PFObject {
  @NSManaged var name: String!
//  @NSManaged var id: NSInteger
  @NSManaged var tracks: [PFObject]!
  @NSManaged var contributors: [PFUser]!
  var trackCount: Int! { return tracks.count }
  
  // Necessary to avoid crash
  override init()
  {
    super.init()
  }
  
  init(name: String, contributors: [PFUser] = [PFUser.currentUser()!])
  {
    super.init(className: ParsePlaylist.parseClassName())

    self.name = name
    self.contributors = contributors
    self.tracks = []
  }
}

extension ParsePlaylist: PFSubclassing {
  static func parseClassName() -> String { return "Playlist" }
}
