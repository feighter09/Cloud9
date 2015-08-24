//
//  SearchViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/29/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

let kSearchViewControllerIdentifier = "SearchViewController"

protocol SearchViewControllerDelegate: NSObjectProtocol {
  func searchViewController(searchViewController: SearchViewController, didSelectTrack track: Track)
  func searchViewControllerDidTapCancel(searchViewController: SearchViewController)
}

class SearchViewController: LogoImageViewController {
  var shownModally = false
  weak var delegate: SearchViewControllerDelegate?
  
  @IBOutlet private weak var searchTypeControl: UISegmentedControl!
  @IBOutlet private weak var searchBar: UISearchBar!
  @IBOutlet private weak var containerView: UIView!
  
  private var searchResultsController = TracksTableViewController()
  
  private var searchesInProgress = 0
  private var hud: SCLAlertView!
  
  private static var onceToken: dispatch_once_t = 0
  
  deinit
  {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}

// MARK: - View Life Cycle
extension SearchViewController {
  class func instance(delegate delegate: SearchViewControllerDelegate?) -> UIViewController
  {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let searchController = storyboard.instantiateViewControllerWithIdentifier(kSearchViewControllerIdentifier) as! SearchViewController
    searchController.delegate = delegate
    searchController.shownModally = true
    
    return UINavigationController(rootViewController: searchController)
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    view.backgroundColor = .backgroundColor
    
    setupSearchResults()
    setupSearchBar()
    
    if shownModally {
      navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
    }
  }
  
  override func viewDidAppear(animated: Bool)
  {
    super.viewDidAppear(animated)
    searchBar.becomeFirstResponder()
  }
  
  private func setupSearchResults()
  {
//    searchResultsController.tracksPlayOnSelect = false
    
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
  
  private func setupSearchBar()
  {
    searchBar.delegate = self

    searchBar.enablesReturnKeyAutomatically = false
    searchBar.returnKeyType = .Done
    changeDoneButtonColorWhenKeyboardShows()
    
    // how you express !(#available) apparantly
    if #available(iOS 9, *){} else {
      let textField = searchBar.valueForKey("_searchField") as! UITextField
      textField.textColor = .secondaryColor
    }
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
    performSearch()
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar)
  {
    searchBar.resignFirstResponder()
  }
}

// MARK: - Search Bar Delegate
extension SearchViewController {
  @IBAction func searchTypeChanged(sender: AnyObject)
  {
    performSearch()
  }
}

// MARK: - Table View Delegate
extension SearchViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
  {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    let selectedTrack = searchResultsController.tracks[indexPath.row]
    delegate?.searchViewController(self, didSelectTrack: selectedTrack)
  }
}

// MARK: - Search Bar Delegate
extension SearchViewController {
  private func changeDoneButtonColorWhenKeyboardShows()
  {
    NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: nil) { (notification) -> Void in
      self.changeKeyboardDoneKeyColor()
    }
  }

  private func changeKeyboardDoneKeyColor()
  {
    let (keyboard, keys) = getKeyboardAndKeys()
    
    for key in keys {
      if keyIsOnBottomRightEdge(key, keyboardView: keyboard) {
        let newButton = newDoneButtonWithOld(key)
        keyboard.addSubview(newButton)
      }
    }
  }

  private func getKeyboardAndKeys() -> (keyboard: UIView, keys: [UIView])!
  {
    for keyboardWindow in UIApplication.sharedApplication().windows {
      for view in keyboardWindow.subviews {
        for keyboard in Utilities.subviewsOfView(view, withType: "UIKBKeyplaneView") {
          let keys = Utilities.subviewsOfView(keyboard, withType: "UIKBKeyView")
          return (keyboard, keys)
        }
      }
    }
    
    return nil
  }

  private func keyIsOnBottomRightEdge(key: UIView, keyboardView: UIView) -> Bool
  {
    let margin: CGFloat = 5
    let onRightEdge = key.frame.origin.x + key.frame.width + margin > keyboardView.frame.width
    let onBottom = key.frame.origin.y + key.frame.height + margin > keyboardView.frame.height
    
    return onRightEdge && onBottom
  }

  private func newDoneButtonWithOld(oldButton: UIView) -> UIButton
  {
    let oldFrame = oldButton.frame
    let newFrame = CGRect(x: oldFrame.origin.x + 2,
                          y: oldFrame.origin.y + 1,
                          width: oldFrame.size.width - 4,
                          height: oldFrame.size.height - 4)
    
    let newButton = UIButton(frame: newFrame)
    newButton.backgroundColor = .secondaryColor
    newButton.layer.cornerRadius = 4;
    newButton.setTitle("Done", forState: .Normal)
    newButton.addTarget(self.searchBar, action: "resignFirstResponder", forControlEvents: .TouchUpInside)
    
    return newButton
  }
}

// MARK: - Helpers
extension SearchViewController {
  private func performSearch()
  {
    if searchBar.text == nil || searchBar.text == "" {
      searchResultsController.tracks = []
      return
    }
    
    let searchText = searchBar.text!
    let searchType = currentSearchType()
    
    showLoadingView()
    SoundCloud.search(searchType, containing: searchText) { (tracks, error) -> Void in
      self.hideLoadingView()
      
      if error == nil {
        self.searchResultsController.tracks = tracks
      }
      else {
        ErrorHandler.handleNetworkingError("tracks", error: error)
      }
    }
  }
  
  private func currentSearchType() -> SearchType
  {
    switch searchTypeControl.selectedSegmentIndex {
    case 0:
      return .Sounds
    case 1:
      return .Artists
    case 2:
      return .Collectives
    default:
      fatalError()
    }
  }
  
  private func showLoadingView()
  {
    searchResultsController.showLoadingCell = (searchesInProgress++ == 0)
  }
  
  private func hideLoadingView()
  {
    searchResultsController.showLoadingCell = (--searchesInProgress != 0)
  }
}