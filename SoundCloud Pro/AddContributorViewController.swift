//
//  AddContributorViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/4/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit
import Parse

let kAddContributorCellIdentifier = "addContributorCell"

class AddContributorViewController: UIViewController {
  var playlist: Playlist
  
  private var searchBar: UISearchBar!
  private var tableView: UITableView!
  private var tableViewDataSource: LFTableViewDataSource!
  
  init(playlist: Playlist)
  {
    self.playlist = playlist
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - View Life Cycle
extension AddContributorViewController {
  override func viewDidLoad()
  {
    super.viewDidLoad()

    initSearchBar()
    initTable()
  }
  
  private func initSearchBar()
  {
    let searchFrame = CGRect(x: 0, y: 64, width: CGRectGetWidth(view.bounds), height: 44)
    searchBar = UISearchBar(frame: searchFrame)
    view.addSubview(searchBar)
    
    searchBar.delegate = self
  }
  
  private func initTable()
  {
    let yOffset = CGRectGetMaxY(searchBar.frame)
    let height = UIView.rectWithinBars().height - searchBar.bounds.height
    let tableRect = CGRect(x: 0, y: yOffset, width: view.bounds.width, height: height)
    tableView = UITableView(frame: tableRect)
    view.addSubview(tableView)
    
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kAddContributorCellIdentifier)
    tableViewDataSource = LFTableViewDataSource(defaultCellIdentifier: kAddContributorCellIdentifier, constructCellBlock: { (cell, data) -> Void in
      let user = data as! PFUser
      cell.textLabel?.text = user.username
    })
    tableView.dataSource = tableViewDataSource
    tableView.delegate = self
  }
}

// MARK: - Search Bar Delegate
extension AddContributorViewController: UISearchBarDelegate {
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
  {
    SoundCloud.getUsersMatchingText(searchText) { (users, error) -> Void in
      if error == nil {
        self.tableViewDataSource.dataItems = users
        self.tableView.reloadData()
      }
      else {
        ErrorHandler.handleNetworkingError("finding users", error: error)
      }
    }
  }
}

// MARK: - Table View Delegate
extension AddContributorViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
  {
    let contributor = tableViewDataSource.dataItems[indexPath.row] as! PFUser
    playlist.addContributor(contributor)
  }
}