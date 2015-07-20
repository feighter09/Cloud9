//
//  AudioPlayer.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/11/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

protocol AudioPlayerListener: Listener {
  func audioPlayer(audioPlayer: AudioPlayer, didBeginBufferingTrack track: Track)
  func audioPlayer(audioPlayer: AudioPlayer, didBeginPlayingTrack track: Track)
  func audioPlayer(audioPlayer: AudioPlayer, didPauseTrack track: Track)
}

let kAudioPlayerDefaultSeekDelta: Double = 4
let kAudioPlayerSeekTimeInterval = 1.0

class AudioPlayer: NSObject {
  static let sharedPlayer = AudioPlayer()
  private static var audioPlayer = STKAudioPlayer()
  
  var currentTrack: Track?
  var listeners = ListenerArray()
  
  var seekDelta = kAudioPlayerDefaultSeekDelta
  var seekTimer: NSTimer?
  
  override init()
  {
    super.init()
    AudioPlayer.audioPlayer.delegate = self
  }
}

// MARK: - Interface
extension AudioPlayer {
  func play(track: Track)
  {
    if track == currentTrack && AudioPlayer.audioPlayer.state == .Paused {
      AudioPlayer.audioPlayer.resume()
    } else {
      currentTrack = track
      AudioPlayer.audioPlayer.play("\(track.streamURL)?client_id=\(kSoundCloudClientID)")
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
  
  func durationForTrack(track: Track) -> Double?
  {
    return currentTrack == track ? AudioPlayer.audioPlayer.duration : nil
  }
  
  func seekTimeForTrack(track: Track) -> Double
  {
    return currentTrack == track ? AudioPlayer.audioPlayer.progress : 0
  }
  
  func seekTrack(track: Track, toTime time: Double)
  {
    assert(currentTrack == track)
    AudioPlayer.audioPlayer.seekToTime(time)
  }
  
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
    NSLog("buffering: \(queueItemId)")
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
      listeners.announce({ (listener) -> Void in
        let audioListener = listener as! AudioPlayerListener
        audioListener.audioPlayer(self, didBeginBufferingTrack: self.currentTrack!)
      })
    case STKAudioPlayerState.Playing:
      listeners.announce({ (listener) -> Void in
        let audioListener = listener as! AudioPlayerListener
        audioListener.audioPlayer(self, didBeginPlayingTrack: self.currentTrack!)
      })
    case STKAudioPlayerState.Paused:
      listeners.announce({ (listener) -> Void in
        let audioListener = listener as! AudioPlayerListener
        audioListener.audioPlayer(self, didPauseTrack: self.currentTrack!)
      })
    case STKAudioPlayerState.Ready:
      fallthrough
    case STKAudioPlayerState.Running:
      fallthrough
    case STKAudioPlayerState.Stopped:
      fallthrough
    case STKAudioPlayerState.Error:
      fallthrough
    case STKAudioPlayerState.Disposed:
      break
    }
    if state == STKAudioPlayerState.Error {
      NSLog("Audio player error: \(audioPlayer.stopReason)")
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

// MARK: - Helpers
extension AudioPlayer {
  private func resetSeeking()
  {
    seekTimer?.invalidate()
    seekDelta = kAudioPlayerDefaultSeekDelta
    AudioPlayer.audioPlayer.resume()
  }
}

// MARK: - Remnants
extension AudioPlayer {
  func rewind()
  {
    // TODO: come on clean this up
    seekTimer?.invalidate()
    
    let seekTime = AudioPlayer.audioPlayer.progress - seekDelta--
    AudioPlayer.audioPlayer.pause()
    AudioPlayer.audioPlayer.seekToTime(seekTime)
    seekTimer = NSTimer.scheduledTimerWithTimeInterval(kAudioPlayerSeekTimeInterval, target: self, selector: "rewind", userInfo: nil, repeats: true)
    AudioPlayer.audioPlayer.resume()
  }
  
  func stopRewind()
  {
    resetSeeking()
  }
  
  func fastForward()
  {
    seekTimer?.invalidate()
    
    let seekTime = AudioPlayer.audioPlayer.progress + seekDelta++
    AudioPlayer.audioPlayer.pause()
    AudioPlayer.audioPlayer.seekToTime(seekTime)
    seekTimer = NSTimer.scheduledTimerWithTimeInterval(kAudioPlayerSeekTimeInterval, target: self, selector: "fastForward", userInfo: nil, repeats: true)
    AudioPlayer.audioPlayer.resume()
  }
  
  func stopFastForward()
  {
    resetSeeking()
  }
}