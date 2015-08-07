//
//  SettingsViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/28/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit
import Parse

let kSettingsViewControllerNib = "SettingsViewController"
let kSettingsCellIdentifier = "settingsCell"

class SettingsViewController: UITableViewController {
  class func instanceFromNib() -> UIViewController
  {
    let settingsViewController = SettingsViewController(nibName: kSettingsViewControllerNib, bundle: nil)
    return UINavigationController(rootViewController: settingsViewController)
  }
  
  private var tableViewDataSource: LFSectionedTableViewDataSource!
}

// MARK: - View Life Cycle
extension SettingsViewController {
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    tableView.frame = UIView.rectWithinBars()
    view.layoutIfNeeded()
  }
}

// MARK: - Table View Delegate
extension SettingsViewController {
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
  {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    if indexPath.section == 0 {
      let voteType: VoteType = (indexPath.row == 0 ? .Up : .Down)
      showVotesViewController(voteType)
    }
    else if indexPath.section == 2 {
      logOut()
    }
  }
  
  private func showVotesViewController(voteType: VoteType)
  {
    let votesTableViewController = VotesViewController.instanceFromNib()
    votesTableViewController.voteType = voteType
    navigationController!.pushViewController(votesTableViewController, animated: true)
  }
  
  private func logOut()
  {
    SCSoundCloud.removeAccess()
    PFUser.logOutInBackgroundWithBlock({ (error) -> Void in
      if error == nil {
        self.showLogin()
      }
      else {
        ErrorHandler.handleNetworkingError("logging out - lol", error: error)
      }
    })
  }
  
  private func showLogin()
  {
    tabBarController?.selectedIndex = 0
  }
}