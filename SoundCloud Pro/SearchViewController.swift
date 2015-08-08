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
  func searchViewController(searchViewController: SearchViewController, didSelectTrack track: Track)
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
    
    setupSearchResults()
    searchBar.delegate = self
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
  }
  
  override func viewDidAppear(animated: Bool)
  {
    super.viewDidAppear(animated)
    searchBar.becomeFirstResponder()
  }
  
  private func setupSearchResults()
  {
    searchResultsController.tracksPlayOnSelect = false
    
    let hideKeyboardRecognizer = UITapGestureRecognizer(target: searchBar, action: "resignFirstResponder")
    hideKeyboardRecognizer.cancelsTouchesInView = false

    let resultsTableView = searchResultsController.tableView
    resultsTableView.tableFooterView = nil
    resultsTableView.addGestureRecognizer(hideKeyboardRecognizer)
    resultsTableView.keyboardDismissMode = .OnDrag
    resultsTableView.delegate = self
    
    resultsTableView.frame = containerView.bounds
    searchResultsController.addToView(containerView, inViewController: self, withDelegate: nil)
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

// MARK: - Search Bar Delegate
extension SearchViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
  {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    let selectedTrack = searchResultsController.tracks[indexPath.row]
    delegate?.searchViewController(self, didSelectTrack: selectedTrack)
  }
}