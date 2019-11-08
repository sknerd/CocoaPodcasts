//
//  PlayerDetailsView.swift
//  PodcastsLBTA
//
//  Created by renks on 02/11/2019.
//  Copyright © 2019 Renald Renks. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class PlayerDetailsView: UIView {
    
    var episode: Episode! {
        
        didSet {
            miniTitleLabel.text = episode.title
            episodeTitleLabel.text = episode.title
            authorLabel.text = episode.author
            
            setupNowPlayingInfo()
            
            playEpisode()
            
            guard let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "") else { return }
            episodeImageView.sd_setImage(with: url)
            
            miniEpisodeImageView.sd_setImage(with: url) { (image, _, _, _) in
                
                let image = self.episodeImageView.image ?? UIImage()
                let artworkItem = MPMediaItemArtwork(boundsSize: .zero, requestHandler: { (size) -> UIImage in
                    return image
                })
                MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artworkItem
            }
        }
    }
    
    fileprivate func setupNowPlayingInfo() {
        
        var nowPlayingInfo = [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    fileprivate func playEpisode() {
        print("Trying to play episode ar url:", episode.streamUrl)
        
        guard let url = URL(string: episode.streamUrl) else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
//    var player: AVPlayer!
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    fileprivate func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            self?.currentTimeLabel.text = time.toDisplayString()
            let durationTime = self?.player.currentItem?.duration
            self?.durationLabel.text = durationTime?.toDisplayString()
            
            self?.updateCurrentTimeSlider()
        }
    }
    
    fileprivate func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(percentage)
    }
    
    var panGesture: UIPanGestureRecognizer!
    
    fileprivate func setupGestures() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        miniPlayerView.addGestureRecognizer(panGesture)
        
        maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
    }
    
    @objc func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        
        if gesture.state == .changed {
            let translation = gesture.translation(in: superview)
            self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        } else if gesture.state == .ended {
            let translation = gesture.translation(in: superview)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.transform = .identity
                
                if translation.y > 50 {
                    UIApplication.mainTabBarController()?.minimizePlayerDetails()
                }
            })
        }
    }
    
    //setting audio session for background playback
    
    fileprivate func setupAudioSession() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let sessionErr {
            print("Failed to activate session:", sessionErr)
        }
    }
    
    fileprivate func setupRemoteControll() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.play()
            self.playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            self.miniPlayPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            
            self.setupElapsedTime()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            self.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            self.miniPlayPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            self.setupElapsedTime()
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            
            self.handlePlayPause()
            
            return .success
        }
        
        
        //TODO: - Not working on iOS 13 because of the MPRemoteCommandCenter bug
//        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
//        commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePreviousTrack))
       
    }
    
//    var playlistEpisodes = [Episode]()
    
//    @objc fileprivate func handlePreviousTrack() {
//        changeTrack(moveForward: false)
//    }
//
//    @objc fileprivate func handleNextTrack() {
//        changeTrack(moveForward: true)
//    }
//
//    fileprivate func changeTrack(moveForward: Bool) {
//        let offset = moveForward ? 1 : playlistEpisodes.count - 1
//        if playlistEpisodes.count == 0 {return}
//        let currentEpisodeIndex = playlistEpisodes.firstIndex { (episode) -> Bool in
//            return self.episode.title == episode.title
//        }
//        guard let index = currentEpisodeIndex else {return}
//        self.episode = playlistEpisodes[(index + offset) % playlistEpisodes.count]
//    }
    
    fileprivate func setupElapsedTime() {
        
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
    }
    
    fileprivate func observeBoundaryTime() {
        let time = CMTime(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        
        //player has a reference to self
        //self has a reference to player
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            print("Episode started playing")
            self?.enlargeEpisodeImageView()
            self?.setupLockScreenDuration()
        }
    }
    
    fileprivate func setupLockScreenDuration() {
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupRemoteControll()
        setupAudioSession()
        setupGestures()
        observePlayerCurrentTime()
        
        observeBoundaryTime()
    }
    
    static func initFromNib() -> PlayerDetailsView {
        return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
    }
    
    deinit {
        print("PlayerDetailsView memory being reclaimed...")
    }
    
    //MARK:- IB Actions & Outlets
    
    @IBOutlet weak var miniEpisodeImageView: UIImageView!
    @IBOutlet weak var miniTitleLabel: UILabel!
    
    @IBOutlet weak var miniPlayPauseButton: UIButton!
    
    @IBAction func miniPlayPauseButton(_ sender: UIButton) {
        handlePlayPause()
    }
    @IBAction func handleMiniFastForward(_ sender: UIButton) {
        handleFastForward(self)
    }
    
    @IBOutlet weak var miniFastForwardButton: UIButton!
    @IBOutlet weak var maximizedStackView: UIStackView!
    @IBOutlet weak var miniPlayerView: UIView!
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        print("Slider value:", currentTimeSlider.value)
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeinSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeinSeconds, preferredTimescale: 1)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeinSeconds
        
        player.seek(to: seekTime)
        
    }
    
    @IBAction func handleRewind(_ sender: Any) {
        seekToCurrentTime(delta: -15)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentTime()) - 15
    }
    
    @IBAction func handleFastForward(_ sender: Any) {
        seekToCurrentTime(delta: 15)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentTime()) + 15
    }
    
    private func seekToCurrentTime(delta: Int64) {
        let fifteenSeconds = CMTimeMake(value: delta, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
    }
    
    @IBAction func handleVolumeChange(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBAction func handleDismiss(_ sender: UIButton) {
        UIApplication.mainTabBarController()?.minimizePlayerDetails()
    }
    
    private let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    
    fileprivate func shrinkEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = self.shrunkenTransform
            
        }, completion: nil)
    }
    
    fileprivate func enlargeEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.episodeImageView.transform = .identity
        }, completion: nil)
    }
    
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.layer.cornerRadius = 7
            episodeImageView.clipsToBounds = true
            episodeImageView.transform = shrunkenTransform
        }
    }
    
    @IBOutlet weak var playPauseButton: UIButton! {
        didSet {
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    @objc func handlePlayPause() {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            miniPlayPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            enlargeEpisodeImageView()
        } else {
            player.pause()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            miniPlayPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            shrinkEpisodeImageView()
        }
    }
    
    @IBOutlet weak var episodeTitleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
}
