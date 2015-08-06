//
//  LFTableViewDataSource.swift
//  ScholarsAd
//
//  Created by Austin Feight on 12/31/14.
//  Copyright (c) 2014 ScholarsAd. All rights reserved.
//

import UIKit

typealias LFConstructTableCellBlock = (UITableViewCell, AnyObject) -> Void
typealias LFDeleteTableCellBlock = (NSIndexPath) -> Void

class LFTableViewDataSource: NSObject, UITableViewDataSource {
  
  var dataItems = [AnyObject]()
  
  /** Callback when a cell is deleted from the table */
  var deleteCellBlock: LFDeleteTableCellBlock?

  private var defaultCellIdentifier: String
  private var cellIdentifiers = [NSIndexPath: String]()
  private var constructCellBlock: LFConstructTableCellBlock
  
  init(defaultCellIdentifier: String, dataItems: [AnyObject] = [], constructCellBlock: LFConstructTableCellBlock)
  {
    self.defaultCellIdentifier = defaultCellIdentifier
    self.constructCellBlock = constructCellBlock
    self.dataItems = dataItems
  }
}

// MARK: - Interface
extension LFTableViewDataSource {
  func setCellIdentifier(identifier: String, forIndexPath indexPath: NSIndexPath)
  {
    cellIdentifiers[indexPath] = identifier
  }
  
  func identifierForIndexPath(indexPath: NSIndexPath) -> String
  {
    return cellIdentifiers[indexPath] == nil ? defaultCellIdentifier : cellIdentifiers[indexPath]!
  }
  
  func dataItemForIndexPath(indexPath: NSIndexPath) -> AnyObject
  {
    return dataItems[indexPath.row]
  }
}

// MARK: - Data Source Methods
extension LFTableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return dataItems.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
  {
    let identifier = identifierForIndexPath(indexPath)
    let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
    let data: AnyObject = dataItemForIndexPath(indexPath)
    
    constructCellBlock(cell, data)
    
    cell.tag = indexPath.row
    return cell
  }
  
  func tableView(tableView: UITableView,
                 commitEditingStyle editingStyle: UITableViewCellEditingStyle,
                 forRowAtIndexPath indexPath: NSIndexPath)
  {
    if editingStyle == .Delete {
      dataItems.removeAtIndex(indexPath.row)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
      deleteCellBlock?(indexPath)
    } else if editingStyle == .Insert {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
  }
}
