//
//  SCAPI.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/10/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import SwiftyJSON
import Parse
import PromiseKit

typealias NetworkCallback = (response: NSURLResponse!, responseData: NSData!, error: NSError!) -> Void

typealias SuccessCallback = (success: Bool, error: NSError?) -> Void
typealias FetchTracksCallback = (tracks: [Track]!, error: NSError!) -> Void
typealias FetchPlaylistsCallback = (playlists: [Playlist]!, error: NSError!) -> Void

class SoundCloud: NSObject {
  private static var nextStreamUrl: String?
  private static var authCallback: SuccessCallback?

  private static var searchInProgress: SCRequest?
}

// MARK: - Auth / Users
extension SoundCloud {
  static var userIsAuthenticated: Bool { return SCSoundCloud.account() != nil && PFUser.currentUser() != nil }
  
  class func authenticateUser(callback: SuccessCallback)
  {
    if userIsAuthenticated {
      callback(success: true, error: nil)
      return
    }
    
    authCallback = callback
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "didAuthenticate", name: kSoundCloudDidAuthenticate, object: nil)
    
    SCSoundCloud.requestAccessWithPreparedAuthorizationURLHandler { (url) -> Void in
      UIApplication.sharedApplication().openURL(url)
    }
  }
  
  class func didAuthenticate()
  {
    NSNotificationCenter.defaultCenter().removeObserver(self)

    // HACK: I need SCSoundCloud.account, which is just a wrapper for NXOAuth accounts, which are set async.
    // I can't observe NXOAuth actually saving the SoundCloud credentials, so I just delay the code a second
    delay(delay: 1, block: { () -> Void in
      if PFUser.currentUser() != nil {
        authCallback!(success: true, error: nil)
      } else {
        GET(kSCSoundCloudAPIURL + "me", params: nil) { (response, responseData, error) -> Void in
          if requestSucceeded(response, error: error) {
            let json = JSON(data: responseData)
            let username = json["username"].stringValue
            let fullName = json["full_name"].stringValue
            signUpOrLoginOnParse(fullName, username: username, password: "password")
          }
          else {
            authCallback!(success: false, error: error)
          }
        }
      }
    })
  }
  
  class func getUsersMatchingText(text: String, callback: (users: [PFUser]!, error: NSError!) -> Void)
  {
    if text == "" {
      callback(users: [], error: nil)
      return
    }
    
    let usernameQuery = PFUser.query()!, fullnameQuery = PFUser.query()!
    usernameQuery.whereKey("username", matchesRegex: text, modifiers: "i")
    fullnameQuery.whereKey("fullname", matchesRegex: text, modifiers: "i")
    PFQuery.orQueryWithSubqueries([usernameQuery, fullnameQuery]).findObjectsInBackgroundWithBlock { (objects, error) -> Void in
      callback(users: objects as! [PFUser], error: error)
    }
  }
  
  private class func signUpOrLoginOnParse(fullname: String, username: String, password: String)
  {
    //    PFUser.promiseSignUp(username, password: password).then({ success -> PFUser in
    //
    //      return PFUser.currentUser()!
    //    }).recover({ error -> Promise<PFUser> in
    //      return PFUser.promiseLogIn(username, password: password)
    //    })
    
    // I wish I could get promiseKit to improve this
    let user = PFUser()
    user["fullname"] = fullname
    user.username = username
    user.password = password
    user.signUpInBackgroundWithBlock { (success, error) -> Void in
      if success {
        authCallback!(success: true, error: nil)
      } else {
        PFUser.logInWithUsernameInBackground(username, password: password) { (user, error) -> Void in
          authCallback!(success: user != nil, error: error)
        }
      }
    }
  }
}

// MARK: - Tracks / Stream
extension SoundCloud {
  class func getStream(callback: FetchTracksCallback)
  {
    getStreamWithURLString(kSCSoundCloudAPIURL + "me/activities/tracks/affiliated", callback: callback)
  }
  
  class func getMoreStream(callback: FetchTracksCallback)
  {
    getStreamWithURLString(nextStreamUrl!, callback: callback)
  }
  
  class func getTracksMatching(searchString: String, callback: FetchTracksCallback)
  {
    if searchInProgress != nil { SCRequest.cancelRequest(searchInProgress!) }
    
    let params = ["q": searchString]
    GET(kSCSoundCloudAPIURL + "tracks", params: params) { (response, responseData, error) -> Void in
      if requestSucceeded(response, error: error) {
        let tracks = parseSearchJSON(responseData)
        callback(tracks: tracks, error: nil)
      } else {
        callback(tracks: nil, error: error)
      }
    }
  }
}

