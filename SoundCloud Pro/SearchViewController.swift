//
//  SearchViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/29/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
  @IBOutlet private weak var searchBar: UISearchBar!
  @IBOutlet private weak var containerView: UIView!
  
  private var searchResultsController = StreamTableViewController()
}

// MARK: - View Life Cycle
extension SearchViewController {
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    searchBar.delegate = self
    setupSearchResults()
  }
  
  private func setupSearchResults()
  {
    searchResultsController.tableView.frame = containerView.bounds
    searchResultsController.addToView(containerView, inViewController: self, withDelegate: nil)
  }
}

// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
  {
    SoundCloud.getTracksMatching(searchText) { (tracks, error) -> Void in
      if error == nil {
        self.searchResultsController.tracks = tracks
      } else {
        ErrorHandler.handleNetworkingError("tracks", error: error)
      }
    }
  }
}

