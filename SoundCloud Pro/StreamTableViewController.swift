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
extension StreamTableViewController: StreamCellDelegate {
  func streamCell(streamCell: StreamCell, beganPlayingTrack track: Track)
  {
    addStreamToPlaylistBeginningWithTrack(track)
  }
  
  private func addStreamToPlaylistBeginningWithTrack(track: Track)
  {
    if track == AudioPlayer.sharedPlayer.playlist.first { return }
    
    let index = tracks.indexOf(track)!
    if index < tracks.count {
      let playlistTracks = Array(tracks[index + 1 ..< tracks.count])
      playlistTracks.map { print($0) }
      AudioPlayer.sharedPlayer.addTracksToPlaylist(playlistTracks, clearExisting: true)
    } else {
      // TODO: handle end of stream
    }
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
    cell.delegate = self

    return cell
  }
}


// MARK: - Table View Delegate
extension StreamTableViewController {
}
