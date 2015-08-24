//
//  Collective.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/23/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import SwiftyJSON

class Collective {
  let id: Int
  let name: String
  let collectiveDescription: String
  let collectiveShortDescription: String

  init(id: Int, name: String, collectiveDescription: String, collectiveShortDescription: String)
  {
    self.id = id
    self.name = name
    self.collectiveDescription = collectiveDescription
    self.collectiveShortDescription = collectiveShortDescription
  }
  
  convenience init(json: JSON)
  {
    let id = json["id"].int!
    let name = json["name"].string!
    let collectiveDescription = json["description"].string!
    let collectiveShortDescription = json["short_description"].string!

    self.init(id: id,
              name: name,
              collectiveDescription: collectiveDescription,
              collectiveShortDescription: collectiveShortDescription)
  }
}
