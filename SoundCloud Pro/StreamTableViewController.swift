//
//  StreamTableViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/11/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

let kStreamCellIdentifier = "streamCell"
let kStreamPlaylistMinimum = 1

class StreamTableViewController: UITableViewController {
  var tracks: [Track] = [] {
    didSet { tableView.reloadData() }
  }
  var listenerId = 0
}

// MARK: - Life Cycle
extension StreamTableViewController {
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    initTable()
    AudioPlayer.sharedPlayer.addListener(self)
  }
  
  private func initTable()
  {
    tableView.registerNib(StreamCell.nib, forCellReuseIdentifier: kStreamCellIdentifier)
    
    tableView.estimatedRowHeight = 59
    tableView.rowHeight = UITableViewAutomaticDimension

    tableView.tableFooterView = UIView(frame: CGRectZero)
  }
}

// MARK: - Stream Cell Delegate
extension StreamTableViewController: AudioPlayerListener {
  func audioPlayer(audioPlayer: AudioPlayer, didBeginBufferingTrack track: Track)
  {
    addStreamToPlaylistAfterTrack(track)
  }
  
  func audioPlayer(audioPlayer: AudioPlayer, didBeginPlayingTrack track: Track)
  {
    addStreamToPlaylistAfterTrack(track)
  }
  
  private func addStreamToPlaylistAfterTrack(track: Track)
  {
    // TODO: this might not be very robust
    if let tracksToAdd = tracksFollowingTrack(track) {
      if tracksToAdd.first != AudioPlayer.sharedPlayer.playlist.first  {
//        tracksToAdd.map { print($0) }
        AudioPlayer.sharedPlayer.addTracksToPlaylist(tracksToAdd, clearExisting: true)
      }
    } else {
      // TODO: Handle end of stream
    }
  }
  
  private func tracksFollowingTrack(track: Track) -> [Track]?
  {
    if let index = tracks.indexOf(track) {
      if index + 1 < tracks.count { return Array(tracks[index + 1 ..< tracks.count]) }
    }
    
    return nil
  }
  
  private func shouldAddStreamToPlaylistBeginningWithTrack(track: Track) -> Bool
  {
    if AudioPlayer.sharedPlayer.currentTrack == nil { return true }
    
    let toAddIndex = tracks.indexOf(track)!
    if let currentlyPlayingIndex = tracks.indexOf(AudioPlayer.sharedPlayer.currentTrack!) {
      return toAddIndex > currentlyPlayingIndex
    } else {
      return true
    }
  }
}

// MARK: - Table View Data Source
extension StreamTableViewController {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return tracks.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCellWithIdentifier(kStreamCellIdentifier, forIndexPath: indexPath) as! StreamCell
    cell.track = tracks[indexPath.row]
    return cell
  }
}

// MARK: - Table View Delegate
extension StreamTableViewController {
}
