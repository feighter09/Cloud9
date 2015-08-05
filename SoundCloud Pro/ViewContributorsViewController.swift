//
//  ViewContributorsViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/4/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit
import Parse

let kViewContributorsCellIdentifier = "contributorCell"

class ViewContributorsViewController: UITableViewController {
  var playlist: Playlist
  private var contributors: [PFUser]!
  
  init(playlist: Playlist)
  {
    self.playlist = playlist
    self.contributors = playlist.contributors
    
    super.init(style: .Plain)
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - View Life Cycle
extension ViewContributorsViewController {
  override func viewDidLoad()
  {
    super.viewDidLoad()
    initTable()
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addContributor")
  }
  
  private func initTable()
  {
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kViewContributorsCellIdentifier)
  }
  
  func addContributor()
  {
    // TODO: show add contributor
  }
}

// MARK: - Table view data source
extension ViewContributorsViewController {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return contributors.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCellWithIdentifier(kViewContributorsCellIdentifier, forIndexPath: indexPath)
    cell.textLabel?.text = contributors[indexPath.row].username
    
    return cell
  }
}
