//
//  SearchViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/29/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

let kSearchViewControllerNib = "SearchViewController"

protocol SearchViewControllerDelegate: NSObjectProtocol {
  func searchViewControllerDidTapCancel(searchViewController: SearchViewController)
}

class SearchViewController: UIViewController {
  weak var delegate: SearchViewControllerDelegate?
  
  @IBOutlet private weak var searchBar: UISearchBar!
  @IBOutlet private weak var containerView: UIView!
  
  private var searchResultsController = TracksTableViewController()
  
  class func instanceFromNib(delegate delegate: SearchViewControllerDelegate? = nil) -> UIViewController
  {
    let searchController = SearchViewController(nibName: kSearchViewControllerNib, bundle: nil)
    searchController.delegate = delegate
    return UINavigationController(rootViewController: searchController)
  }
}

// MARK: - View Life Cycle
extension SearchViewController {
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    searchBar.delegate = self
    setupSearchResults()
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
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
  
  func cancel()
  {
    delegate?.searchViewControllerDidTapCancel(self)
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

