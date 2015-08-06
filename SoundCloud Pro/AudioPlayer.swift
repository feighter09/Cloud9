//
//  AudioPlayer.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/11/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

enum PlayState: String {
  case Playing
  case Paused
  case Buffering
  case Stopped
  
  var image: UIImage! {
    switch self {
      case .Playing: return UIImage(named: "Pause")
      case .Paused: return UIImage(named: "Play")
      case .Buffering: fallthrough
      case .Stopped: return nil
    }
  }
}

@objc protocol AudioPlayerListener: Listener {
  optional func audioPlayer(audioPlayer: AudioPlayer, didBeginBufferingTrack track: Track)//, forTheFirstTime firstTime: Bool)
  optional func audioPlayer(audioPlayer: AudioPlayer, didBeginPlayingTrack track: Track)
  optional func audioPlayer(audioPlayer: AudioPlayer, didPauseTrack track: Track)
  optional func audioPlayer(audioPlayer: AudioPlayer, didStopTrack track: Track)
}

let kAudioPlayerDefaultSeekDelta: Double = 4
let kAudioPlayerSeekTimeInterval = 1.0

class AudioPlayer: NSObject {
  static let sharedPlayer = AudioPlayer()
  private static var audioPlayer = STKAudioPlayer()
  
  var currentTrack: Track?
  private(set) var playlist: [Track] = []

  var listeners = ListenerArray<AudioPlayerListener>()
  
  override init()
  {
    super.init()
    AudioPlayer.audioPlayer.delegate = self
  }
}

// MARK: - Interface
// MARK: Playing State
extension AudioPlayer {
  var playState: PlayState {
    switch AudioPlayer.audioPlayer.state {
      case .Playing:
        return .Playing
      case .Buffering:
        return .Buffering
      case .Paused:
        return .Paused
      default:
        return .Stopped
    }
  }
  
  var isPlaying: Bool { return playState == .Playing || playState == .Buffering }
  
  func seekTimeForTrack(track: Track) -> Double
  {
//    return currentTrack == track ? AudioPlayer.audioPlayer.progress : 0
    return AudioPlayer.audioPlayer.progress
  }
}

// MARK: Playback Controls
extension AudioPlayer {
  /// Plays the provided track and clears the playlist if specified
  func play(track: Track, clearingPlaylist: Bool = false)
  {
    if track == currentTrack && AudioPlayer.audioPlayer.state == .Paused {
      AudioPlayer.audioPlayer.resume()
    } else {
      if currentTrack != nil {
        listeners.announceOnMainQueue { listener in listener.audioPlayer?(self, didStopTrack: self.currentTrack!) }
      }
      
      AudioPlayer.audioPlayer.play(track.streamURL)
      currentTrack = track
    }
    
    if clearingPlaylist {
      playlist = []
    } else {
      playlist.map { AudioPlayer.audioPlayer.queue($0.streamURL) }
    }
  }
  
  /// Plays the provided track, subscribes the provided listener to audio events and clears the playlist if specified
  func play(track: Track, withListener listener: AudioPlayerListener, clearingPlaylist: Bool = false)
  {
    addListener(listener)
    play(track, clearingPlaylist: clearingPlaylist)
  }
  
  /// Pauses the player. Requires that the player is playing or buffering a track
  func pause()
  {
    assert(AudioPlayer.audioPlayer.state == STKAudioPlayerState.Playing ||
           AudioPlayer.audioPlayer.state == STKAudioPlayerState.Buffering) // TODO: Put the assert somewhere else?
    AudioPlayer.audioPlayer.pause()
  }
  
  /// Seeks the current track to time 0
  func restartTrack()
  {
    AudioPlayer.audioPlayer.seekToTime(0)
  }
  
  /// Pops the first track off the playlist and plays it
  func playNextTrack()
  {
    if playlist.count > 0 {
      currentTrack = playlist.removeAtIndex(0)
      play(currentTrack!)
    }
  }
  
  /// Seeks the track provided to the time specified. Requires that the track provided is current playing track
  func seekTrack(track: Track, toTime time: Double)
  {
    assert(currentTrack == track) // TODO: put assert before call?
    AudioPlayer.audioPlayer.seekToTime(time)
  }
  
  /// Appends tracks provided to playlist, clearing the existing enqueued tracks if specified
  func addTracksToPlaylist(tracks: [Track], clearExisting: Bool = false)
  {
    assert(tracks.count > 0, "can't add 0 tracks to playlist")
    
    if clearExisting { clearPlaylist() }
    tracks.map { AudioPlayer.audioPlayer.queue($0.streamURL) }
    
    playlist += tracks
  }
  
