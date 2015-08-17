//
//  StreamCell.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/11/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit
import Bond

let kStreamCellPlaybackControlsHeight: CGFloat = 32
let kStreamCellPlaybackControlsMargin: CGFloat = 4
let kStreamCellVoteControlsWidth: CGFloat = 40

protocol StreamCellDelegate: NSObjectProtocol {
  func streamCell(streamCell: StreamCell, didDownvoteTrack track: Track)
  func streamCell(streamCell: StreamCell, didTapAddToPlaylist track: Track)
}

class StreamCell: UITableViewCell {
  var track: Track! {
    didSet {
      assert(track != nil, "Cannot set Track to nil")
      updateLabelsAndButtons()
    }
  }
  var playsOnSelection = true
  
  weak var delegate: StreamCellDelegate?
  
  var listenerId: Int = 0
  private var playState: PlayState = .Stopped {
    didSet { playingLabel.text = playState != .Stopped ? "[\(playState.rawValue)]" : "" }
  }
  
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var artistLabel: UILabel!
  @IBOutlet private weak var playingLabel: UILabel!
  
  @IBOutlet private weak var upVoteButton: UIButton!
  @IBOutlet private weak var downVoteButton: UIButton!
  @IBOutlet private weak var addToPlaylistButton: UIButton!
  
  required init?(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    AudioPlayer.sharedPlayer.addListener(self)
    MusicPlayerViewController.sharedPlayer.addListener(self)
  }

  deinit
  {
    AudioPlayer.sharedPlayer.removeListener(self)
  }
}

// MARK: - Life Cycle
extension StreamCell {
  static var nib: UINib { return UINib(nibName: "StreamCell", bundle: nil) }
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
    
    setColors()
  }
  
  override func prepareForReuse()
  {
    playState = .Stopped
  }
  
  private func setColors()
  {
    backgroundColor = .backgroundColor

    titleLabel.textColor = .primaryColor
    artistLabel.textColor = .secondaryColor
    playingLabel.textColor = .primaryColor
    
    addToPlaylistButton.tintColor = .secondaryColor
  }
}

// MARK: - UI Action
extension StreamCell {
  
  @IBAction func upVoteTapped(sender: AnyObject)
  {
    if !UserPreferences.upvotes.contains(track) {
      UserPreferences.addUpvote(track)
    }
    else {
      UserPreferences.removeUpvote(track)
    }
    
    updateUpDownButtons()
  }
  
  @IBAction func downVoteTapped(sender: AnyObject)
  {
    if !UserPreferences.downvotes.contains(track) {
      UserPreferences.addDownvote(track)
      delegate?.streamCell(self, didDownvoteTrack: track)
    }
    else {  // Right now this is not possible to get to, track won't be shown if it's downvoted
      UserPreferences.removeUpvote(track)
    }
    
    updateUpDownButtons()
  }

  override func setSelected(selected: Bool, animated: Bool)
  {
    super.setSelected(selected, animated: animated)
    if !selected { return }
    
    if !trackIsCurrentlyPlaying && playsOnSelection {
      AudioPlayer.sharedPlayer.play(track, clearingPlaylist: true)
    }

    setSelected(false, animated: animated)
  }
  
  @IBAction func addToPlaylist(sender: AnyObject)
  {
    delegate?.streamCell(self, didTapAddToPlaylist: track)
  }
}

// MARK: - Audio Playing Listener
extension StreamCell: AudioPlayerListener {
  func audioPlayer(audioPlayer: AudioPlayer, didBeginBufferingTrack track: Track)
  {
    updatePlayStateWithTrack(track)
  }
  
  func audioPlayer(audioPlayer: AudioPlayer, didBeginPlayingTrack track: Track)
  {
    updatePlayStateWithTrack(track)
  }
  
  func audioPlayer(audioPlayer: AudioPlayer, didPauseTrack track: Track)
  {
    updatePlayStateWithTrack(track)
  }
  
  func audioPlayer(audioPlayer: AudioPlayer, didStopTrack track: Track)
  {
    updatePlayStateWithTrack(track)
  }
  
  private func updatePlayStateWithTrack(track: Track)
  {
    if track == self.track { playState = AudioPlayer.sharedPlayer.playState }
    else { playState = .Stopped }
  }
}

// MARK: - Music Player Listener
extension StreamCell: Listener, MusicControllerListener {
  func musicPlayer(musicPlayer: MusicPlayerViewController, didTapUpvoteTrack track: Track)
  {
    if track == self.track { updateUpDownButtons() }
  }
}

// MARK: - Helpers
extension StreamCell {
  private var trackIsCurrentlyPlaying: Bool
  {
    return AudioPlayer.sharedPlayer.currentTrack == track && AudioPlayer.sharedPlayer.isPlaying
  }
  
  private func updateLabelsAndButtons()
  {
    titleLabel.text = track.title
    artistLabel.text = track.artist
    
    if let currentTrack = AudioPlayer.sharedPlayer.currentTrack where track == currentTrack {
      playState = AudioPlayer.sharedPlayer.playState
    } else {
      playState = .Stopped
    }

    updateUpDownButtons()
  }
  
  private func updateUpDownButtons()
  {
    upVoteButton.selected = UserPreferences.upvotes.contains(track)
    downVoteButton.selected = UserPreferences.downvotes.contains(track)
  }
}

