//
//  StreamTableViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/11/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

let kStreamCellIdentifier = "streamCell"

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
  }
}

// MARK: - Stream Cell Delegate
extension StreamTableViewController: StreamCellDelegate {
  func streamCell(streamCell: StreamCell, beganPlayingTrack track: Track)
  {
    let index = tracks.indexOf(track)!
    if index < tracks.count {
      let playlistTracks = Array(tracks[index + 1 ..< tracks.count])
      print(track)
      playlistTracks.map { print($0) }
      AudioPlayer.sharedPlayer.addTracksToPlaylist(playlistTracks, clearExisting: true)
    } else {
      // TODO: handle end of stream
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
