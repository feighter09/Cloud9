//
//  MusicPlayerViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/6/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

class MusicPlayerViewController: UIViewController {
  private var track: Track! {
    didSet {
      titleLabel.text = track.title
      artistLabel.text = track.artist
      scrubber.maximumValue = Float(track.duration)
    }
  }
  
  private var seekTimer: NSTimer!
  
  @IBOutlet private weak var playPauseButton: PlayPauseButton!
  
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var artistLabel: UILabel!

  @IBOutlet private weak var beginningButton: UIButton!
  @IBOutlet private weak var endButton: UIButton!
  @IBOutlet private weak var scrubber: UISlider!
  
  var listenerId = 0
  
  deinit
  {
    stopUpdatingSeekTime()
  }
}

// MARK: - Interface
extension MusicPlayerViewController {
  
  private static var nibName: String { return "MusicPlayerViewController" }
  class func instanceFromNib() -> MusicPlayerViewController
  {
    return MusicPlayerViewController(nibName: nibName, bundle: nil)
  }
}

// MARK: - View Life Cycle
extension MusicPlayerViewController {
  override func viewDidLoad()
  {
    super.viewDidLoad()
    AudioPlayer.sharedPlayer.addListener(self)
  }
}

// MARK: - UI Action
extension MusicPlayerViewController {

  @IBAction func playPauseTapped(button: PlayPauseButton)
  {
    switch button.playState {
      case .Paused:
        AudioPlayer.sharedPlayer.resume()
      case .Playing:
        AudioPlayer.sharedPlayer.pause()
      default:
        break
    }    
  }

  @IBAction func upVoteTapped(sender: AnyObject)
  {
    if track != nil { UserPreferences.addUpvote(track) }
  }

  @IBAction func downVoteTapped(sender: AnyObject)
  {
    if track != nil { UserPreferences.addDownvote(track) }
    // TODO: remove from playlist
  //  delegate?.streamCell(self, didDownvoteTrack: track)
  }

  @IBAction func beginningTapped(sender: AnyObject)
  {
    AudioPlayer.sharedPlayer.restartTrack()
  }

  @IBAction func endTapped(sender: AnyObject)
  {
    AudioPlayer.sharedPlayer.playNextTrack()
  }

  @IBAction func seekTouchDown(sender: AnyObject)
  {
    stopUpdatingSeekTime()
  }

  @IBAction func seekEnd(sender: UISlider)
  {
    startUpdatingSeekTime()
  }

  @IBAction func seekValueChanged(slider: UISlider)
  {
    if track == nil { return }
    AudioPlayer.sharedPlayer.seekTrack(track, toTime: Double(slider.value))
  }
  
  @IBAction func addToPlaylist(sender: AnyObject)
  {
    
    // TODO: add to playlist
    //delegate?.streamCell(self, didTapAddToPlaylist: track)
  }
}

// MARK: - Audio Playing Listener
extension MusicPlayerViewController: AudioPlayerListener {
  func audioPlayer(audioPlayer: AudioPlayer, didBeginBufferingTrack track: Track)
  {
    updateTrackAndPlayState(track)
  }
  
  func audioPlayer(audioPlayer: AudioPlayer, didBeginPlayingTrack track: Track)
  {
    updateTrackAndPlayState(track)
  }
  
  func audioPlayer(audioPlayer: AudioPlayer, didPauseTrack track: Track)
  {
    updateTrackAndPlayState(track)
  }
  
  func audioPlayer(audioPlayer: AudioPlayer, didStopTrack track: Track)
  {
    updateTrackAndPlayState(track)
  }
  
  private func updateTrackAndPlayState(newTrack: Track)
  {
    track = newTrack
    playPauseButton.playState = AudioPlayer.sharedPlayer.playState
    startUpdatingSeekTimeIfNecessary()
  }
}

// MARK: - Helpers
extension MusicPlayerViewController {
  func updateSeekTime()
  {
    if track != nil {
      let seekTime = AudioPlayer.sharedPlayer.seekTimeForTrack(track)
      scrubber.setValue(Float(seekTime), animated: true)
    } else {
      scrubber.setValue(0, animated: true)
    }
  }
  
  private func startUpdatingSeekTimeIfNecessary()
  {
    if seekTimer != nil { return }
    startUpdatingSeekTime()
  }
  
  private func startUpdatingSeekTime()
  {
    seekTimer = NSTimer.scheduledTimerWithTimeInterval(0.1,
                                                       target: self,
                                                       selector: "updateSeekTime",
                                                       userInfo: nil,
                                                       repeats: true)
  }
  
  private func stopUpdatingSeekTime()
  {
    seekTimer?.invalidate()
    seekTimer = nil
  }
}