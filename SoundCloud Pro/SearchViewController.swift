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
  
  private var searchResultsController = TracksTableViewController()
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
    
    let hideKeyboardRecognizer = UITapGestureRecognizer(target: searchBar, action: "resignFirstResponder")
    hideKeyboardRecognizer.cancelsTouchesInView = false
    searchResultsController.tableView.addGestureRecognizer(hideKeyboardRecognizer)
    searchResultsController.tableView.keyboardDismissMode = .OnDrag
  }
}

// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
  {
    if searchText == "" {
      searchResultsController.tracks = []
      return
    }
    
    searchResultsController.beginLoading()
    SoundCloud.getTracksMatching(searchText) { (tracks, error) -> Void in
      self.searchResultsController.finishedLoading()
      
      if error == nil {
        self.searchResultsController.tracks = tracks
      }
      else {
        ErrorHandler.handleNetworkingError("tracks", error: error)
      }
    }
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar)
  {
    searchBar.resignFirstResponder()
  }
}

