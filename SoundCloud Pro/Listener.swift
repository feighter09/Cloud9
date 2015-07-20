//
//  Listener.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/12/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

protocol Listener: NSObjectProtocol {
  var listenerId: Int { get set }
}

func ==(lhs: Listener, rhs: Listener) -> Bool
{
  return lhs.listenerId == rhs.listenerId
}

class ListenerArray {
  var listeners: [Listener] = []

  private var listenerIdsInUse = Set<Int>()
}

// MARK: - Interface
extension ListenerArray {
  func addListener(listener: Listener)
  {
    if !listeners.contains({ return $0 == listener }) {
      setListenerUniqueId(listener)
      unowned let _listener = listener
      listeners.append(_listener)
    }
  }
  
  func removeListener(listener: Listener)
  {
    if let index = listeners.indexOf({ return $0 == listener }) {
      listeners.removeAtIndex(index)
      listenerIdsInUse.remove(listener.listenerId)
    }
  }
  
  func announce(announcement: (Listener) -> Void)
  {
    listeners.map { announcement($0) }
  }
}

// MARK: - Helpers
extension ListenerArray {
  private func setListenerUniqueId(listener: Listener)
  {
    while true {
      listener.listenerId = Int(arc4random())
      
      if !listenerIdsInUse.contains(listener.listenerId) {
        listenerIdsInUse.insert(listener.listenerId)
        break
      }
    }
  }
}