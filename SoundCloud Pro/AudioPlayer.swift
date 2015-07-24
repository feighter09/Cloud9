//
//  AudioPlayer.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/11/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

@objc protocol AudioPlayerListener: Listener {
  optional func audioPlayer(audioPlayer: AudioPlayer, didBeginPlayingTrack track: Track)
  optional func audioPlayer(audioPlayer: AudioPlayer, didBeginBufferingTrack track: Track)
  optional func audioPlayer(audioPlayer: AudioPlayer, didPauseTrack track: Track)
  optional func audioPlayer(audioPlayer: AudioPlayer, didStopTrack track: Track)
}

let kAudioPlayerDefaultSeekDelta: Double = 4
let kAudioPlayerSeekTimeInterval = 1.0

class AudioPlayer: NSObject {
  static let sharedPlayer = AudioPlayer()
  private static var audioPlayer = STKAudioPlayer()
  
  var currentTrack: Track?
  private var playlist: [Track] = []

  var listeners = ListenerArray<AudioPlayerListener>()
  
  override init()
  {
    super.init()
    AudioPlayer.audioPlayer.delegate = self
  }
}

// MARK: - Interface
// MARK: Play State
extension AudioPlayer {
  var playPauseState: PlayPauseState {
    switch AudioPlayer.audioPlayer.state {
    case .Playing:
      return .Play
    case .Buffering:
      return .Loading
    default:
      return .Pause
    }
  }
  
  var isPlaying: Bool {
    return playPauseState == .Play || playPauseState == .Loading
  }
  
  func seekTimeForTrack(track: Track) -> Double
  {
    return currentTrack == track ? AudioPlayer.audioPlayer.progress : 0
  }
}

// MARK: Playback Controls
extension AudioPlayer {
  func play(track: Track)
  {
    if track == currentTrack && AudioPlayer.audioPlayer.state == .Paused {
      AudioPlayer.audioPlayer.resume()
    } else {
      if currentTrack != nil {
        listeners.announce { listener in listener.audioPlayer?(self, didStopTrack: self.currentTrack!) }
      }
      
      currentTrack = track
      AudioPlayer.audioPlayer.play(track.streamURL)
    }
  }
  
  func play(track: Track, withListener listener: AudioPlayerListener)
  {
    addListener(listener)
    play(track)
  }
  
  func pause()
  {
    assert(AudioPlayer.audioPlayer.state == STKAudioPlayerState.Playing ||
           AudioPlayer.audioPlayer.state == STKAudioPlayerState.Buffering)
    AudioPlayer.audioPlayer.pause()
  }
  
  func restartTrack()
  {
    AudioPlayer.audioPlayer.seekToTime(0)
  }
  
  func playNextTrack()
  {
    if playlist.count > 0 {
      currentTrack = playlist.removeAtIndex(0)
      play(currentTrack!)
    }
  }
  
  func seekTrack(track: Track, toTime time: Double)
  {
    assert(currentTrack == track)
    AudioPlayer.audioPlayer.seekToTime(time)
  }
  
  func addTracksToPlaylist(tracks: [Track], clearExisting: Bool = false)
  {
    assert(tracks.count > 0, "can't add 0 tracks to playlist")
    
    if clearExisting { playlist = [] }
    if playlist.count == 0 { AudioPlayer.audioPlayer.queue(tracks.first!.streamURL) }
    
    playlist += tracks
  }
  
  func addTrackToPlaylist(track: Track, clearExisting: Bool = false)
  {
    addTracksToPlaylist([track], clearExisting: clearExisting)
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
    if let trackIndex = playlist.indexOf({ $0.streamURL == queueItemId as! String }) {
      let newTrack = playlist[trackIndex]
      listeners.announce { listener in
        if let currentTrack = self.currentTrack {
          listener.audioPlayer?(self, didStopTrack: currentTrack)
        }
        
        listener.audioPlayer?(self, didBeginPlayingTrack: newTrack)
      }
      
      currentTrack = newTrack
    }
  }
  
  func audioPlayer(audioPlayer: STKAudioPlayer!, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject!)
  {
    NSLog("playing: \(queueItemId)")
  }
  
  func audioPlayer(audioPlayer: STKAudioPlayer!, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState)
  {
    NSLog("State changed from: \(previousState.rawValue) to: \(state.rawValue)")
    switch state {
    case STKAudioPlayerState.Buffering:
      listeners.announce { listener in listener.audioPlayer?(self, didBeginBufferingTrack: self.currentTrack!) }
    case STKAudioPlayerState.Playing:
      listeners.announce { listener in listener.audioPlayer?(self, didBeginPlayingTrack: self.currentTrack!) }
    case STKAudioPlayerState.Paused:
      listeners.announce { listener in listener.audioPlayer?(self, didPauseTrack: self.currentTrack!) }
    case STKAudioPlayerState.Stopped:
      listeners.announce { listener in listener.audioPlayer?(self, didStopTrack: self.currentTrack!) }
      
      if Int(previousState.rawValue) & Int(STKAudioPlayerState.Running.rawValue) > 0 {
        playNextTrack()
      }
    case STKAudioPlayerState.Ready:
      fallthrough
    case STKAudioPlayerState.Running:
      fallthrough
    case STKAudioPlayerState.Error:
      NSLog("Audio player error: \(audioPlayer.stopReason)")
      fallthrough
    case STKAudioPlayerState.Disposed:
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
    NSLog(line)
  }
  
  @objc func audioPlayer(audioPlayer: STKAudioPlayer!, didCancelQueuedItems queuedItems: [AnyObject]!)
  {
    
  }
}
