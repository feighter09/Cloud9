//
//  AllPlaylistsViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/29/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

let kLoadingCellIdentifier = "loadingCell"
let kNoPlaylistsCellIdentifier = "noPlaylists"

enum PlaylistMode: Int {
  case ContributingPlaylists = 0
  case FollowingPlaylists
  case PersonalPlaylists
}

class AllPlaylistsViewController: LogoImageViewController {
//  var sharedPlaylists: [Playlist]! {
//    didSet { tableView.reloadData() }
//  }
//  var myPlaylists: [Playlist]! {
//    didSet { tableView.reloadData() }
//  }

  var playlists: [Playlist]! {
    didSet { tableView.reloadData() }
  }

  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var segmentedControl: UISegmentedControl!
}

// MARK: - View Life Cycle
extension AllPlaylistsViewController {
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    setupTable()
    setColors()
    loadPlaylists()
  }
  
  private func setColors()
  {
    view.backgroundColor = .backgroundColor
    
  }
  
  func loadPlaylists()
  {
    playlists = nil
    
    let currentPlaylistMode = PlaylistMode(rawValue: segmentedControl.selectedSegmentIndex)!
    SoundCloud.getPlaylistsOfMode(currentPlaylistMode) { (playlists, error) -> Void in
      if error == nil {
        self.playlists = playlists
      }
      else {
        ErrorHandler.handleNetworkingError("fetching playlists", error: error)
      }
    }
//    myPlaylists = nil
//    sharedPlaylists = nil
//    
//    loadSharedPlaylists()
//    loadMyPlaylists()
  }

  private func setupTable()
  {
    tableView.registerNib(LoadingCell.nib, forCellReuseIdentifier: kLoadingCellIdentifier)
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kNoPlaylistsCellIdentifier)

    tableView.dataSource = self
    tableView.delegate = self
    
    tableView.backgroundColor = .backgroundColor
  }
}

// MARK: - Table View Data Source
extension AllPlaylistsViewController: UITableViewDataSource {
//  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
//  {
//    switch section {
//      case kLocalPlaylistSection: return "Offline Playlists"
//      case kSharedPlaylistSection: return "Shared Playlists"
//      case kMyPlaylistSection: return "My Playlists"
//      default: return nil
//    }
//  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    if playlists == nil || playlists.count == 0 {
      return 1
    }

    return playlists.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
  {
    var cell: UITableViewCell
    
    if playlists == nil {
      let loadingCell = tableView.dequeueReusableCellWithIdentifier(kLoadingCellIdentifier, forIndexPath: indexPath) as! LoadingCell
      loadingCell.animate()
      cell = loadingCell
    }
    else if playlists.count == 0 {
      let normalCell = tableView.dequeueReusableCellWithIdentifier(kNoPlaylistsCellIdentifier, forIndexPath: indexPath)
      normalCell.textLabel?.text = "No playlists!"
      normalCell.textLabel?.textColor = .primaryColor
      cell = normalCell
    }
    else {
      let playlistCell = tableView.dequeueReusableCellWithIdentifier(kPlaylistCellIdentifier, forIndexPath: indexPath) as! PlaylistCell
      playlistCell.playlist = playlists[indexPath.row]
      cell = playlistCell
    }
    
    cell.backgroundColor = .backgroundColor
    cell.tintColor = .primaryColor
    
    return cell
  }
}

// MARK: - UI Actions
extension AllPlaylistsViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
  {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    if playlists != nil {
      presentPlaylist(playlists[indexPath.row])
    }
  }
  
  @IBAction func addPlaylistTapped(sender: AnyObject)
  {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "New Shared Playlist", style: .Default, handler: { (action) -> Void in
      self.showAddPlaylistAlert(.Shared)
    }))
//    alert.addAction(UIAlertAction(title: "New Playlist", style: .Default, handler: { (action) -> Void in
//      self.showAddPlaylistAlert(.Normal)
//    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: nil))
    presentViewController(alert, animated: true, completion: nil)
  }
  
  @IBAction func refreshTapped(sender: AnyObject)
  {
    loadPlaylists()
  }
  
  @IBAction func playlistTypeChanged(sender: AnyObject)
  {
    loadPlaylists()
  }
  
  private func presentPlaylist(playlist: Playlist)
  {
    let playlistVC = PlaylistViewController(playlist: playlist)
    navigationController?.pushViewController(playlistVC, animated: true)
  }
}

// MARK: - Helpers
extension AllPlaylistsViewController {
  private func showAddPlaylistAlert(playlistType: PlaylistType)
  {
    let alert = UIAlertController(title: "New \(playlistType.rawValue) Playlist", message: nil, preferredStyle: .Alert)
    alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
      textField.placeholder = "name"
    }
    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { [unowned alert] (action) -> Void in
      let name = alert.textFields!.first!.text!
      SoundCloud.createPlaylistWithName(name, type: playlistType, callback: self.createPlaylistHandler)
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: nil))
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func createPlaylistHandler(success: Bool, error: NSError?)
  {
    if error == nil {
      loadPlaylists()
    }
    else {
      ErrorHandler.handleNetworkingError("creating playlists", error: error!)
    }
  }
}
