//
//  TracksTableViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/11/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit
import Bond

let kStreamCellIdentifier = "streamCell"
let kStreamPlaylistMinimum = 1

protocol TracksTableViewControllerDelegate: NSObjectProtocol {
  func tracksTableControllerDidTriggerRefresh(streamTableController: TracksTableViewController)
  func tracksTableControllerDidScrollToEnd(streamTableController: TracksTableViewController)
}

class TracksTableViewController: UITableViewController {
  /// The tracks shown. Automatically updates tableView if set with `=`
  var tracks: [Track] = [] {
    didSet {
      tableView.reloadData()
      pullToRefresh?.finishedLoading()
      tableView.infiniteScrollingView?.stopAnimating()
    }
  }

  var tracksPlayOnSelect = true
  var pullToRefreshEnabled = false
  var infiniteScrollingEnabled = false
  
  weak var delegate: TracksTableViewControllerDelegate?
  
  var listenerId = 0
  
  private var pullToRefresh: BOZPongRefreshControl?
  private var trackToAddToPlaylist: Track?
}

// MARK: - Interface
extension TracksTableViewController {
  func addToView(view: UIView,
    inViewController viewController: UIViewController,
    withDelegate delegate: TracksTableViewControllerDelegate?)
  {
    self.delegate = delegate
    
    view.addSubview(tableView)
    viewController.addChildViewController(self)
    didMoveToParentViewController(viewController)
  }
  
  func beginLoading()
  {
    pullToRefresh?.beginLoading()
    tableView.setContentOffset(CGPoint(x: 0, y: -65), animated: true)
  }
  
  func finishedLoading()
  {
    pullToRefresh?.finishedLoading()
    tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
  }
}

// MARK: - Life Cycle
extension TracksTableViewController {
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

    if pullToRefreshEnabled {
      pullToRefresh = BOZPongRefreshControl.attachToScrollView(tableView, withRefreshTarget: self, andRefreshAction: "refreshTracks")
      pullToRefresh!.backgroundColor = .orangeColor()
    }
    
    if infiniteScrollingEnabled {
      tableView.addInfiniteScrollingWithActionHandler { () -> Void in
        delegate?.tracksTableControllerDidScrollToEnd(self)
      }
    }
  }
  
  func refreshTracks()
  {
    delegate?.tracksTableControllerDidTriggerRefresh(self)
  }
}

// MARK: - Audio Playback Delegate
extension TracksTableViewController: AudioPlayerListener {
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
    if let tracksToAdd = tracksFollowingTrack(track) {
      if tracksToAdd.first != AudioPlayer.sharedPlayer.playlist.first || AudioPlayer.sharedPlayer.playlist.count == 0 {
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

// MARK: - Stream Cell Delegate
extension TracksTableViewController: StreamCellDelegate {
  func streamCell(streamCell: StreamCell, didDownvoteTrack track: Track)
  {
    tableView.beginUpdates()
    
    let indexPath = NSIndexPath(forRow: tracks.indexOf(track)!, inSection: 0)
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
    tracks = tracks.filter { $0 != track }
    
    tableView.endUpdates()
  }
  
  func streamCell(streamCell: StreamCell, didTapAddToPlaylist track: Track)
  {
    let playlistPicker = PlaylistPickerViewController()
    trackToAddToPlaylist = track
    playlistPicker.delegate = self
    
    let presentingController: UIViewController = navigationController ?? self
    presentingController.presentViewController(UINavigationController(rootViewController: playlistPicker), animated: true, completion: nil)
  }
}

// MARK: - Stream Cell Delegate
extension TracksTableViewController: PlaylistPickerDelegate {
  func playlistPicker(playlistPicker: PlaylistPickerViewController, didSelectPlaylist playlist: Playlist)
  {
    playlist.addTrack(trackToAddToPlaylist!)
    dismissPlaylistPicker()
  }
  
  func playlistPickerDidTapCancel(playlistPicker: PlaylistPickerViewController)
  {
    dismissPlaylistPicker()
  }
  
  private func dismissPlaylistPicker()
  {
    let presentingController: UIViewController = navigationController ?? self
    presentingController.dismissViewControllerAnimated(true, completion: nil)
  }
}

// MARK: - Table View Data Source
extension TracksTableViewController {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return tracks.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCellWithIdentifier(kStreamCellIdentifier, forIndexPath: indexPath) as! StreamCell
    
    cell.track = tracks[indexPath.row]
    cell.playsOnSelection = tracksPlayOnSelect
    cell.delegate = self
    
    return cell
  }
}

// MARK: - Scroll Delegate for Pong Refresh
extension TracksTableViewController {
  override func scrollViewDidScroll(scrollView: UIScrollView)
  {
    pullToRefresh?.scrollViewDidScroll()
  }
  
  override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
  {
    pullToRefresh?.scrollViewDidEndDragging()
  }
}