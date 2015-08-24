//
//  Follow.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/23/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit
import Parse

let FollowUserKey = "user"
let FollowPlaylistKey = "playlist"

class Follow: PFObject {
  @NSManaged var user: PFUser!
  @NSManaged var playlist: ParsePlaylist!
}

extension Follow: PFSubclassing {
  static func parseClassName() -> String { return "Follow" }
}
