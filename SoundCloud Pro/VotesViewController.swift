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
    let dataSource = LFTableViewDataSource(defaultCellIdentifier: kVotesCellIdentifier, dataItems: votes) { (cell, data) -> Void in
      let voteCell = cell as! VoteCell
      voteCell.track = data as! Track
    }
    dataSource.deleteCellBlock = { self.removeItemAtIndexPath($0) }
    tableView.dataSource = dataSource
    
    tableView.tableFooterView = UIView(frame: CGRectZero)
  }
}

// MARK: - Table view data source
extension VotesViewController {
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
