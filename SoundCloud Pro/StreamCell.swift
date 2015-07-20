//
//  StreamCell.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/11/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit
import Bond

protocol StreamCellDelegate {
  func streamCell(streamCell: StreamCell, tappedUpVoteTrack track: Track)
  func streamCell(streamCell: StreamCell, tappedDownVoteTrack track: Track)
  func streamCellTappedNextTrack(streamCell: StreamCell)
}

let kStreamCellControlsHeight: CGFloat = 32
let kStreamCellControlsMargin: CGFloat = 4

class StreamCell: UITableViewCell {
  var listenerId: Int = 0
  var track: Track! {
    didSet { updateLabels() }
  }
  
  var delegate: StreamCellDelegate?
  
  @IBOutlet private weak var seekProgressBar: UISlider!
  private var seekTimer: NSTimer!
  // This seems like some shit to me
  private var tableView: UITableView? {
    var table = superview
    while !(table is UITableView) && table != nil {
      table = table!.superview
    }
    
    return table as? UITableView
  }
  
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
    // TODO: fill in
//    expandCell(false, animated: false)

  }
}

// MARK: - UI Action
extension StreamCell {
  @IBAction func playPauseTapped(button: PlayPauseButton)
  {
    if button.playState == .Pause {
      AudioPlayer.sharedPlayer.play(track, withListener: self)
      startUpdatingSeekTime()
      expandCell(true, animated: true)
    } else {
      AudioPlayer.sharedPlayer.pause()
      stopUpdatingSeekTime()
      expandCell(false, animated: true)
    }
  }
  
  @IBAction func upVoteTapped(sender: AnyObject)
  {
    delegate?.streamCell(self, tappedUpVoteTrack: track)
  }
  
  @IBAction func downVoteTapped(sender: AnyObject)
  {
    delegate?.streamCell(self, tappedDownVoteTrack: track)
  }
  
  @IBAction func beginningTapped(sender: AnyObject)
  {
    AudioPlayer.sharedPlayer.restartTrack()
  }
  
  @IBAction func endTapped(sender: AnyObject)
  {
    delegate?.streamCellTappedNextTrack(self)
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
}

extension StreamCell: AudioPlayerListener {
  func audioPlayer(audioPlayer: AudioPlayer, didBeginBufferingTrack track: Track)
  {
    if track == self.track {
      playPauseButton.playState = .Loading
    } else {
      playPauseButton.playState = .Pause
    }
  }
  
  func audioPlayer(audioPlayer: AudioPlayer, didBeginPlayingTrack track: Track)
  {
    if track == self.track {
      playPauseButton.playState = .Play
    } else {
      // TODO: shouldn't need this, confirm.
      playPauseButton.playState = .Pause
    }
  }
  
  func audioPlayer(audioPlayer: AudioPlayer, didPauseTrack track: Track)
  {
    if track == self.track {
      playPauseButton.playState = .Pause
    }
  }
}

// MARK: - Helpers
extension StreamCell {
  private func updateLabels()
  {
    assert(track != nil, "Track must not be nil")
    titleLabel.text = track.title
    artistLabel.text = track.artist
    
//    if track == AudioPlayer.sharedPlayer.currentTrack {
//      expandCell(true, animated: false)
//    }
//    
//    playPauseButton.playState = track == AudioPlayer.sharedPlayer.currentTrack ? .Play : .Pause
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
      self.tableView?.beginUpdates()
      self.tableView?.endUpdates()
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
    seekTimer.invalidate()
    seekTimer = nil
  }
}

