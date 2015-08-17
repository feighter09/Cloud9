//
//  PlaylistPickerViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/4/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

protocol PlaylistPickerDelegate: NSObjectProtocol {
  func playlistPickerDidTapDone(playlistPicker: PlaylistPickerViewController)
  func playlistPickerDidTapCancel(playlistPicker: PlaylistPickerViewController)
}

class PlaylistPickerViewController: UITableViewController {
  /// Track to be added to playlists selected. Must be set before picker is presented
  var track: Track!
  var playlists: [Playlist] = [] {
    didSet { tableView.reloadData() }
  }
  
  weak var delegate: PlaylistPickerDelegate?
  
  private var selectedIndices = Set<NSIndexPath>()
}

// MARK: - View Life Cycle
extension PlaylistPickerViewController {
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    setupNavBar()

    tableView.registerNib(PlaylistCell.nib, forCellReuseIdentifier: kPlaylistCellIdentifier)
    loadPlaylists()
  }
  
  private func loadPlaylists()
  {
    let alert = Utilities.showLoadingAlert("Loading playlists", onViewController: self)
    
    SoundCloud.getSharedPlaylists({ (sharedPlaylists, error) -> Void in
      alert.hideView()
      
      if error == nil {
        self.playlists = [UserPreferences.onTheGoPlaylist] + sharedPlaylists
      } else {
        ErrorHandler.handleNetworkingError("fetching playlists", error: error)
      }
    })
  }
  
  func done()
  {
    saveOnTheGoPlaylistIfNecessary()
    
    let playlistsToAdd = selectedIndices.map { indexPath in return self.playlists[indexPath.row] }
    playlistsToAdd.map { playlist in playlist.addTrack(track) }

    delegate?.playlistPickerDidTapDone(self)
  }
  
  func cancel()
  {
    delegate?.playlistPickerDidTapCancel(self)
  }
}

// MARK: - Table view data source + Delegate
extension PlaylistPickerViewController {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return playlists.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCellWithIdentifier(kPlaylistCellIdentifier, forIndexPath: indexPath) as! PlaylistCell
    cell.playlist = playlists[indexPath.row]
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
  {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let cell = tableView.cellForRowAtIndexPath(indexPath)!
    let cellChecked = cell.accessoryType == .Checkmark
    cell.accessoryType = (cellChecked ? .None : .Checkmark)
    cell.tintColor = .secondaryColor
    
    selectedIndices.insert(indexPath)
  }
}

// MARK: - Helpers
extension PlaylistPickerViewController {
  private func setupNavBar()
  {
    navigationItem.title = "Add To Playlist"
    navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.secondaryColor]
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")
  }
  
  private func isOnTheGoPlaylistIndex(indexPath: NSIndexPath) -> Bool
  {
    return indexPath.row == 0
  }
  
  private func saveOnTheGoPlaylistIfNecessary()
  {
    if selectedIndices.contains({ indexPath in isOnTheGoPlaylistIndex(indexPath) }) {
      UserPreferences.addTrackToOnTheGoPlaylist(track)

      let selectedIndicesWithoutOnTheGo = selectedIndices.filter({ indexPath in !isOnTheGoPlaylistIndex(indexPath) })
      selectedIndices = Set<NSIndexPath>(selectedIndicesWithoutOnTheGo)
    }
  }
}
