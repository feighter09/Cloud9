//
//  MusicPlayerViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/6/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit


let kMusicPlayerContractedHeight: CGFloat = 50
let kMusicPlayerExpandedHeight: CGFloat = 130
let kVoteControlsDefaultHeight: CGFloat = 44
let kPlaybackControlsHeight: CGFloat = 32

@objc protocol MusicControllerListener: Listener {
  optional func musicPlayer(musicPlayer: MusicPlayerViewController, didTapDownvoteTrack track: Track)
  optional func musicPlayer(musicPlayer: MusicPlayerViewController, didTapUpvoteTrack track: Track)
  optional func musicPlayer(musicPlayer: MusicPlayerViewController, didTapAddToPlaylist track: Track)
}

class MusicPlayerViewController: UIViewController {
  static var sharedPlayer = MusicPlayerViewController.instanceFromNib()
  
  // Internals
  private var track: Track! {
    didSet {
      titleLabel.text = track.title
      artistLabel.text = track.artist
      scrubber.maximumValue = Float(track.duration)
    }
  }
  
  private var listeners = ListenerArray<MusicControllerListener>()
  private var seekTimer: NSTimer!
  
  // IB Outlets
  @IBOutlet private weak var playPauseButton: PlayPauseButton!
  
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var artistLabel: UILabel!

  @IBOutlet private weak var beginningButton: UIButton!
  @IBOutlet private weak var endButton: UIButton!
  @IBOutlet private weak var scrubber: UISlider!
  
  @IBOutlet private weak var expandContractButton: UIButton!
  @IBOutlet private weak var addToPlaylistButton: UIButton!
  @IBOutlet private weak var borderLine: UIView!
  
  @IBOutlet private weak var voteControlsHeight: NSLayoutConstraint!
  @IBOutlet private weak var playbackControlsHeight: NSLayoutConstraint!
  
  var listenerId = 0
  
  deinit
  {
    stopUpdatingSeekTime()
  }
}

// MARK: - Interface
extension MusicPlayerViewController {
  private static var nibName: String { return "MusicPlayerViewController" }
  private class func instanceFromNib() -> MusicPlayerViewController
  {
    return MusicPlayerViewController(nibName: nibName, bundle: nil)
  }
}

// MARK: - View Life Cycle
extension MusicPlayerViewController {
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    titleLabel.text = "No song playing"
    artistLabel.text = ""
    setColors()
    
    AudioPlayer.sharedPlayer.addListener(self)
  }
  
  private func setColors()
  {
    titleLabel.textColor = .primaryColor
    artistLabel.textColor = .primaryColor
    scrubber.tintColor = .secondaryColor
    addToPlaylistButton.tintColor = .secondaryColor

    expandContractButton.tintColor = .secondaryColor
    expandContractButton.backgroundColor = .lightBackgroundColor
    borderLine.backgroundColor = .secondaryColor
    
    view.backgroundColor = .lightBackgroundColor
  }
}

// MARK: Listeners
extension MusicPlayerViewController {
  func addListener(listener: MusicControllerListener)
  {
    listeners.addListener(listener)
  }
  
  func removeListener(listener: MusicControllerListener)
  {
    listeners.removeListener(listener)
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
    if track == nil { return }

    UserPreferences.addUpvote(track)
    listeners.announce { listener in listener.musicPlayer?(self, didTapUpvoteTrack: track) }
  }

  @IBAction func downVoteTapped(sender: AnyObject)
  {
    if track == nil { return }

    // TODO: subscribe listeners to remove from playlist
    UserPreferences.addDownvote(track)
    listeners.announce { listener in listener.musicPlayer?(self, didTapDownvoteTrack: track) }
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
  
  @IBAction private func addToPlaylist(sender: AnyObject)
  {
    if track == nil { return }
    
    let playlistPicker = PlaylistPickerViewController()
    playlistPicker.track = track
    playlistPicker.delegate = self
    
    let navigationController = UINavigationController(rootViewController: playlistPicker)
    parentViewController!.presentViewController(navigationController, animated: true, completion: nil)
  }
  
  @IBAction private func toggleExpandContract(sender: AnyObject)
  {
    let oldFrame = view.frame
    let expand = (view.bounds.height == kMusicPlayerContractedHeight)

    let newHeight = (expand ? kMusicPlayerExpandedHeight : kMusicPlayerContractedHeight)
    let heightDiff = kMusicPlayerExpandedHeight - kMusicPlayerContractedHeight
    let yOffset = oldFrame.origin.y + (expand ? -1 : 1) * heightDiff

    UIView.animateWithDuration(0.5) { () -> Void in
      let transform = (expand ? CATransform3DMakeRotation(CGFloat(M_PI), 1, 0, 0) : CATransform3DIdentity)
      self.expandContractButton.imageView!.layer.transform = transform
      
      self.voteControlsHeight.constant = (expand ? kVoteControlsDefaultHeight : 0)
      self.playbackControlsHeight.constant = (expand ? kPlaybackControlsHeight: 0)

      self.view.frame = CGRect(x: oldFrame.origin.x,
                               y: yOffset,
                               width: oldFrame.width,
                               height: newHeight)
      self.view.layoutIfNeeded()
    }
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

// MARK: - Playlist Picker Delegate
extension MusicPlayerViewController: PlaylistPickerDelegate {
  func playlistPickerDidTapDone(playlistPicker: PlaylistPickerViewController)
  {
    parentViewController!.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func playlistPickerDidTapCancel(playlistPicker: PlaylistPickerViewController)
  {
    parentViewController!.dismissViewControllerAnimated(true, completion: nil)
  }
}

// MARK: - Helpers
extension MusicPlayerViewController {
  func updateSeekTime()
  {
    if track == nil {
      scrubber.setValue(0, animated: true)
      return
    }
    
    let seekTime = AudioPlayer.sharedPlayer.seekTimeForTrack(track)
    scrubber.setValue(Float(seekTime), animated: true)

    addTrackToRecentlyPlayedIfNecessary(seekTime)
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
  
  private func addTrackToRecentlyPlayedIfNecessary(seekTime: Double)
  {
    if seekTime > 30 { // I want this to shortcut going to NSUserDefaults, and you cant do an && before an 'if let'
      if let mostRecentlyPlayed = UserPreferences.recentsPlaylist.tracks.first {
        if mostRecentlyPlayed != track { UserPreferences.addTrackToRecentlyPlayed(track) }
      }
      else {
        UserPreferences.addTrackToRecentlyPlayed(track)
      }
    }
  }
}