// MARK: - Playlists
extension SoundCloud {
  class func getMyPlaylists(callback: FetchPlaylistsCallback)
  {
    let urlString = kSCSoundCloudAPIURL + "me/playlists"
    GET(urlString, params: nil) { (response, responseData, error) -> Void in
      if requestSucceeded(response, error: error) {
        let playlists = parsePlaylistJSON(responseData)
        callback(playlists: playlists, error: nil)
      } else {
        NSLog("response: \(response)")
        callback(playlists: [], error: error)
      }
    }
  }
  
  class func getSharedPlaylists(callback: FetchPlaylistsCallback)
  {
    let query = ParsePlaylist.query()!
    query.whereKey("contributors", equalTo: PFUser.currentUser()!)
    query.includeKey("tracks")
    query.includeKey("contributors")
    query.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
      var playlists: [Playlist]!
      if error == nil {
        let parsePlaylists = results as! [ParsePlaylist]
        playlists = parsePlaylists.map { Playlist(parsePlaylist: $0) }
      }
      
      callback(playlists: playlists, error: error)
    })
  }
  
  class func createPlaylistWithName(name: String, type: PlaylistType, callback: SuccessCallback)
  {
    switch type {
      case .Normal:
        // TODO:
        break
      case .Shared:
        ParsePlaylist(name: name).saveInBackgroundWithBlock(callback)
    }
  }
  
  class func addTrack(track: Track, toPlaylist playlist: Playlist, callback: SuccessCallback)
  {
    switch playlist.type {
    case .Normal:
      // TODO: Add to SC playlist
      break
    case .Shared:
      addTrackToSharedPlaylist(track, toPlaylist: playlist, callback: callback)
    }
  }
  
  private class func addTrackToSharedPlaylist(track: Track, toPlaylist playlist: Playlist, callback: SuccessCallback)
  {
    playlist.parsePlaylist { (playlist) -> Void in
      if playlist != nil {
        playlist.tracks.append(track.serializeToParseObject())
        playlist.saveInBackgroundWithBlock(callback)
      } else {
        callback(success: false, error: nil)
      }
    }
  }
}

// MARK: - Helpers
extension SoundCloud {
  private class func getStreamWithURLString(urlString: String, callback: FetchTracksCallback)
  {
    let params = ["limit": "30"]
    GET(urlString, params: params) { (response, responseData, error) -> Void in
      if requestSucceeded(response, error: error) {
        let tracks = parseStreamJSON(responseData)
        callback(tracks: tracks, error: nil)
      } else {
        callback(tracks: nil, error: error)
      }
    }
  }
  
  private class func GET(urlString: String, params: [NSObject: AnyObject]!, callback: NetworkCallback) -> SCRequest
  {
    return SCRequest.performMethod(SCRequestMethodGET,
                                   onResource: NSURL(string: urlString),
                                   usingParameters: params,
                                   withAccount: SCSoundCloud.account(),
                                   sendingProgressHandler: nil,
                                   responseHandler: callback)
  }
  
  private class func requestSucceeded(response: NSURLResponse!, error: NSError?) -> Bool
  {
    if let httpResponse = response as? NSHTTPURLResponse {
      return httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
    }
    
    return error == nil
  }
  
  private class func userExists(error: NSError!) -> Bool
  {
    // TODO: fill this in with error code
    return error != nil
  }
  
  private class func parseStreamJSON(data: NSData) -> [Track]
  {
    let json = JSON(data: data)
//    print("stream json: \(json)")
    nextStreamUrl = json["next_href"].string
    
    let tracks = json["collection"].array!.filter { !$0["type"].stringValue.hasPrefix("playlist") }  // remove playlist types for now
                                          .filter { Track.isStreamable($0) }
                                          .map { Track(json: $0) }
                                          // this is fucked up. .contains doesn't by default call "==" on all the elements
                                          .filter { track in !UserPreferences.downvotes.contains { track == $0 } }
                                          .uniqueElements()
    return tracks
  }
  
  private class func parseSearchJSON(data: NSData) -> [Track]
  {
    let json = JSON(data: data)
//    print("search json: \(json)")
    return json.array!.map { Track(json: $0) }
  }
  
  private class func parsePlaylistJSON(data: NSData) -> [Playlist]
  {
    let json = JSON(data: data)
//    print("playlists: \(json)")
    return json.array!.map { Playlist(json: $0) }
  }  
}