  /// Appends track to playlist, clearing the existing enqueued tracks if specified
  func addTrackToPlaylist(track: Track, clearExisting: Bool = false)
  {
    addTracksToPlaylist([track], clearExisting: clearExisting)
  }
  
  /// Removes all pending tracks from playlist
  func clearPlaylist()
  {
    AudioPlayer.audioPlayer.clearQueue()
    playlist = []
  }
}

// MARK: Listeners
extension AudioPlayer {
  func addListener(listener: AudioPlayerListener)
  {
    listeners.addListener(listener)
  }
  
  func removeListener(listener: AudioPlayerListener)
  {
    listeners.removeListener(listener)
  }
}

// MARK: - Audio Player Delegate
extension AudioPlayer: STKAudioPlayerDelegate {
  func audioPlayer(audioPlayer: STKAudioPlayer!, didStartPlayingQueueItemId queueItemId: NSObject!)
  {
    if currentTrack?.streamURL == queueItemId as? String { return }
    
    if let trackIndex = playlist.indexOf({ $0.streamURL == queueItemId as! String }) {
      let newTrack = playlist[trackIndex]
      listeners.announceOnMainQueue { listener in
        if let currentTrack = self.currentTrack {
          listener.audioPlayer?(self, didStopTrack: currentTrack)
        }
        
        listener.audioPlayer?(self, didBeginPlayingTrack: newTrack)
      }
      
      playlist.removeAtIndex(0)
      currentTrack = newTrack
    }
  }
  
  func audioPlayer(audioPlayer: STKAudioPlayer!, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject!)
  {
    // TODO: can this cause "didBeginBufferingTrack" to not be called?
    NSLog("finished buffering item from queue: \(queueItemId)")
  }
  
  func audioPlayer(audioPlayer: STKAudioPlayer!, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState)
  {
    NSLog("State changed from: \(previousState.toString) to: \(state.toString)")
    
    switch state {
    case .Buffering:
      listeners.announceOnMainQueue { listener in listener.audioPlayer?(self, didBeginBufferingTrack: self.currentTrack!) }
      
    case .Playing:
      listeners.announceOnMainQueue { listener in listener.audioPlayer?(self, didBeginPlayingTrack: self.currentTrack!) }
      
    case .Paused:
      listeners.announceOnMainQueue { listener in listener.audioPlayer?(self, didPauseTrack: self.currentTrack!) }
      
    case .Stopped:
      listeners.announceOnMainQueue { listener in listener.audioPlayer?(self, didStopTrack: self.currentTrack!) }
      if Int(previousState.rawValue) & Int(STKAudioPlayerState.Running.rawValue) > 0 { playNextTrack() }
      
    case .Ready:
      fallthrough
    case .Running:
      fallthrough
    case .Error:
      NSLog("Audio player error: \(audioPlayer.stopReason)")
      fallthrough
    case .Disposed:
      break
    }
  }
  
  func audioPlayer(audioPlayer: STKAudioPlayer!,
    didFinishPlayingQueueItemId queueItemId: NSObject!,
    withReason stopReason: STKAudioPlayerStopReason,
    andProgress progress: Double, andDuration duration: Double)
  {
    
  }
  
  func audioPlayer(audioPlayer: STKAudioPlayer!, unexpectedError errorCode: STKAudioPlayerErrorCode)
  {
    NSLog("An unexpected error occured within the audio player, recreating player. Error: \(errorCode)")
    AudioPlayer.audioPlayer = STKAudioPlayer()
  }
  
  @objc func audioPlayer(audioPlayer: STKAudioPlayer!, logInfo line: String!)
  {
    NSLog("Audio player log: " + line)
  }
  
  @objc func audioPlayer(audioPlayer: STKAudioPlayer!, didCancelQueuedItems queuedItems: [AnyObject]!)
  {
    
  }
}

extension STKAudioPlayerState {
  var toString: String {
    switch self {
    case .Ready:
      return "Ready"
    case .Running:
      return "Running"
    case .Playing:
      return "Playing"
    case .Buffering:
      return "Buffering"
    case .Paused:
      return "Paused"
    case .Stopped:
      return "Stopped"
    case .Error:
      return "Error"
    case .Disposed:
      return "Disposed"
    }
  }
}

// MARK: - Helpers
extension AudioPlayer {
  
}