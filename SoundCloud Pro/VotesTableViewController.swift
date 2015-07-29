//
//  VotesTableViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/28/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

let kVotesStoryboardId = "votesTableViewController"
let kVotesCellIdentifier = "voteCell"

enum VoteType {
  case Up, Down
}

class VotesTableViewController: UITableViewController {
  var voteType: VoteType! {
    didSet {
      loadVotes()
      navigationItem.title = (voteType == .Up ? "Upvoted Tracks" : "Downvoted Tracks")
    }
  }
  
  private var votes: [Track]! {
    didSet { tableView.reloadData() }
  }
}

// MARK: - View Life Cycle
extension VotesTableViewController {
  override func viewDidLoad()
  {
    super.viewDidLoad()

    navigationItem.rightBarButtonItem = editButtonItem()
    tableView.tableFooterView = UIView(frame: CGRectZero)
  }
}

// MARK: - Table view data source
extension VotesTableViewController {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return votes.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCellWithIdentifier(kVotesCellIdentifier, forIndexPath: indexPath) as! VoteCell
    cell.track = votes[indexPath.row]
    
    return cell
  }
  
  // Override to support editing the table view.
  override func tableView(tableView: UITableView,
                          commitEditingStyle editingStyle: UITableViewCellEditingStyle,
                          forRowAtIndexPath indexPath: NSIndexPath)
  {
    if editingStyle == .Delete {
      removeItemAtIndexPath(indexPath)
    }
  }
}

// MARK: - Helpers
extension VotesTableViewController {
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
