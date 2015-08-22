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

@objc protocol TracksTableViewControllerDelegate: NSObjectProtocol {
  optional func tracksTableControllerDidTriggerRefresh(tracksTableController: TracksTableViewController)
  optional func tracksTableControllerDidScrollToEnd(tracksTableController: TracksTableViewController)
  optional func tracksTableController(tracksTableController: TracksTableViewController, didDeleteTrack track: Track)
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

  // Options
  var tracksPlayOnSelect = true
  var pullToRefreshEnabled = false
  var infiniteScrollingEnabled = false
  var swipeToDeleteEnabled = false
  var showLoadingCell = false {
    didSet { tableView.reloadData() }
  }
  
  weak var delegate: TracksTableViewControllerDelegate?
  
  // Internals
  
  var listenerId = 0
  
  private var pullToRefresh: BOZPongRefreshControl?
  private var trackToAddToPlaylist: Track?
  
  deinit
  {
    UserPreferences.listeners.removeListener(self)
  }
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
}

// MARK: - Life Cycle
extension TracksTableViewController {
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    initTable()
    UserPreferences.listeners.addListener(self)
  }
  
  private func initTable()
  {
    tableView.registerNib(StreamCell.nib, forCellReuseIdentifier: kStreamCellIdentifier)
    tableView.registerNib(LoadingCell.nib, forCellReuseIdentifier: kLoadingCellIdentifier)
    tableView.delegate = self
    
    setupTableViewAppearance()
    setupPullToRefreshAndInfiniteScrollingIfNecessary()
  }
  
  private func setupTableViewAppearance()
  {
    tableView.estimatedRowHeight = 97
    tableView.rowHeight = UITableViewAutomaticDimension

    tableView.separatorInset = UIEdgeInsetsZero

    tableView.tableFooterView = UIView(frame: CGRectZero)
  }
  
  private func setupPullToRefreshAndInfiniteScrollingIfNecessary()
  {
    if pullToRefreshEnabled {
      pullToRefresh = BOZPongRefreshControl.attachToScrollView(tableView,
                                                               withRefreshTarget: self,
                                                               andRefreshAction: "refreshTracks")
      pullToRefresh!.backgroundColor = .secondaryColor
    }
    
    if infiniteScrollingEnabled {
      tableView.addInfiniteScrollingWithActionHandler { () -> Void in
        delegate?.tracksTableControllerDidScrollToEnd?(self)
      }
      
      let activityIndicator = tableView.infiniteScrollingView.valueForKey("activityIndicatorView") as! UIActivityIndicatorView
      activityIndicator.color = .secondaryColor
    }
  }
  
  func refreshTracks()
  {
    delegate?.tracksTableControllerDidTriggerRefresh?(self)
  }
}

// MARK: - User Preferences Listener
extension TracksTableViewController: UserPreferencesListener {
  func downvoteStatusChangedForTrack(track: Track, downvoted: Bool)
  {
    if tracks.contains(track) { removeTrack(track) }
  }
}

// MARK: - Stream Cell Delegate
extension TracksTableViewController: StreamCellDelegate {
  func streamCell(streamCell: StreamCell, didTapAddToPlaylist track: Track)
  {
    showAddToPlaylistWithTrack(track)
  }
  
  func streamCell(streamCell: StreamCell, didTapMoreWithTrack track: Track)
  {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "Add to playlist", style: .Default, handler: { (action) -> Void in
      self.showAddToPlaylistWithTrack(track)
    }))
    alert.addAction(UIAlertAction(title: "Save locally (coming soon)", style: .Default, handler: nil))
    alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: nil))
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  private func showAddToPlaylistWithTrack(track: Track)
  {
    let playlistPicker = PlaylistPickerViewController()
    playlistPicker.track = track
    playlistPicker.delegate = self
    
    navigationController!.presentViewController(UINavigationController(rootViewController: playlistPicker), animated: true, completion: nil)
  }
}

// MARK: - Playlist Picker Delegate
extension TracksTableViewController: PlaylistPickerDelegate {
  func playlistPickerDidTapDone(playlistPicker: PlaylistPickerViewController)
  {
    dismissPlaylistPicker()
  }
  
  func playlistPickerDidTapCancel(playlistPicker: PlaylistPickerViewController)
  {
    dismissPlaylistPicker()
  }
  
  private func dismissPlaylistPicker()
  {
    navigationController!.dismissViewControllerAnimated(true, completion: nil)
  }
}

// MARK: - Table View Data Source
extension TracksTableViewController {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return tracks.count + (showLoadingCell ? 1 : 0)
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
  {
    if showLoadingCellForIndexPath(indexPath) {
      let cell = tableView.dequeueReusableCellWithIdentifier(kLoadingCellIdentifier, forIndexPath: indexPath) as! LoadingCell
      cell.animate()
      return cell
    }
    
    let cell = tableView.dequeueReusableCellWithIdentifier(kStreamCellIdentifier, forIndexPath: indexPath) as! StreamCell
    let trackIndex = showLoadingCell ? indexPath.row - 1 : indexPath.row
    
    cell.track = tracks[trackIndex]
    cell.playsOnSelection = tracksPlayOnSelect
    cell.delegate = self
    
    return cell
  }
  
  override func tableView(tableView: UITableView,
    commitEditingStyle editingStyle: UITableViewCellEditingStyle,
    forRowAtIndexPath indexPath: NSIndexPath)
  {
    if editingStyle == .Delete {
      let track = tracks[indexPath.row]
      removeTrack(track)
    }
  }
  
  override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
  {
    return tableView.editing || swipeToDeleteEnabled ? .Delete : .None
  }
}

// MARK: - Table View Delegate
extension TracksTableViewController {
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
  {
    addStreamToPlaylistAfterTrackWithIndex(indexPath.row)
  }
  
  private func addStreamToPlaylistAfterTrackWithIndex(index: Int)
  {
    if index + 1 >= tracks.count { return }
    
    let start = index + 1
    let tracksToAdd = Array(tracks[start ..< tracks.count])

    AudioPlayer.sharedPlayer.addTracksToPlaylist(tracksToAdd, clearExisting: true)
    // TODO: Handle end of stream
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

// MARK: - Helpers
extension TracksTableViewController {
  private func removeTrack(track: Track)
  {
    tableView.beginUpdates()
    
    let indexPath = NSIndexPath(forRow: tracks.indexOf(track)!, inSection: 0)
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
    tracks.removeAtIndex(indexPath.row)   // mix between track / index of is bleh, there for deleting duplicates, 
                                          // don't wanna delete both
    tableView.endUpdates()
    
    delegate?.tracksTableController?(self, didDeleteTrack: track)
  }
  
  private func showLoadingCellForIndexPath(indexPath: NSIndexPath) -> Bool
  {
    return showLoadingCell && indexPath.row == 0
  }
}