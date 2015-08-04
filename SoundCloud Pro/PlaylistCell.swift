//
//  PlaylistCell.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/29/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

let kPlaylistCellIdentifier = "playlistCell"

class PlaylistCell: UITableViewCell {
  var playlist: Playlist! {
    didSet {
      textLabel?.text = playlist.name
      detailTextLabel?.text = "\(playlist.trackCount)"
    }
  }
  
  class var nib: UINib { return UINib(nibName: "PlaylistCell", bundle: nil) }
}