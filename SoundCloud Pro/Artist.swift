//
//  Artist.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/23/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import SwiftyJSON

class Artist {
  let id: Int
  let name: String
  
  init(id: Int, name: String)
  {
    self.id = id
    self.name = name
  }
  
  convenience init(json: JSON)
  {
    let id = json["id"].int!
    let name = json["name"].string!

    self.init(id: id, name: name)
  }
}
