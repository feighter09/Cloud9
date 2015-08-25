//
//  ArtistViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/23/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

private enum ListType: Int {
  case Tracks, Playlists, Reposts
}

class ArtistViewController: UIViewController {
  var artist: Artist!
  var collective: Collective!
  
  // Outlets
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var listControl: UISegmentedControl!
  @IBOutlet private weak var playlistsTableView: UITableView!
}

// MARK: - View Life Cycle
extension ArtistViewController {
  override func viewDidLoad()
  {
    super.viewDidLoad()
    loadList()
  }
}

// MARK: - Helpers
extension ArtistViewController {
  private func loadList()
  {
    let listType = ListType(rawValue: listControl.selectedSegmentIndex)!
    switch listType {
    case .Tracks:
      loadTracks()
    case .Playlists:
      loadPlaylists()
    case .Reposts:
      loadReposts()
    }
  }
  
  private func loadTracks()
  {
    
  }
  
  private func loadPlaylists()
  {
    
  }
  
  private func loadReposts()
  {
    
  }
}