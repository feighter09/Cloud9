//
//  VotesViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/28/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

let kVotesViewControllerNib = "VotesViewController"
let kVotesCellIdentifier = "voteCell"

enum VoteType {
  case Up, Down
}

class VotesViewController: UIViewController {
  var voteType: VoteType! {
    didSet {
      loadVotes()
      navigationItem.title = (voteType == .Up ? "Upvoted Tracks" : "Downvoted Tracks")
    }
  }
  
  class func instanceFromNib() -> VotesViewController
  {
    return VotesViewController(nibName: kVotesViewControllerNib, bundle: nil)
  }
  
  private var votes: [Track]! {
    didSet { tableView?.reloadData() }
  }
  
  @IBOutlet private weak var tableView: UITableView!
}

// MARK: - View Life Cycle
extension VotesViewController {
  override func viewDidLoad()
  {
    super.viewDidLoad()

    navigationItem.rightBarButtonItem = editButtonItem()
    setupTableView()
  }
  
  private func setupTableView()
  {
    tableView.registerClass(VoteCell.self, forCellReuseIdentifier: kVotesCellIdentifier)
    tableView.tableFooterView = UIView(frame: CGRectZero)
    
    tableView.dataSource = self
  }
  
  override func setEditing(editing: Bool, animated: Bool)
  {
    super.setEditing(editing, animated: animated)
    tableView.setEditing(editing, animated: animated)
  }
}

// MARK: - Table view data source
extension VotesViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return votes.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
  {
    let voteCell = tableView.dequeueReusableCellWithIdentifier(kVotesCellIdentifier, forIndexPath: indexPath) as! VoteCell
    voteCell.track = votes[indexPath.row]
    
    return voteCell
  }
  
  func tableView(tableView: UITableView,
                          commitEditingStyle editingStyle: UITableViewCellEditingStyle,
                          forRowAtIndexPath indexPath: NSIndexPath)
  {
    if editingStyle == .Delete {
      removeItemAtIndexPath(indexPath)
    }
  }
}

// MARK: - Helpers
extension VotesViewController {
  private func loadVotes()
  {
    votes = (voteType == .Up ? UserPreferences.upvotes : UserPreferences.downvotes)
  }
  
  private func removeItemAtIndexPath(indexPath: NSIndexPath)
  {
    tableView.beginUpdates()
    
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
    let removeFunc = (voteType == .Up ? UserPreferences.removeUpvote : UserPreferences.removeDownvote)
    removeFunc(votes[indexPath.row])
    loadVotes()
    
    tableView.endUpdates()
  }
}
