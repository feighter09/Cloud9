//
//  StreamCell.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/11/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit
import Bond

let kStreamCellControlsHeight: CGFloat = 32
let kStreamCellControlsMargin: CGFloat = 4

protocol StreamCellDelegate {
  func streamCell(streamCell: StreamCell, didDownvoteTrack track: Track)
}

class StreamCell: UITableViewCell {
  var listenerId: Int = 0
  var track: Track! {
    didSet { updateViews() }
  }
  
  var delegate: StreamCellDelegate?
  
  @IBOutlet private weak var seekProgressBar: UISlider!
  private var seekTimer: NSTimer!
  
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var artistLabel: UILabel!
  @IBOutlet private weak var playPauseButton: PlayPauseButton!
  
  private var waveformImage: Dynamic<UIImage?>!
  
  @IBOutlet private weak var controlsHeight: NSLayoutConstraint!
  @IBOutlet private weak var controlsMargin: NSLayoutConstraint!
//  @IBOutlet private weak var waveformImageView: UIImageView!
//  @IBOutlet private weak var waveformHeight: NSLayoutConstraint!
//  @IBOutlet private weak var waveformMargin: NSLayoutConstraint!
//  private lazy var waveformImageLoaded: Bond<UIImage?> = Bond<UIImage?>() { image in
//    self.waveformHeight.constant = kStreamCellWaveformHeight
//    self.waveformMargin.constant = kStreamCellWaveformMargin
//    
//    self.layoutIfNeeded()
//  }
  
  required init?(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    AudioPlayer.sharedPlayer.addListener(self)
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
    seekProgressBar.hidden = true
//    waveformImageView.dynImage.bindTo(waveformImageLoaded, fire: false)
  }
  
  override func prepareForReuse()
  {
    stopTrack()
  }
}

// MARK: - UI Action
extension StreamCell {
  @IBAction func playPauseTapped(button: PlayPauseButton)
  {
    if button.playState == .Pause {
      playTrack()
    } else {
      AudioPlayer.sharedPlayer.pause()
      stopTrack()
    }
  }
  
  @IBAction func upVoteTapped(sender: AnyObject)
  {
    UserPreferences.addUpvote(track)
  }
  
  @IBAction func downVoteTapped(sender: AnyObject)
  {
    UserPreferences.addDownvote(track)
    delegate?.streamCell(self, didDownvoteTrack: track)
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
    AudioPlayer.sharedPlayer.seekTrack(track, toTime: Double(slider.value))
  }
  
  override func setSelected(selected: Bool, animated: Bool)
  {
    super.setSelected(selected, animated: animated)
    
    if selected {
      if !trackIsCurrentlyPlaying { playTrack() }
      setSelected(false, animated: animated)
    }
  }
}

extension StreamCell: AudioPlayerListener {
  func audioPlayer(audioPlayer: AudioPlayer, didBeginBufferingTrack track: Track)
  {
    expandCell(track == self.track, animated: true)
    
    if track == self.track {
      playPauseButton.playState = .Loading
      startUpdatingSeekTime() // #1 might call for a refactor
    } else {
      playPauseButton.playState = .Pause
      stopUpdatingSeekTime()
    }
  }
  
  func audioPlayer(audioPlayer: AudioPlayer, didBeginPlayingTrack track: Track)
  {
    expandCell(track == self.track, animated: true)
    playPauseButton.playState = track == self.track ? .Play : .Pause
    startUpdatingSeekTime() // #1 might call for a refactor
  }
  
  func audioPlayer(audioPlayer: AudioPlayer, didPauseTrack track: Track)
  {
    if track == self.track {
      playPauseButton.playState = .Pause
    }
  }
  
  func audioPlayer(audioPlayer: AudioPlayer, didStopTrack track: Track)
  {
    if track == self.track {
      stopTrack()
    }
  }
}

// MARK: - Helpers
extension StreamCell {
  private func playTrack()
  {
    AudioPlayer.sharedPlayer.play(track)
    startUpdatingSeekTime()
    expandCell(true, animated: true)
  }
  
  private func stopTrack()
  {
    stopUpdatingSeekTime()
    playPauseButton.playState = .Pause
    expandCell(false, animated: true)
  }
  
  private var trackIsCurrentlyPlaying: Bool {
    return AudioPlayer.sharedPlayer.currentTrack == track && AudioPlayer.sharedPlayer.isPlaying
  }
  
  private func updateViews()
  {
    assert(track != nil, "Track must not be nil")
    titleLabel.text = track.title
    artistLabel.text = track.artist
  
    if track == AudioPlayer.sharedPlayer.currentTrack {
      startUpdatingSeekTime()
      expandCell(true, animated: false)
      playPauseButton.playState = AudioPlayer.sharedPlayer.playPauseState
    }
//    if let waveformURL = track.waveformURL {
//      self.getWaveformWithURL(waveformURL)
//    }
  }
  
  private func expandCell(expand: Bool, animated: Bool)
  {
    let animationDuration = animated ? 0.4 : 0
    UIView.animateWithDuration(animationDuration) { () -> Void in
      self.controlsHeight.constant = expand ? kStreamCellControlsHeight : 0
      self.controlsMargin.constant = expand ? kStreamCellControlsMargin : 0
      self.seekProgressBar.hidden = !expand
      
      self.layoutIfNeeded()
      if self.tableView != nil && self.tableView!.visibleCells.contains(self) {
        do {
          try self.tableView?.beginUpdates()
          try self.tableView?.endUpdates()
        } catch _ {
          print("Something went wrong expanding cell")
        }
      }
    }
  }
  
  func updateSeekTime()
  {
    let seekTime = AudioPlayer.sharedPlayer.seekTimeForTrack(track)
    seekProgressBar.setValue(Float(seekTime), animated: false)
    
    if seekTime >= track.duration {
      stopUpdatingSeekTime()
      playPauseButton.playState = .Pause
      // TODO: pause player
    }
  }
  
  private func startUpdatingSeekTime()
  {
    seekProgressBar.maximumValue = Float(track.duration)
    seekTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateSeekTime", userInfo: nil, repeats: true)
  }
  
  private func stopUpdatingSeekTime()
  {
    seekTimer?.invalidate()
    seekTimer = nil
  }
  
  // This seems like some shit to me
  private var tableView: UITableView? {
    var table = superview
    while !(table is UITableView) && table != nil {
      table = table!.superview
    }
    
    return table as? UITableView
  }
}

