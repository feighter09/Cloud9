//
//  LFSectionedTableViewDataSource.swift
//  ScholarsAd
//
//  Created by Austin Feight on 3/22/15.
//  Copyright (c) 2015 ScholarsAd. All rights reserved.
//

import UIKit

typealias LFSectionedConstructTableCellBlock = (UITableViewCell, AnyObject, Int) -> Void

class LFSectionedTableViewDataSource: NSObject, UITableViewDataSource {
  var sectionHeaders = [String]()
  var dataItems = [[AnyObject]]()
  
  private var defaultCellIdentifier: String
  private var cellIdentifiers = [Int: String]()
  private var constructCellBlock: LFSectionedConstructTableCellBlock
  
  init(defaultCellIdentifier: String, constructCellBlock: LFSectionedConstructTableCellBlock)
  {
    self.defaultCellIdentifier = defaultCellIdentifier
    self.constructCellBlock = constructCellBlock
  }
}

// MARK: - Interface
extension LFSectionedTableViewDataSource {
  func dataItemForIndexPath(indexPath: NSIndexPath) -> AnyObject
  {
    return dataItems[indexPath.section][indexPath.row]
  }
  
  func setCellIdentifier(identifier: String, forSection section: Int)
  {
    cellIdentifiers[section] = identifier
  }
  
  func identifierForIndexPath(indexPath: NSIndexPath) -> String!
  {
    return cellIdentifiers[indexPath.section] ?? defaultCellIdentifier
  }
}

// MARK: - Data Source Methods
extension LFSectionedTableViewDataSource {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int
  {
    return dataItems.count
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
  {
    if sectionHeaders.count > 0 && sectionHeaders[section] != "" {
      return sectionHeaders[section]
    }
    
    return nil
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return dataItems[section].count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
  {
    let identifier = identifierForIndexPath(indexPath)
    let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
    let data: AnyObject = dataItemForIndexPath(indexPath)
    
    constructCellBlock(cell, data, indexPath.section)
    
    cell.tag = indexPath.row
    return cell
  }
}
