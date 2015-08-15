//
//  Listener.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/12/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

@objc protocol Listener: NSObjectProtocol {
  var listenerId: Int { get set }
}

func ==(lhs: Listener, rhs: Listener) -> Bool
{
  return lhs.listenerId == rhs.listenerId
}

class ListenerArray<ListenerType: Listener> {
  var listeners: [ListenerType] = []

  private var listenerIdsInUse = Set<Int>()
}

// MARK: - Interface
extension ListenerArray {
  func addListener(listener: ListenerType)
  {
    if !listeners.contains({ return $0 == listener }) {
      setListenerUniqueId(listener)
      unowned let _listener = listener
      listeners.append(_listener)
    }
  }
  
  func removeListener(listener: ListenerType)
  {
    if let index = listeners.indexOf({ return $0 == listener }) {
      listeners.removeAtIndex(index)
      listenerIdsInUse.remove(listener.listenerId)
    }
  }
  
  func announce(announcement: (ListenerType) -> Void)
  {
    listeners.map { announcement($0) }
  }
  
  func announceOnMainQueue(announcement: (ListenerType) -> Void)
  {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      listeners.map { listener in announcement(listener) }
    })
  }
}

// MARK: - Helpers
extension ListenerArray {
  private func setListenerUniqueId(listener: Listener)
  {
    while true {
      listener.listenerId = Int(arc4random() % UInt32(INT32_MAX))
      
      if !listenerIdsInUse.contains(listener.listenerId) {
        listenerIdsInUse.insert(listener.listenerId)
        break
      }
    }
  }
}